
import 'package:trackora/Dashboard.dart';
import 'package:trackora/GoogleMapExample.dart';
import 'package:trackora/students/LiveMapScreen.dart';
import 'package:trackora/drivers/driverProfile.dart';
import 'package:trackora/pages/SliderSwitchExample.dart';
import 'package:trackora/profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


import 'helpers/sharedPref.dart';
import 'login.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool rememberMe = false;

  final TextEditingController emailController = TextEditingController(text: "saifan@trackora.ca");
  final TextEditingController passwordController = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Column(
                children: [
                  Image.asset(
                    "assets/trackora_logo.png", // Put your black eagle image here
                    height: 120,
                  ),
                  const SizedBox(height: 10),

                ],
              ),

              const SizedBox(height: 40),

              // Sign In Title
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sign In".tr(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFAF6EFF), // blue color
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Email Field
              TextField(
                controller: emailController,

                decoration: InputDecoration(
                  labelText: "E-mail".tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),


              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password".tr(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Remember & Forgot Password Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Colors.pink,
                        value: rememberMe,
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                      Text(
                        "Remember".tr(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Forgot password navigation
                    },
                    child: Text(
                      "Forgot Password".tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Sign In Button
              SizedBox(

                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    // TODO: Sign In Logic
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => DashboardScreen()),
                    // );

                    String email = emailController.text.trim();
                    String password = passwordController.text;

                    if(await loginUser(email, password)== true){

                      loadDashboard(context);


                    }

                  },
                  child: Text(
                    "Sign In".tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadDashboard(BuildContext context) async {
    Map<String, dynamic> data = await loadLoginData();

    if(data['role']=="admin"){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LiveMapScreen()),
      );
    }

    if(data['role']=="driver"){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Driverprofile() ),
      );
    }

    if(data['role']=="student"){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LiveMapScreen() ),
      );
    }


  }
}
