import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool granted = await requestLocationPermission();

  runApp(MyApp(permissionGranted: granted));
}

// Permission Function
Future<bool> requestLocationPermission() async {
  var status = await Permission.location.request();

  if (status.isGranted) {
    return true;
  } else if (status.isPermanentlyDenied) {
    await openAppSettings();
  }
  return false;
}

class MyApp extends StatelessWidget {
  final bool permissionGranted;
  const MyApp({super.key, required this.permissionGranted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: permissionGranted ? SafeGoogleMapScreen() : PermissionDeniedScreen(),
    );
  }
}

// Permission Denied Screen
class PermissionDeniedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Location permission is required to use Google Map")),
    );
  }
}

// Safe Google Map Screen
class SafeGoogleMapScreen extends StatefulWidget {
  @override
  _SafeGoogleMapScreenState createState() => _SafeGoogleMapScreenState();
}

class _SafeGoogleMapScreenState extends State<SafeGoogleMapScreen> {
  GoogleMapController? _controller;
  Marker? _marker;
  bool _mapReady = false;
  Timer? _timer;

  static const LatLng _initialPosition = LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();

    // Initialize marker
    _marker = Marker(
      markerId: MarkerId("live_marker"),
      position: _initialPosition,
    );

    // Start timer to update marker every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      if (_mapReady) _fetchAndUpdateMarker();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller = null; // Safe dispose
    super.dispose();
  }

  // API call simulation (replace with your API)
  Future<LatLng> _fetchLocationFromApi() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.0.112/sbtmonitor/public/api/livemaploc"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double lat = data["latitude"];
        double lng = data["longitude"];
        return LatLng(lat, lng);
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
    return _initialPosition;
  }

  // Update marker safely
  Future<void> _updateMarker(LatLng newPosition) async {
    if (!_mapReady || _controller == null) return;

    setState(() {
      _marker = Marker(
        markerId: MarkerId("live_marker"),
        position: newPosition,
      );
    });

    // Move camera to new marker
    _controller?.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  // Combine API call + marker update
  void _fetchAndUpdateMarker() async {
    LatLng newPos = await _fetchLocationFromApi();
    _updateMarker(newPos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Safe Google Map Marker")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 14,
        ),
        markers: _marker != null ? {_marker!} : {},
        onMapCreated: (controller) {
          _controller = controller;
          _mapReady = true;
        },
        myLocationEnabled: true,
        mapType: MapType.normal,
      ),
    );
  }
}


// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
//
// class LiveMapScreen extends StatefulWidget {
//   @override
//   _LiveMapScreenState createState() => _LiveMapScreenState();
// }
//
// class _LiveMapScreenState extends State<LiveMapScreen> {
//   GoogleMapController? _mapController;
//   Marker? _marker;
//   LatLng _initialPosition = LatLng(23.8103, 90.4125); // Dhaka default
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _marker = Marker(
//       markerId: MarkerId("live_marker"),
//       position: _initialPosition,
//     );
//     // Start fetching every 5 seconds
//     _timer = Timer.periodic(Duration(seconds: 5), (timer) {
//       _fetchAndUpdateMarker();
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _mapController?.dispose();
//     super.dispose();
//   }
//
//   // Step 1: Fetch geo location from API
//   Future<LatLng> _fetchLocationFromApi() async {
//     try {
//       // Dummy API (replace with your real API)
//       final response = await http.get(Uri.parse("http://192.168.0.112/sbtmonitor/public/api/livemaploc"));
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         double lat = data["latitude"];
//         double lng = data["longitude"];
//         print(lat);
//         print(lng);
//         return LatLng(lat, lng);
//       } else {
//         throw Exception("Failed to load location");
//       }
//     } catch (e) {
//       print("Error fetching location: $e");
//       return _initialPosition;
//     }
//   }
//
//   // Step 2: Update marker on map
//   Future<void> _updateMarker(LatLng newPosition) async {
//     setState(() {
//       _marker = Marker(
//         markerId: MarkerId("live_marker"),
//         position: newPosition,
//       );
//     });
//
//     // Move camera smoothly to new position
//     _mapController?.animateCamera(
//       CameraUpdate.newLatLng(newPosition),
//     );
//   }
//
//   // Step 3: Combine API call + update marker
//   void _fetchAndUpdateMarker() async {
//     LatLng newPos = await _fetchLocationFromApi();
//     _updateMarker(newPos);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Live Google Map Marker")),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: _initialPosition,
//           zoom: 14,
//         ),
//         markers: _marker != null ? {_marker!} : {},
//         onMapCreated: (controller) => _mapController = controller,
//       ),
//     );
//   }
// }
