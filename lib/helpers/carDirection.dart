import 'dart:math' show pi, sin, cos, atan2;
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Calculate the bearing (direction) between two LatLng points
double getBearing(LatLng start, LatLng end) {
  double lat1 = start.latitude * (pi / 180);
  double lon1 = start.longitude * (pi / 180);
  double lat2 = end.latitude * (pi / 180);
  double lon2 = end.longitude * (pi / 180);

  double dLon = lon2 - lon1;

  double y = sin(dLon) * cos(lat2);
  double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
  double brng = atan2(y, x);

  return (brng * 180 / pi + 360) % 360; // convert to degrees
}

/// Update the moving car/bus marker on Google Map
Marker updateMovingMarker({
  required Marker oldMarker,
  required LatLng newPosition,
}) {
  // Calculate bearing between old and new position
  double bearing = getBearing(oldMarker.position, newPosition);

  // Return updated marker
  return oldMarker.copyWith(
    positionParam: newPosition,
    rotationParam: bearing,
    anchorParam: const Offset(0.5, 0.5), // center of icon
    flatParam: true,
  );
}

// /// Update car marker with new location & direction
// void _updateCarLocation(LatLng newPosition, LatLng lastPosition) {
//   final bearing = getBearing(lastPosition, newPosition);
//
//   setState(() {
//     _carMarker = _carMarker!.copyWith(
//       positionParam: newPosition,
//       rotationParam: bearing,
//     );
//   });
//
//   _mapController?.animateCamera(
//     CameraUpdate.newLatLng(newPosition),
//   );
//
//   _lastPosition = newPosition;
//   _lastRotation = bearing;
// }