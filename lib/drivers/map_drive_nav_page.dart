// map_drive_nav_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:latlong2/latlong.dart' as ll;

class MapDriveNavPage extends StatefulWidget {
  final LatLng destination;

  // destination: you can pass a LatLng of the destination
  const MapDriveNavPage({Key? key, required this.destination}) : super(key: key);

  @override
  State<MapDriveNavPage> createState() => _MapDriveNavPageState();
}

class _MapDriveNavPageState extends State<MapDriveNavPage> {
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(23.8103, 90.4125), // fallback (Dhaka)
    zoom: 14,
  );

  GoogleMapController? _mapController;
  Marker? _originMarker;
  Marker? _destinationMarker;
  Polyline? _routePolyline;
  List<LatLng> _polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSub;

  final FlutterTts _tts = FlutterTts();

  // Replace with your keys
  final String googleMapsKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  final String directionsApiKey = 'YOUR_DIRECTIONS_API_KEY';

  // Directions steps
  List<_NavStep> _navSteps = [];
  int _currentStepIndex = 0;
  bool _isNavigating = false;

  // distance checker
  final _distance = ll.Distance();

  @override
  void initState() {
    super.initState();
    _initPermissionsAndLocation();
    _tts.setSpeechRate(0.9);
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initPermissionsAndLocation() async {
    await Permission.location.request();
    var status = await Permission.location.status;
    if (!status.isGranted) {
      // Permission denied, gracefully handle
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission required')),
      );
      return;
    }

    // Get initial position
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _currentPosition = pos;
    });

    _setOriginMarker(LatLng(pos.latitude, pos.longitude));
    _setDestinationMarker(widget.destination);

    // Move camera to user
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(pos.latitude, pos.longitude), 15.0));

    // Get route
    await _fetchRouteAndSteps(
        LatLng(pos.latitude, pos.longitude), widget.destination);

    // Start listening to position updates (navigation)
    _startLocationStream();
  }

  void _setOriginMarker(LatLng pos) {
    final marker = Marker(
      markerId: const MarkerId('origin'),
      position: pos,
      infoWindow: const InfoWindow(title: 'You'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    setState(() {
      _originMarker = marker;
      _markers.removeWhere((m) => m.markerId.value == 'origin');
      _markers.add(marker);
    });
  }

  void _setDestinationMarker(LatLng pos) {
    final marker = Marker(
      markerId: const MarkerId('destination'),
      position: pos,
      infoWindow: const InfoWindow(title: 'Destination'),
    );
    setState(() {
      _destinationMarker = marker;
      _markers.removeWhere((m) => m.markerId.value == 'destination');
      _markers.add(marker);
    });
  }

  // Fetch route polyline + step-by-step instructions from Google Directions API
  Future<void> _fetchRouteAndSteps(LatLng origin, LatLng dest) async {
    final originStr = '${origin.latitude},${origin.longitude}';
    final destStr = '${dest.latitude},${dest.longitude}';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$originStr&destination=$destStr&key=$directionsApiKey&mode=driving&units=metric';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      debugPrint('Directions API error ${response.statusCode}');
      return;
    }
    final data = json.decode(response.body);
    if (data['status'] != 'OK') {
      debugPrint('Directions status not OK: ${data['status']}');
      return;
    }

    final route = data['routes'][0];
    final overviewPolyline = route['overview_polyline']['points'];

    // decode polyline to coordinates
    final polylinePoints = PolylinePoints(apiKey: '');
    final decoded = PolylinePoints.decodePolyline(overviewPolyline);
    _polylineCoordinates = decoded
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList(growable: false);

    // create polyline
    final polyline = Polyline(
      polylineId: const PolylineId('route_poly'),
      points: _polylineCoordinates,
      width: 6,
      color: const Color(0xFF1E88E5),
    );

    // parse steps (from legs -> steps)
    _navSteps.clear();
    final legs = route['legs'] as List<dynamic>;
    for (final leg in legs) {
      final steps = leg['steps'] as List<dynamic>;
      for (final s in steps) {
        final instr = _stripHtmlIfNeeded(s['html_instructions'] ?? '');
        final startLoc = s['start_location'];
        final lat = startLoc['lat'];
        final lng = startLoc['lng'];
        final distanceText = s['distance']?['text'] ?? '';
        final durationText = s['duration']?['text'] ?? '';
        _navSteps.add(_NavStep(
          instruction: instr,
          position: LatLng(lat, lng),
          distanceText: distanceText,
          durationText: durationText,
        ));
      }
    }

    setState(() {
      _polylines = {polyline};
      _routePolyline = polyline;
    });

    // announce first instruction and mark navigation active
    if (_navSteps.isNotEmpty) {
      _currentStepIndex = 0;
      _announce('Navigation started. ${_navSteps[0].instruction}');
      setState(() {
        _isNavigating = true;
      });
    }
  }

  String _stripHtmlIfNeeded(String html) {
    // very basic strip (Directions returns short html e.g. 'Turn <b>right</b>')
    return html.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '');
  }

  void _startLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // meters
    );

    _positionStreamSub =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
          _currentPosition = position;
          final posLatLng = LatLng(position.latitude, position.longitude);
          _setOriginMarker(posLatLng);

          // move camera following user but keep some freedom
          _mapController?.animateCamera(CameraUpdate.newLatLng(posLatLng));

          if (_isNavigating && _navSteps.isNotEmpty) {
            _checkAndAnnounceNextStep(posLatLng);
          }
        });
  }

  // Compute distance and announce instruction when within threshold
  void _checkAndAnnounceNextStep(LatLng userPos) {
    if (_currentStepIndex >= _navSteps.length) return;

    final nextStep = _navSteps[_currentStepIndex];
    final distMeters = _computeDistanceMeters(userPos, nextStep.position);

    // thresholds:
    // announce main instruction at ~40 m, repeat when closer (~15 m)
    if (distMeters <= 40 && !_navSteps[_currentStepIndex].announced) {
      _announce(nextStep.instruction);
      _navSteps[_currentStepIndex].announced = true;
    } else if (distMeters <= 15 &&
        _navSteps[_currentStepIndex].announced &&
        !_navSteps[_currentStepIndex].arrived) {
      // arrival for that step, move to next
      _announce('Now ${nextStep.instruction}');
      _navSteps[_currentStepIndex].arrived = true;
      _currentStepIndex++;
      if (_currentStepIndex < _navSteps.length) {
        // announce upcoming next step shortly
        final upcoming = _navSteps[_currentStepIndex];
        // optionally announce upcoming in a short delay
      } else {
        // reached end of steps
        _announce('You are near your destination.');
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  double _computeDistanceMeters(LatLng a, LatLng b) {
    // Use latlong2 distance for accuracy (returns meters)
    final p1 = ll.LatLng(a.latitude, a.longitude);
    final p2 = ll.LatLng(b.latitude, b.longitude);
    return _distance.as( ll.LengthUnit.Meter, p1, p2 );
  }

  Future<void> _announce(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController!
          .moveCamera(CameraUpdate.newLatLng(LatLng(_currentPosition!.latitude, _currentPosition!.longitude)));
    }
  }

  // UI controls: re-center, start/stop voice nav
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drive Navigation (demo)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentPosition != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    17.0,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(_isNavigating ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isNavigating = !_isNavigating;
              });
              if (_isNavigating && _navSteps.isNotEmpty) {
                // if resuming, announce current step if not announced
                if (_currentStepIndex < _navSteps.length) {
                  _announce(_navSteps[_currentStepIndex].instruction);
                }
              } else {
                _tts.stop();
              }
            },
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            padding: const EdgeInsets.only(bottom: 120),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: _controlCard(),
          )
        ],
      ),
    );
  }

  Widget _controlCard() {
    final nextText =
    (_currentStepIndex < _navSteps.length) ? _navSteps[_currentStepIndex].instruction : "No upcoming step";
    final etaAndDistance = _routePolyline != null ? '${_polylineCoordinates.length} route points' : '';
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.navigation, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nextText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(etaAndDistance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    if (_currentStepIndex < _navSteps.length) {
                      _announce(_navSteps[_currentStepIndex].instruction);
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Recalculate route from current pos if available
                    if (_currentPosition != null) {
                      _fetchRouteAndSteps(
                          LatLng(_currentPosition!.latitude, _currentPosition!.longitude), widget.destination);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recalculate route'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    _tts.stop();
                    setState(() {
                      _isNavigating = false;
                    });
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _NavStep {
  final String instruction;
  final LatLng position;
  final String distanceText;
  final String durationText;
  bool announced;
  bool arrived;

  _NavStep({
    required this.instruction,
    required this.position,
    required this.distanceText,
    required this.durationText,
    this.announced = false,
    this.arrived = false,
  });
}
