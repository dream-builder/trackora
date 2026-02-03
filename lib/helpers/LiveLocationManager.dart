import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';

Future<void> setLiveLocation({
  required double lat,
  required double lng,
  required int user_id,
  required double route_id,
  required double speed,
  required double bearing,

}) async {

  const String apiUrl = "${apiBaseUrl}api/location/store"; //API URL was api/saveuserlocation

  final Map<String, dynamic> queryParams = {
    "user_id":user_id.toInt(),
    "route_id": route_id.toInt(),
    "lat": lat.toDouble(),
    "lng": lng.toDouble(),
    "latitude": lat.toDouble(),
    "longitude": lng.toDouble(),
    "speed":speed.toDouble(),
    "bearing":bearing.toDouble(),
    "name": "",
    "date": ""
  };

  // Convert JSON → String
  final String paramString = jsonEncode(queryParams);

  final uri = Uri.parse(apiUrl);
  // final uri = Uri.parse(apiUrl).replace(queryParameters: {
  //   "data": paramString,
  // });

  print("request URL: $uri");

  try {
    final response = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: paramString,
    );

    if (response.statusCode == 200) {
      debugPrint("Live location sent successfully");
      debugPrint("Response: ${response.body}");
    } else {
      debugPrint(
        "Failed: ${response.statusCode} ${response.body}",
      );
    }
  } catch (e) {
    debugPrint("API error: $e");
  }
}