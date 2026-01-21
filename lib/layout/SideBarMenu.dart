import 'package:flutter/material.dart';
import 'package:trackora/Logout.dart';
import 'package:trackora/helpers/ToastHelper.dart';

class AppSidebar extends StatelessWidget {

  final String accountName;
  final String accountEmail;
  final BuildContext context;

  const AppSidebar({
    super.key,
    required this.accountName,
    required this.accountEmail,
    required this.context,
  });

  //const AppSidebar({super.key, required this.onItemSelected});

  void onItemSelected(String key){

      //Navigator.pop(context); // close drawer

      if (key == "dashboard") {
        print("Dashboard clicked");
      }

      if (key == "users") {
        print("Users clicked");
      }

      if (key == "settings") {
        print("Settings clicked");
      }

      if (key == "logout") {
        logout(context);
      }

  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          // Header
          UserAccountsDrawerHeader(
            accountName: Text(accountName),
            accountEmail: Text(accountEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40),
            ),
          ),

          // Menu Items
          _menuItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            onTap: () => onItemSelected("dashboard"),
          ),

          _menuItem(
            icon: Icons.people,
            title: "Users",
            onTap: () => onItemSelected("users"),
          ),

          _menuItem(
            icon: Icons.settings,
            title: "Settings",
            onTap: () => onItemSelected("settings"),
          ),

          const Divider(),

          _menuItem(
            icon: Icons.logout,
            title: "Logout",
            onTap: () => onItemSelected("logout"),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
