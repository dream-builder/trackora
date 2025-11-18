import 'dart:convert';
import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> loadLoginData() async {
  final prefs = await SharedPreferences.getInstance();

  String? email = prefs.getString("email");
  String? name = prefs.getString("name");
  String? token = prefs.getString("token");
  String? pickupLat = prefs.getString("pickupPoint");
  String? role = prefs.getString("role");
  String? user_data = prefs.getString("user_data");
  //print("Shared saved");
  //print(pickupLat);

  print("Saved user data ${user_data}");

  Map<String, dynamic> userData = {};

  // Decode user_data if it's valid JSON
  if (user_data != null && user_data.isNotEmpty) {
    try {
      userData = jsonDecode(user_data);

      // 👇 Handle nested pickup_point JSON string
      if (userData['pickup_point'] != null &&
          userData['pickup_point'] is String) {
        try {
          userData['pickup_point'] = jsonDecode(userData['pickup_point']);
        } catch (e) {
          print("⚠️ pickup_point is not valid JSON: $e");
        }
      }
    } catch (e) {
      print("❌ Invalid user_data JSON: $e");
    }
  }

  return {
    "email": email,
    "name": name,
    "token": token,
    "pickupPoint":pickupLat,
    "role":role,
    "user_data": userData
  };
}

Future<bool> setSharedPref(String key, dynamic value) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    if (value is String) {
      return await prefs.setString(key, value);
    } else if (value is int) {
      return await prefs.setInt(key, value);
    } else if (value is bool) {
      return await prefs.setBool(key, value);
    } else if (value is double) {
      return await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      return await prefs.setStringList(key, value);
    } else {
      // For unsupported types (like Map), convert to JSON string
      return await prefs.setString(key, value.toString());
    }
  } catch (e) {
    print("Error saving SharedPref: $e");
    return false;
  }
}

Future<dynamic> getSharedPref(String key) async{
  try{
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }catch(e){
    return null;
  }
}