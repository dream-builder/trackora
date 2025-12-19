import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:trackora/controlers/StudentProfileController.dart';
import 'package:trackora/helpers/StringHelper.dart';

import '../helpers/camera_helper.dart';
import '../helpers/sharedPref.dart';

class AppTheme {
  static const Color primary = Color(0xFF00A7A7);
  static const Color softBg = Color(0xFFEAF9F9);
  static const Color textGrey = Color(0xFF7A7A7A);

  static const double radius = 16;

  static ThemeData theme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primary,
    fontFamily: "Roboto",
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
  );
}


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isActive = true;
  Map<String, dynamic>? studentProfile;
  String? imagePath ="";

  Future<void> init() async {
    Map<String, dynamic>?profile = await loadLoginData();

    setState(() {
      studentProfile = profile;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    init();
  }

  void captureImage() async {
    final path = await CameraHelper.takePicture();

    if (imagePath != null) {
      print("Image saved at: $imagePath");
    }

    if (path != null && mounted) {
      setState(() {
        imagePath = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileHeader(),
            const SizedBox(height: 24),
            _infoCard(),
            const SizedBox(height: 20),
            _bikeDetails(),
            const SizedBox(height: 24),

          ],
        ),
      ),
    );
  }

  // ---------------- Profile Header ----------------
  Widget _profileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.primary.withOpacity(.12),

              child: InkWell(
                onTap: captureImage,
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: imagePath != null
                      ? FileImage(File(imagePath!))
                      : const AssetImage("assets/student.png") as ImageProvider,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primary,
                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
         Text(
          "${studentProfile?['name']??''}",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text("ID-${studentProfile?['user_data']['student_id']??''}", style: TextStyle(color: AppTheme.textGrey)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            _RoleChip("${capitalizeFirst(studentProfile?['role']??'')}"),
            SizedBox(width: 8),

          ],
        ),
      ],
    );
  }

  // ---------------- Info Card ----------------
  Widget _infoCard() {
    return _card(
      Column(
        children: [
          const _InfoRow(Icons.badge, "DESIGNATION", "Senior Software Engineer"),
          const Divider(),
          _InfoRow(Icons.email, "EMAIL ADDRESS", "${studentProfile?['email']??''}"),
          const Divider(),
           _InfoRow(Icons.phone, "PHONE NUMBER", "${studentProfile?['phone'] ?? ''}"),
          const Divider(),
          _InfoRow(Icons.calendar_month, "DATE of BIRTH", ""),
        ],
      ),
    );
  }

  // ---------------- Bike Details ----------------
  Widget _bikeDetails() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.route, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                "Route Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.softBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [

                const _InfoRow(Icons.route_sharp, "ROUTE ID/NAME", "401"),
                const Divider(),
                _InfoRow(Icons.maps_home_work, "Pickup Point", ""),
                const Divider(),
                _InfoRow(Icons.map_rounded, "Destination Point", ""),
              ],
            ),
          ),
        ],
      ),
    );
  }



  // ---------------- Helpers ----------------
  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _bikeRow(String title, String value, {required String badge}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label(title),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary),
          ),
          child: Text(
            badge,
            style: const TextStyle(color: AppTheme.primary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _bikeItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(title),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey));
  }
}

class _RoleChip extends StatelessWidget {
  final String text;
  const _RoleChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      backgroundColor: AppTheme.primary.withOpacity(.1),
      labelStyle: const TextStyle(color: AppTheme.primary),
      side: BorderSide.none,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

