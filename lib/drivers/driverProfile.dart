
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:trackora/SingInPage.dart';
import 'package:trackora/login.dart';
import 'package:trackora/students/LiveMapScreen.dart';
import 'package:trackora/drivers/DriverLiveScreen.dart';
import 'package:trackora/pages/LiveCarMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Dashboard.dart';
import '../config/config.dart';
import '../helpers/sharedPref.dart';


class SafeGoApp extends StatelessWidget {
  const SafeGoApp({super.key});

  // static const Color header = Color(0xFFE175FF);
  // static const Color header2 = Color(0xFF8EA2FF);
  // static const Color accent = Color(0xFF1B1B1B);
  // static const Color canvas = Color(0xFFF2F3F5);

  static const Color header = Color(0xFFFF6600);
  static const Color header2 = Color(0xFFFF6600);
  static const Color accent = Color(0xFFFF6600);
  static const Color canvas = Color(0xFFF2F3F5);


  // static String DriverName="";
  // static String DriverEmail="";
  // static String DriverPhone="";
  // static String DriverLicense="";
  // static int DriverID;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Theme',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: header,
          primary: header,
          secondary: header2,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          bodyMedium: TextStyle(fontSize: 14, height: 1.35),
        ),
      ),
      home: const Driverprofile(),
    );
  }
}

class Driverprofile extends StatefulWidget {
  const Driverprofile({super.key});

  @override
  State<Driverprofile> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<Driverprofile> {
  int _tab =1; //select Nav bar Icon

  Map<String, dynamic>? userData;

  // Sample data
  List<Map<String, dynamic>> routeList = [];

  @override
  void initState() {
    super.initState();
    checkLoginData();



    //routeList.add({"route": "Route D", "status": "On Time", "bus": "Bus 405"});
  }


  void checkLoginData() async {
    Map<String, dynamic> data = await loadLoginData();
    setState(() {
      userData = data;

      print("Saved Shared Preference");
      print ("User Data1: ${userData!['user_data']}");

      //Loading route list
      fetchrouteList(userData!['user_data']['driver_id']);

    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);



    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with curve and name
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: ClipPath(
                      clipper: _HeaderClipper(),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [SafeGoApp.header2, SafeGoApp.header],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 50,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(userData?['name']??"", style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 25)),
                    ),
                  ),
                  // Avatar floating
                  Positioned(
                    bottom: -10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 44,
                          backgroundColor: Color(0xFFF4F5F7),
                          backgroundImage: AssetImage("assets/driver_profile.png"),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    Row(
                      children:  [
                        Expanded(child: _InfoItem(label: "Name".tr(), value: userData?['name']??"")),
                        SizedBox(width: 26),
                        Expanded(child: _InfoItem(label: "Phone".tr(), value: "${userData?['user_data']?['driver_phone']??""}")),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(child: _InfoItem(label: "License".tr(), value: "${userData?['user_data']?['driver_license_no']??""}"),),
                        SizedBox(width: 26),
                        Expanded(child: _InfoItem(label: "E-mail".tr(), value: "${userData?['user_data']?['email']??""}"),),
                      ],
                    ),

                    const _SectionDivider(),

                    Column(
                      children: [
                        // Example: A header or filter bar
                        Container(
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.centerLeft,
                          child:  Text(
                            "Route".tr(),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),

                        // ✅ Expanded ensures ListView fills the remaining space

                      ],
                    ),
                    // ✅ ListView inside SingleChildScrollView
                    ListView.builder(
                      itemCount: routeList.length,
                      shrinkWrap: true, // <- important!
                      physics: const NeverScrollableScrollPhysics(), // <- disable inner scroll
                      itemBuilder: (context, index) {
                        var bus = routeList[index];
                        return Card(
                          margin:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(

                            title: Text(
                              "${bus["route_name"]}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Status".tr() + ": "),

                              ],
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6600) ), //Colors.blueAccent
                              onPressed: () async {

                                //set route id to shared pref
                                bool success = await setSharedPref("route_id", bus["route_id"]);

                                if (success) {
                                  //loading driver live activity
                                  Navigator.push(
                                    context,
                                      //_currentIndex=1
                                    MaterialPageRoute(builder: (context) => DriverliveScreen()),
                                  );
                                }else{
                                  print("not saved");
                                }






                              },
                              child: Text("Show".tr(),style:TextStyle(color:Colors.white)),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
        // bottomNavigationBar: NavigationBarTheme(
        //   data: NavigationBarThemeData(
        //     height: 56, // reduce bottom bar height
        //     labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // remove labels
        //   ),
        //   child: NavigationBar(
        //     backgroundColor: Color(0xB2FF6600),
        //     selectedIndex: _tab,
        //     onDestinationSelected: (i) {
        //       setState(() => _tab = i);
        //     },
        //     destinations: const [
        //       NavigationDestination(
        //         icon: Icon(Icons.home_outlined),
        //         selectedIcon: Icon(Icons.home),
        //         label: '',
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.person_outline),
        //         selectedIcon: Icon(Icons.person),
        //         label: '',
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.dashboard_customize_outlined),
        //         selectedIcon: Icon(Icons.dashboard),
        //         label: '',
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.apps_outlined),
        //         selectedIcon: Icon(Icons.apps),
        //         label: '',
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.location_on_outlined),
        //         selectedIcon: Icon(Icons.location_on),
        //         label: '',
        //       ),
        //     ],
        //   ),
        // )
    );
  }

  _onBottomNavClick(BuildContext context, i) {
    switch (i) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Driverprofile()),
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 3:
        Navigator.pushNamed(context, '/apps');
        break;
      case 4:
        Navigator.pushNamed(context, '/location');
        break;
    }
  }

  // ✅ Function to fetch bus list from API
  Future fetchrouteList(int id) async {
    const String url = "${apiBaseUrl}api/get_route_by_driver_id"; // Replace with your API
    final Map<String, String> params = {"id": id.toString()};

    try {
      final uri = Uri.parse(url).replace(queryParameters: params);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        updateRouteList(data);
      }
    } catch (e) {

    }
  }

  // ✅ Function to update list
  void updateRouteList(List<dynamic> data) {

    routeList.clear();

    // Convert each item into a Map<String, dynamic>
    List<Map<String, dynamic>> tempList = [];

    for (var item in data) {
      tempList.add(Map<String, dynamic>.from(item));
    }

    // Update state
    setState(() {
      routeList = tempList;
    });

  }

}


class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 0.4,
            color: Color(0xFF7B7D86),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      height: 2,
      width: double.infinity,
      color: SafeGoApp.header.withOpacity(0.7),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width; final h = size.height;
    final p = Path()
      ..lineTo(0, h * 0.6)
      ..quadraticBezierTo(w * 0.5, h * 1.05, w, h * 0.55)
      ..lineTo(w, 0)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
