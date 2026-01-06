import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:trackora/config/config.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  late GoogleMapController mapController;
  final FlutterTts tts = FlutterTts();

  LatLng currentPos = const LatLng(23.8103, 90.4125);
  LatLng destination = const LatLng(23.7806, 90.4070);

  Set<Polyline> polylines = {};
  List<dynamic> steps = [];

  int currentStepIndex = 0;
  bool spoken50 = false;
  bool spoken20 = false;

  @override
  void initState() {
    super.initState();
    startLocation();
  }

  // ---------------- LOCATION ----------------
  void startLocation() async {
    await Geolocator.requestPermission();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((pos) {
      currentPos = LatLng(pos.latitude, pos.longitude);
      followCamera();
      checkDistanceAndSpeak();
    });

    loadRoute();
  }

  // ---------------- ROUTE ----------------
  Future<void> loadRoute() async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${currentPos.latitude},${currentPos.longitude}"
        "&destination=${destination.latitude},${destination.longitude}"
        "&mode=driving"
        "&key=${googleApiKey}";

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    steps = data['routes'][0]['legs'][0]['steps'];

    print("steps: ${steps}");

    PolylinePoints pp = PolylinePoints(apiKey: googleApiKey);
    List<PointLatLng> points =
    PolylinePoints.decodePolyline(data['routes'][0]['overview_polyline']['points']);

    polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        color: Colors.deepPurple,
        width: 6,
        points: points
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList(),
      ),
    );

    speak(currentInstruction());
    setState(() {});
  }

  // ---------------- VOICE ----------------
  void speak(String text) async {
    await tts.setLanguage("en-US");
    await tts.speak(text);
  }

  // ---------------- DISTANCE BASED VOICE ----------------
  void checkDistanceAndSpeak() {
    if (steps.isEmpty || currentStepIndex >= steps.length) return;

    final step = steps[currentStepIndex];
    final end = step['end_location'];

    final distance = Geolocator.distanceBetween(
      currentPos.latitude,
      currentPos.longitude,
      end['lat'],
      end['lng'],
    );

    if (distance < 50 && !spoken50) {
      speak("In 50 meters, ${currentInstruction()}");
      spoken50 = true;
    }

    if (distance < 20 && !spoken20) {
      speak(currentInstruction());
      spoken20 = true;
    }

    if (distance < 8) {
      currentStepIndex++;
      spoken50 = false;
      spoken20 = false;
    }
  }

  String currentInstruction() {
    return steps[currentStepIndex]['html_instructions']
        .replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // ---------------- CAMERA FOLLOW ----------------
  void followCamera() {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentPos,
          zoom: 18,
          tilt: 60,
          bearing: 45,
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // MAP
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: currentPos, zoom: 16),
            polylines: polylines,
            myLocationEnabled: true,
            onMapCreated: (c) => mapController = c,
          ),

          // TOP TURN CARD
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.arrow_upward, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Go straight",
                          style: TextStyle(
                              color: Colors.white, fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(currentInstruction(),
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),

          // RECENTER
          Positioned(
            bottom: 110,
            left: 16,
            child: FloatingActionButton.extended(
              onPressed: followCamera,
              label: const Text("Re-center"),
              icon: const Icon(Icons.navigation),
            ),
          ),

          // BOTTOM BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: const Text(
                "20 min · 5.9 km",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
