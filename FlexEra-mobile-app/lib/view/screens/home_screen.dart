import 'package:flexera/view/screens/about_us_screen.dart';
import 'package:flexera/view/screens/account_info_screen.dart';
import 'package:flexera/view/screens/home_content_screen.dart';
import 'package:flexera/view/screens/settings_screen.dart';
import 'package:flexera/view/widget/custom_navbar.dart';
import 'package:flexera/view/widget/mood_overlay.dart';
import 'package:flexera/view/widget/search_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showMoodOverlay = false;
  final List<Widget> _pages = const [
    HomeContentScreen(),
    SettingsScreen(),
    AccountInfoScreen(),
    AboutUsScreen(),
  ];

  @override
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      bool seen = prefs.getBool('mood_overlay_seen') ?? false;

      if (!seen) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: MoodOverlay(onDismissed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('mood_overlay_seen', true);
            }),
          ),
        );
      }
    });
  }


  void _onNavBarTapped(int index) {
    // if (index == 1) {
    //   showSearchSheet(context);
    //   return;
    // }
    // if (index == 2) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => AccountInfoScreen(),
    //     ),
    //   );
    //   return;
    // }
    setState(() {
      _currentIndex = index;
    });
  }

  void _dismissOverlay() {
    setState(() => _showMoodOverlay = false);
  }

  // void showSearchSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) {
  //       return Container(
  //         height: MediaQuery.of(context).size.height * 0.4,
  //         decoration: BoxDecoration(
  //           color: Theme.of(context).scaffoldBackgroundColor,
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
  //         ),
  //         child: const SearchBottomSheet(),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),
          if (_showMoodOverlay) MoodOverlay(onDismissed: _dismissOverlay),
        ],
      ),
      bottomNavigationBar:
      CustomNavBar(currentIndex: _currentIndex, onTap: _onNavBarTapped),
    );
  }
}
