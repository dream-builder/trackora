// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Uber-like Map Demo',
//       home: MapScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class MapScreen extends StatefulWidget {
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? _mapController;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//
//   // Replace with your API key
//   final String googleApiKey = "YOUR_API_KEY_HERE";
//
//   // Example points
//   final LatLng startPoint = const LatLng(23.8103, 90.4125); // Dhaka
//   final LatLng endPoint = const LatLng(23.777176, 90.399452); // Motijheel
//
//   @override
//   void initState() {
//     super.initState();
//     _setMarkers();
//     _getRoute();
//   }
//
//   void _setMarkers() {
//     _markers.add(Marker(markerId: const MarkerId("start"), position: startPoint));
//     _markers.add(Marker(markerId: const MarkerId("end"), position: endPoint));
//   }
//
//   Future<void> _getRoute() async {
//     final polylinePoints = PolylinePoints(apiKey: googleApiKey);
//
//     final request = RoutesApiRequest(
//       origin: PointLatLng(startPoint.latitude, startPoint.longitude),
//       destination: PointLatLng(endPoint.latitude, endPoint.longitude),
//       travelMode: TravelMode.driving,
//       responseFieldMask:
//       'routes.polyline.encodedPolyline,routes.distanceMeters,routes.duration',
//     );
//
//     final result = await polylinePoints.getRouteBetweenCoordinatesV2(request: request);
//
//     // if (result.routes.isNotEmpty) {
//     //   final encoded = result.routes.first.overviewPolyline?.encodedPolyline;
//     //
//     //   if (encoded != null) {
//     //     final points = PolylinePoints.decodePolyline(encoded);
//     //     final List<LatLng> polylineCoordinates =
//     //     points.map((p) => LatLng(p.latitude, p.longitude)).toList();
//     //
//     //     setState(() {
//     //       _polylines.add(
//     //         Polyline(
//     //           polylineId: const PolylineId("route"),
//     //           color: Colors.blue,
//     //           width: 5,
//     //           points: polylineCoordinates,
//     //         ),
//     //       );
//     //     });
//     //
//     //     // Move camera to fit route
//     //     LatLngBounds bounds = LatLngBounds(
//     //       southwest: LatLng(
//     //         polylineCoordinates.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
//     //         polylineCoordinates.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
//     //       ),
//     //       northeast: LatLng(
//     //         polylineCoordinates.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
//     //         polylineCoordinates.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
//     //       ),
//     //     );
//     //     _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//     //   }
//     // }
//
//     if (result.routes.isNotEmpty) {
//       // Use the new nested structure
//       final encoded = result.routes.first.overviewPolyline?.encodedPolyline;
//
//       if (encoded != null) {
//         final points = PolylinePoints.decodePolyline(encoded);
//         final List<LatLng> polylineCoordinates =
//         points.map((p) => LatLng(p.latitude, p.longitude)).toList();
//
//         setState(() {
//           _polylines.add(
//             Polyline(
//               polylineId: const PolylineId("route"),
//               color: Colors.blue,
//               width: 5,
//               points: polylineCoordinates,
//             ),
//           );
//         });
//       }
//     }
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: startPoint,
//           zoom: 13,
//         ),
//         markers: _markers,
//         polylines: _polylines,
//         onMapCreated: (controller) => _mapController = controller,
//       ),
//     );
//   }
// }
