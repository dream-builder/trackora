import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'SingInPage.dart';
import 'login.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // light blue background
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Title
            Column(
              children: [
                const SizedBox(height: 80),
                Text(
                    "School Bus Tracker".tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                // Eagle Logo
                Image.asset(
                  "assets/trackora_logo.png", // <-- place your eagle image in assets
                  height: 140,
                ),

                const SizedBox(height: 15),

              ],
            ),

            // Bottom Buttons & Text
            Column(
              children: [
                // Get Started Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black12, width: 1),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to next page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );

                    },
                    child: Text(
                      "GET STARTED".tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Sign In text
                GestureDetector(
                  onTap: () {
                    // Navigate to Sign In page
                  },
                  child: Column(
                    children:  [
                      Text(
                        "Don't have an account?".tr(),
                        style: TextStyle(color: Colors.black87),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Sign in here".tr(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
