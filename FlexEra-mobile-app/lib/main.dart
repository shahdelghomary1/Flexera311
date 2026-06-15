import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flexera/core/network/constants.dart';
import 'package:flexera/view/screens/booking_success_screen.dart';
import 'package:flexera/view/screens/notification_screen.dart';
import 'package:flexera/view/screens/splash_screen.dart';
import 'package:flexera/view_model/my_exercises_view_model.dart';
import 'package:flexera/view_model/account_info_view_model.dart';
import 'package:flexera/view_model/notification_view_model.dart';
import 'package:flexera/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flexera/core/network/cache_helper.dart';
import 'package:flexera/core/network/dio_helper.dart';
import 'package:flexera/core/themes/app_theme.dart';

import 'package:flexera/view/screens/home_screen.dart';
import 'package:flexera/view/screens/role_selection_screen.dart';
import 'package:flexera/view/screens/patients_list_screen.dart';
import 'package:flexera/view/screens/patient_profile_screen.dart';
import 'package:flexera/view/screens/exercise_screen.dart';
import 'package:flexera/view/screens/exercise_detail_screen.dart';
import 'package:flexera/view/screens/exercise_completion_screen.dart';
import 'package:flexera/view/screens/clinic_schedule_screen.dart';
import 'package:flexera/view/screens/doc_main_screen.dart';
import 'package:flexera/view/screens/doc_account_info_screen.dart';
import 'package:flexera/view/screens/doc_appointment_screen.dart';
import 'package:flexera/view_model/patients_view_model.dart';

import 'package:flexera/view_model/appointment_view_model.dart';
import 'package:flexera/view_model/booking_view_model.dart';
import 'package:flexera/view_model/payment_view_model.dart';
import 'package:flexera/view_model/support_viewmodel.dart';
import 'package:flexera/view_model/login_view_model.dart';
import 'package:flexera/view_model/signup_view_model.dart';
import 'package:flexera/view_model/exercise_view_model.dart';
import 'package:flexera/view_model/exercise_detail_view_model.dart';
import 'package:flexera/view_model/exercise_completion_view_model.dart';
import 'package:flexera/view_model/clinic_schedule_view_model.dart';

import 'package:flexera/view_model/patient_profile_view_model.dart';
import 'package:flexera/view_model/doc_main_view_model.dart';
import 'package:flexera/view_model/doc_account_info_view_model.dart';
import 'package:flexera/view_model/doc_appointment_view_model.dart';
import 'package:flexera/view_model/doc_settings_view_model.dart';

import 'model/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  DioHelper.init();
  await CacheHelper.init();
  await NotificationService.init();

  Widget startWidget;

  token = CacheHelper.getData(key: 'token');
  bool? onBoarding = CacheHelper.getData(key: 'onBoarding');
  bool? isDoctor = CacheHelper.getData(key: 'isDoctor');
  bool? isDark = CacheHelper.getData(key: 'isDark');

  if (onBoarding != null) {
    if (token != null) {
      if (isDoctor == true) {
        startWidget = const DocMainScreen();
      } else {
        startWidget = const HomeScreen();
      }
    } else {
      startWidget = const RoleSelectionScreen();
    }
  } else {
    startWidget = const SplashScreen();
  }

  runApp(MyApp(startWidget: startWidget, isDark: isDark));
}

class MyApp extends StatelessWidget {
  final Widget startWidget;
  final bool? isDark;

  const MyApp({super.key, required this.startWidget, this.isDark});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(startDark: isDark)),
        ChangeNotifierProvider(create: (_) => SupportViewModel()),
        ChangeNotifierProvider(create: (_) => BookingViewModel()),
        // ChangeNotifierProvider(create: (_) => PaymentViewModel()),
        ChangeNotifierProvider(create: (_) => AppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => ExerciseViewModel()),
        ChangeNotifierProvider(create: (_) => ClinicScheduleViewModel()),
        ChangeNotifierProvider(create: (_) => DocMainViewModel()),
        ChangeNotifierProvider(create: (_) => DocAccountInfoViewModel()),
        ChangeNotifierProvider(create: (_) => DocAppointmentViewModel()),
        ChangeNotifierProvider(create: (_) => DocSettingsViewModel()),
        ChangeNotifierProvider(create: (_) => MyExercisesViewModel()),
        ChangeNotifierProvider(create: (_) => AccountInfoViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ScreenUtilInit(
            designSize: const Size(405, 923),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                title: 'FlexEra',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                home: startWidget,
                routes: {
                  '/patients': (context) => const PatientsListScreen(),
                  '/patient-profile': (context) {
                    final patient =
                        ModalRoute.of(context)!.settings.arguments as Patient;
                    return PatientProfileScreen(patient: patient);
                  },
                  '/exercise': (context) => const ExerciseScreen(),
                  '/exercise-detail': (context) {
                    final exerciseName =
                        ModalRoute.of(context)!.settings.arguments as String;
                    return ExerciseDetailScreen(exerciseName: exerciseName);
                  },
                  '/exercise-completion': (context) {
                    final exerciseName =
                        ModalRoute.of(context)!.settings.arguments as String;
                    return ExerciseCompletionScreen(exerciseName: exerciseName);
                  },
                  '/clinic-schedule': (context) => const ClinicScheduleScreen(),
                  '/doc-main': (context) => const DocMainScreen(),
                  '/doc-account-info': (context) =>
                      const DocAccountInfoScreen(),
                  '/doc-appointment': (context) => const DocAppointmentScreen(),
                  '/notifications': (context) => const NotificationScreen(),
                  "/success": (context) => const BookingSuccessScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
