import 'dart:convert';
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
