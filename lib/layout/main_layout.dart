import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trackora/Logout.dart';
import 'package:trackora/SingInPage.dart';
import 'package:trackora/drivers/DriverLiveScreen.dart';
import 'package:trackora/login.dart';
import 'package:trackora/students/LiveMapScreen.dart';
import 'package:trackora/students/LiveMapScreen.dart';
import 'package:trackora/students/Profile.dart';

import '../helpers/AppColors.dart';

// import '../screens/map_screen.dart';
// import '../screens/profile_screen.dart';
// import '../screens/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    LiveMapScreen(),
    ProfilePage(),
    DriverliveScreen(),
    SignInPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 TITLE BAR
      appBar: AppBar(
        title: const Text("Trackora"),
        backgroundColor: AppColors.student,
        foregroundColor:Colors.white,
      ),

      // 🔹 NAVIGATION DRAWER
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.student),
              child: Text(
                "Trackora Menu".tr(),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            _drawerItem(Icons.home, "Home".tr(), 0),
            _drawerItem(Icons.map, "Live".tr(), 1),
            _drawerItem(Icons.person, "Profile".tr(), 2),
            _drawerItem(Icons.settings, "Settings".tr(), 3),
          ],
        ),
      ),

      // 🔹 PAGE CONTENT (CHANGES ONLY THIS)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 🔹 FIXED BOTTOM BAR
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            iconTheme: MaterialStateProperty.resolveWith<IconThemeData>(
                  (states) {
                if (states.contains(MaterialState.selected)) {
                  return const IconThemeData(color: AppColors.student); // selected
                }
                return const IconThemeData(color: Colors.grey); // unselected
              },
            ),
          ),
          child: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {

              if(index<=2){
                setState(() => _currentIndex = index);
              }
              else if(index == 3){
                logout(context);
              }

            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.map), label: ''),
              NavigationDestination(icon: Icon(Icons.person), label: ''),
              NavigationDestination(icon: Icon(Icons.settings), label: ''),
              NavigationDestination(icon: Icon(Icons.logout), label: ''),
            ],
          ),
        ),

    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: AppColors.student),
      title: Text(title),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
