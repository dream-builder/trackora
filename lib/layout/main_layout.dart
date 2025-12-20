import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:trackora/Logout.dart';
import 'package:trackora/SingInPage.dart';
import 'package:trackora/drivers/DriverLiveScreen.dart';
import 'package:trackora/drivers/TripDetail.dart';
import 'package:trackora/drivers/driverProfile.dart';
import 'package:trackora/drivers/driver_profile_page.dart';
import 'package:trackora/login.dart';
import 'package:trackora/students/LiveMapScreen.dart';
import 'package:trackora/students/LiveMapScreen.dart';
import 'package:trackora/students/Profile.dart';

import '../helpers/AppColors.dart';
import '../helpers/sharedPref.dart';
import '../provider/AppBarTitleProvider.dart';

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
  Map<String, dynamic>? user;
  List<Widget> _pages = [];
  List<String> _titles=[];
  String _appBarTitle = "Trackora";

  Widget _buildPage(int index) {

    if(user?['role']=='student'){
      switch (index) {
        case 0:
          return  LiveMapScreen();
        case 1:
          return  ProfilePage();
        case 2:
          return  ProfilePage();
        case 3:
          return  SignInPage();
        default:
          return  ProfilePage();
      }
    }

    if(user?['role']=='driver'){

      switch (index) {
        case 0:
          return  DriverProfilePage();
        case 1:
          return  FieldTripPage();
        case 2:
          return  DriverliveScreen();
        case 3:
          return  SignInPage();
        default:
          return  DriverProfilePage();
      }

    }

    return const SizedBox();
  }

  // 🔁 CALLBACK FUNCTION
  void updateAppBarTitle(String title) {
    setState(() {
      _appBarTitle = title;
    });
  }

  Future<void> init() async {
    Map<String, dynamic>?profile = await loadLoginData();

    setState(() {
      user = profile;

      
      

      //

      print("users: ${user}");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  List<NavigationDestination> buildNavDestinations() {

    List<NavigationDestination> items = [];

    if (user?['role']=='student') {
      items=[
        NavigationDestination(
          icon: Icon(Icons.map),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.logout),
          label: '',
        ),
      ];
    }

    if (user?['role']=='driver') {
      items=[
        NavigationDestination(
          icon: Icon(Icons.person),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.map),
          label: '',
        ),

        NavigationDestination(
          icon: Icon(Icons.settings),
          label: '',
        ),
        NavigationDestination(
          icon: Icon(Icons.logout),
          label: '',
        ),
      ];
    }

    return items;
  }

  void changeAppBarTitle(BuildContext context, String title) {
    context.read<AppBarTitleProvider>().updateTitle(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 TITLE BAR
      //   AppBar(
      //     title: Consumer<AppBarTitleProvider>(
      //       builder: (_, provider, __) => Text(provider.title),
      //     ),
      //   )
      appBar: AppBar(
        //title:  Text(_appBarTitle),
        title: Consumer<AppBarTitleProvider>(
                builder: (_, provider, __) => Text(provider.title),
              ),
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
      // body: IndexedStack(
      //   index: _currentIndex,
      //   children: _pages,
      // ),
      
      body: _buildPage(_currentIndex),

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
                changeAppBarTitle(context, _titles[_currentIndex]);
              }
              else if(index == 3){
                logout(context);
              }

            },
            destinations: buildNavDestinations(),
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
