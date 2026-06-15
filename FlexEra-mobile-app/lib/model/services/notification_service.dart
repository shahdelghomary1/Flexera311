import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexera/core/network/cache_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await CacheHelper.init();

  bool? isDoctor = CacheHelper.getData(key: 'isDoctor');
  if (isDoctor == true) {
    debugPrint("⛔ Blocked Firebase Notification for Doctor (Background)");
    return;
  }
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static final PusherChannelsFlutter _pusher =
      PusherChannelsFlutter.getInstance();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static PusherChannelsFlutter get pusher => _pusher;

  static Future<void> init() async {
    await _initLocalNotification();
    await _requestPermission();
    await _initFirebase();
    await _initPusher();
  }

  static Future<void> logout() async {
    try {
      String? userId = CacheHelper.getData(key: 'userId');
      if (userId != null) {
        await _pusher.unsubscribe(channelName: "user-$userId");
        debugPrint("✅ Pusher: Unsubscribed from user-$userId");
      }
      await _pusher.disconnect();
      debugPrint("✅ Pusher: Disconnected completely");
    } catch (e) {
      debugPrint("⚠️ Pusher Logout Warning: $e");
    }
  }

  static Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }

    if (Platform.isIOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _initFirebase() async {
    try {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      String? fcmToken = await _firebaseMessaging.getToken();
      debugPrint("🔥 Firebase FCM Token: $fcmToken");

      if (fcmToken != null) {
        CacheHelper.saveData(key: 'fcmToken', value: fcmToken);
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          _showFirebaseNotification(message);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _onNotificationTap(jsonEncode(message.data));
      });
    } catch (e) {
      debugPrint("❌ Firebase Init Error: $e");
    }
  }

  static Future<void> _initPusher() async {
    try {
      await _pusher.init(
        apiKey: "d33cd74ce7f397f34b7f",
        cluster: "mt1",
        onEvent: (PusherEvent event) {
          debugPrint("🔔 Pusher Event: ${event.eventName}");

          bool? isDoctor = CacheHelper.getData(key: 'isDoctor');
          if (isDoctor == true) {
            debugPrint("⛔ Ignored Pusher Event for Doctor");
            return;
          }

          switch (event.eventName) {
            case 'notification:appointmentReminder':
            case 'notification:newScheduleAvailable':
            case 'notification:newDoctor':
            case 'notification:newExercises':
            case 'notification:exerciseUpdated':
            case 'notification:exerciseDeleted':
              _showNotification(event);
              break;
            default:
              break;
          }
        },
        onSubscriptionSucceeded: (channelName, data) {
          debugPrint("✅ Subscribed successfully to: $channelName");
        },
        onError: (String message, int? code, dynamic e) {
          debugPrint("❌ Pusher Error: $message Code: $code");
        },
      );

      await connectUser();
    } catch (e) {
      debugPrint("❌ Init Exception: $e");
    }
  }

  static Future<void> connectUser() async {
    bool? isDoctor = CacheHelper.getData(key: 'isDoctor');

    if (isDoctor == true) {
      debugPrint("👨‍⚕️ Current user is Doctor. Skipping Pusher subscription.");
      return;
    }

    String? userId = CacheHelper.getData(key: 'userId');
    if (userId != null) {
      String channelName = "user-$userId";
      try {
        await _pusher.subscribe(channelName: channelName);
        await _pusher.connect();
        debugPrint("✅ Pusher Connected & Subscribed to $channelName");
      } catch (e) {
        if (e.toString().contains("Already subscribed")) {
          debugPrint("ℹ️ Pusher: Already subscribed (Safe to ignore)");
        } else {
          debugPrint("❌ Pusher Subscribe Error: $e");
        }
      }
    }
  }

  static Future<void> _showFirebaseNotification(RemoteMessage message) async {
    bool isEnabled = CacheHelper.getData(key: 'isNotificationsEnabled') ?? true;
    if (!isEnabled) return;

    bool? isDoctor = CacheHelper.getData(key: 'isDoctor');
    if (isDoctor == true) {
      debugPrint("⛔ Blocked Firebase Notification for Doctor (Foreground)");
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'flexera_channel_main',
      'FlexEra Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? "FlexEra",
      message.notification?.body ?? "New Notification",
      details,
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> _showNotification(PusherEvent event) async {
    bool isEnabled = CacheHelper.getData(key: 'isNotificationsEnabled') ?? true;
    if (!isEnabled) return;

    try {
      final Map<String, dynamic> data = jsonDecode(event.data);
      String title = "FlexEra";

      if (event.eventName == 'notification:appointmentReminder') {
        title = "📅 Appointment Reminder";
      } else if (event.eventName == 'notification:newScheduleAvailable') {
        title = "📝 New Schedule Available";
      } else if (event.eventName == 'notification:newDoctor') {
        title = "👨‍⚕️ New Doctor Added";
      } else if (event.eventName == 'notification:newExercises') {
        title = "🏋️ New Exercise Added";
      } else if (event.eventName == 'notification:exerciseUpdated') {
        title = "✏️ Exercise Updated";
      } else if (event.eventName == 'notification:exerciseDeleted') {
        title = "🗑️ Exercise Removed";
      }

      String body = data['message'] ??
          data['content'] ??
          data['data']?['message'] ??
          "You have a new update";

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'flexera_channel_main',
        'FlexEra Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: event.data,
      );
    } catch (e) {
      debugPrint("Error showing notification: $e");
    }
  }

  static Future<void> _initLocalNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/logo');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationTap(response.payload);
      },
    );
  }

  static void _onNotificationTap(String? payload) {
    if (payload != null) {
      navigatorKey.currentState?.pushNamed('/notifications');
    }
  }
}
