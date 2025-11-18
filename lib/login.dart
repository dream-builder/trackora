import 'dart:convert';
import 'dart:ffi';
import 'package:trackora/profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'config/config.dart';
import 'helpers/LoaderController.dart';


Future<bool> loginUser(String email, String password) async {

  String apiUrl = "${apiBaseUrl}api/login";

  try {

    // Attach parameters directly in the URL
    final uri = Uri.parse(apiUrl).replace(queryParameters: {
      "email": email,
      "password": password,
    });

    print ("sending request to : " + apiUrl);
    final response = await http.get(
      uri,
      headers: {
        "Accept": "application/json",
      },
    );

   // print(uri);

    if (response.statusCode == 200) {
      LoaderController.hideLoader();
      print("Got response from server");
      final data = jsonDecode(response.body);

      if (data['status'] == true) {

        // Decode JSON string into a Map
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        //Check login status, if true it will store user information to shared pref
        if(jsonData['status']==true){

          print("Login success");

          //Save data to shared preference
          if(await save_login_info(response.body) == true) // Login Success and information stored in to shared prefernce
          {
            print("Saving data to shared preference");
            print("Got Login values");
            print(response.body);


            // Show login success toast
            Fluttertoast.showToast(
              msg: "loginsuccessful".tr(),
              toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
              gravity: ToastGravity.BOTTOM,    // TOP, CENTER, BOTTOM
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            return true;
          }
        }

        // print("✅ Login successful");
        // print("Token: ${data['token']}");
        // print("User: ${data['user']}");

        return true;
      } else {

        print("Error from first login attempt");
        print("❌ ${data['message']}");
        return false;
      }
    } else {

      // Decode JSON string into a Map
      Map<String, dynamic> jsonData = jsonDecode(response.body);

      if(jsonData['status']==false){
        Fluttertoast.showToast(
          msg: "invalidemailpassword".tr(),
          toastLength: Toast.LENGTH_LONG, // or Toast.LENGTH_LONG
          gravity: ToastGravity.CENTER,    // TOP, CENTER, BOTTOM
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
      //print("❌ Server error: ${response.statusCode}");
      return false;
    }
  } catch (e) {

    // Server Error
    Fluttertoast.showToast(
      msg: "There is an error in server communication, please try again later",
      toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
      gravity: ToastGravity.BOTTOM,    // TOP, CENTER, BOTTOM
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    print("⚠️ Error: $e");

    return false;
  }
}

// Future<bool> loginUser(String email, String password) async {
//   const String apiUrl = "http://192.168.0.112/sbtmonitor/public/api/login";
//
//   try {
//     final response = await http.get(
//       Uri.parse(apiUrl),
//       headers: {"Accept": "application/json"},
//       body: {"email": email, "password": password},
//     );
//     print("request sent to : " + apiUrl);
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//
//       if (data['status'] == true) {
//         print("login success");
//         if (save_login_info(response.body) == true) {
//           Fluttertoast.showToast(
//             msg: "Login Successful.",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.green,
//             textColor: Colors.white,
//             fontSize: 16.0,
//           );
//           return true;
//         } else {
//           return false; // if info not saved
//         }
//       } else {
//         Fluttertoast.showToast(
//           msg: data['message'] ?? "Login failed",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.CENTER,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.orangeAccent,
//           textColor: Colors.white,
//           fontSize: 16.0,
//         );
//         return false;
//       }
//     } else {
//       return false;
//     }
//   } catch (e) {
//     Fluttertoast.showToast(
//       msg: "Server communication error, please try again later",
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       timeInSecForIosWeb: 1,
//       backgroundColor: Colors.redAccent,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//     print("⚠️ Error: $e");
//     return false;
//   }
// }

Future<bool> save_login_info(String data) async {

  Map<String, dynamic> LoginData = jsonDecode(data);
  //Map<String, dynamic> LoginUserData = jsonDecode(LoginData['user']);
   print("Login data: ${data}");


  try{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("email", LoginData['user']['email']);
    await prefs.setString("name", LoginData['user']['name']);
    await prefs.setString("role", LoginData["role"]);
    await prefs.setBool("loginState",true);
    await prefs.setString("user_data", jsonEncode(LoginData["user"]));
    await prefs.setString("pickupPoint",LoginData['user']['pickup_point']);

    print("Login Data saved ✅");
    //print(LoginData['user']['pickup_point']);

    // final prefs1 = await SharedPreferences.getInstance();
    // String? email = prefs1.getString("email");
    // String? name = prefs1.getString("name");

    return true;
  }catch(e){
    return false;
  }



}
