import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

/// Function to calculate the distance between two LatLng points
/// Returns distance in kilometers (you can convert to meters if needed)
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371; // Earth's radius in km

  // Convert degrees to radians
  double dLat = _degToRad(lat2 - lat1);
  double dLon = _degToRad(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c; // in kilometers
}

double _degToRad(double deg) {
  return deg * pi / 180;
}

/// Function that generates a Circle for a geofence area
Circle createGeofenceCircle({
  required LatLng center,
  double radius = 1000, // in meters (default: 1km)
  String id = "geofence",
  Color strokeColor = Colors.red,
  Color fillColor = Colors.redAccent,
}) {
  return Circle(
    circleId: CircleId(id),
    center: center,
    radius: radius,
    strokeColor: strokeColor,
    strokeWidth: 2,
    fillColor: fillColor.withOpacity(0.2),
  );
}



