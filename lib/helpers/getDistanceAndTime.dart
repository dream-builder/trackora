import 'dart:convert';
import 'dart:math';
import 'package:trackora/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Map<String, dynamic>> getDistanceAndTime(

    LatLng origin, LatLng destination) async {

  final String apiKey = googleApiKey;
  final url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data["routes"].isNotEmpty) {
      final route = data["routes"][0];
      final leg = route["legs"][0];

      final distance = leg["distance"]["text"]; // e.g. "5.6 km"
      final duration = leg["duration"]["text"]; // e.g. "12 mins"

      return {
        "distance": distance,
        "duration": duration,
      };
    }
  }
  return {};
}

double calculateDistance({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const R = 6371000; // Radius of Earth in meters

  double dLat = _degToRad(lat2 - lat1);
  double dLon = _degToRad(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c; // distance in meters
}

double _degToRad(double degree) {
  return degree * pi / 180;
}