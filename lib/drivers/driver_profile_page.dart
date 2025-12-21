import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:trackora/drivers/TripDetail.dart';
import '../config/config.dart';
import '../helpers/sharedPref.dart';
import '../provider/AppBarTitleProvider.dart';
import '../provider/PageProvider.dart';
import 'DriverLiveScreen.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  int selectedTab = 2; // 0=Basic, 1=License, 2=Route
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> routeList = [];

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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkLoginData();


    // 🔔 Set title when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppBarTitleProvider>().updateTitle("Profile".tr());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileHeader(),
            const SizedBox(height: 20),
            _statsRow(),
            const SizedBox(height: 20),
            _tabs(),
            const SizedBox(height: 20),
            _tabContent(),
          ],
        ),
      ),
    );
  }

  // ---------------- PROFILE HEADER ----------------
  Widget _profileHeader() {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: Colors.red,
              child: CircleAvatar(
                radius: 43,
                backgroundImage: AssetImage("assets/student.png"), // replace
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.red,
                child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            )
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text(
                "${userData?['name']??''}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Professional Driver",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 6),
              Text(
                "ID-${userData?['user_data']['driver_id']??''}",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        )
      ],
    );
  }

  // ---------------- STATS ----------------
  Widget _statsRow() {
    return Row(
      children: [
        _statCard("12", "Years\nExperience"),
        _statCard("20", "Trips\ncompleted"),
        _statCard("02", "KM\nDriven(km)"),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TABS ----------------
  Widget _tabs() {
    return Row(
      children: [
        _tabButton(Icons.person_outline, "Basic\nInformation", 0),
        _tabButton(Icons.badge_outlined, "License\nInformation", 1),
        _tabButton(Icons.route_outlined, "Route\nInformation", 2),
      ],
    );
  }

  Widget _tabButton(IconData icon, String text, int index) {
    final bool isActive = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.red : Colors.grey.shade300,
            ),
            color: isActive ? Colors.red.withOpacity(0.05) : Colors.white,
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? Colors.red : Colors.black),
              const SizedBox(height: 4),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- TAB CONTENT ----------------
  Widget _tabContent() {
    if (selectedTab == 0) {
      return _basicInfo();
    }
    if (selectedTab == 1) {
      return _licenseInfo();
    }
    if (selectedTab == 2) {
      return _routeList();
    }


    return Container(
      height: 120,
      alignment: Alignment.center,
      child: const Text("Content coming soon1"),
    );
  }
  Widget _basicInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _licenseRow(
            icon: Icons.email,
            label: "EMAIL",
            value: "${userData?['user_data']['email']??''}",
          ),
          _divider(),
          _licenseRow(
            icon: Icons.phone,
            label: "PHONE",
            value: "${userData?['user_data']['driver_phone']??''}",
          ),
          _divider(),
          Row(
            children: const [
              Icon(Icons.calendar_month, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "LICENSE EXPIRY DATE",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(width: 6),
              CircleAvatar(radius: 4, backgroundColor: Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 32),
            child: Text(
              "13/10/2025",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }


  Widget _licenseInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _licenseRow(
            icon: Icons.badge,
            label: "LICENSE NUMBER",
            value: "${userData?['user_data']['driver_license_no']??''}",
          ),
          _divider(),
          _licenseRow(
            icon: Icons.calendar_today,
            label: "RENEWAL DATE",
            value: "14/10/2015",
          ),
          _divider(),
          Row(
            children: const [
              Icon(Icons.calendar_month, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "LICENSE EXPIRY DATE",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(width: 6),
              CircleAvatar(radius: 4, backgroundColor: Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 32),
            child: Text(
              "13/10/2025",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _licenseRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.red),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _routeList(){
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red),
        ),
        child:
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
              "Route Name",
              style: const TextStyle(color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${bus["route_name"]}"),

              ],
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6600) ), //Colors.blueAccent
              onPressed: () async {

                //set route id to shared pref
                bool success = await setSharedPref("route_id", bus["route_id"]);

                if (success) {

                  context.read<PageProvider>().changePage(1);
                  //loading driver live activity
                  // Navigator.push(
                  //   context,
                  //   //_currentIndex=1
                  //   MaterialPageRoute(builder: (context) => FieldTripPage()),
                  // );
                }else{
                  print("not saved");
                }






              },
              child: Text("Show".tr(),style:TextStyle(color:Colors.white)),
            ),
          ),
        );
      },
      )
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: Colors.grey.shade300),
    );
  }
}
