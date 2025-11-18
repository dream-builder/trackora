import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapExample extends StatelessWidget {
  final LatLng dhaka = LatLng(23.8103, 90.4125);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Map Example")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: dhaka,
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: MarkerId("dhaka"),
            position: dhaka,
            infoWindow: InfoWindow(title: "Dhaka"),
          ),
        },
        onMapCreated: (GoogleMapController controller) {},
      ),
    );
  }
}

// class GoogleMapExample extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Google Map Demo',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: MapSample(),
//     );
//   }
// }
//
// class MapSample extends StatefulWidget {
//   @override
//   State<MapSample> createState() => MapSampleState();
// }
//
// class MapSampleState extends State<MapSample> {
//   // Controller for Google Map
//   late GoogleMapController mapController;
//
//   // Coordinates of Dhaka
//   final LatLng _dhaka = const LatLng(23.8103, 90.4125);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Google Map - Dhaka")),
//       body: GoogleMap(
//         onMapCreated: (GoogleMapController controller) {
//           mapController = controller;
//         },
//         initialCameraPosition: CameraPosition(
//           target: _dhaka,
//           zoom: 12.0,
//         ),
//         markers: {
//           Marker(
//             markerId: MarkerId("dhaka_marker"),
//             position: _dhaka,
//             infoWindow: InfoWindow(title: "Dhaka, Bangladesh"),
//           ),
//         },
//       ),
//     );
//   }
// }
