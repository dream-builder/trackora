import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

/// Convert an address string to LatLng using Google Geocoding API
Future<LatLng> getLatLngFromAddress({
  required String address,
  required String googleApiKey,
}) async {
  final url =
      "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleApiKey";

  final response = await http.get(Uri.parse(url));
  final data = json.decode(response.body);

  if (data["status"] != "OK" || data["results"].isEmpty) {
    throw Exception("Geocoding failed: ${data["status"]}");
  }

  final location = data["results"][0]["geometry"]["location"];
  double lat = location["lat"];
  double lng = location["lng"];

  return LatLng(lat, lng);
}
