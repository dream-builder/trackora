import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

/// Fetches directions from Google Directions API
/// [start] = LatLng of starting point
/// [end] = LatLng of destination
/// [waypoints] = List of LatLng as intermediate points
/// Returns a list of LatLng that can be used for Polyline
Future<List<LatLng>> getRouteWithWaypoints({
  required LatLng start,
  required LatLng end,
  required List<LatLng> waypoints,
  required String googleApiKey,
}) async {
  final polylinePoints = PolylinePoints(apiKey: googleApiKey);

  // Build waypoints string for API
  String waypointsString = "";
  if (waypoints.isNotEmpty) {
    waypointsString = "&waypoints=" +
        waypoints.map((e) => "${e.latitude},${e.longitude}").join("|");
  }

  final url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}$waypointsString&key=$googleApiKey";

  print("googel route: ${url}");

  final response = await http.get(Uri.parse(url));
  final data = json.decode(response.body);

  if (data["status"] != "OK" || data["routes"].isEmpty) {
    throw Exception("Directions API failed: ${data["status"]}");
  }

  String encodedPolyline = data["routes"][0]["overview_polyline"]["points"];
  List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);

  return decodedPoints.map((e) => LatLng(e.latitude, e.longitude)).toList();
}
