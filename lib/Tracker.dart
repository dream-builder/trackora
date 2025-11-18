import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class TrackerApp extends StatefulWidget {


  @override
  _TrackerApp createState() => _TrackerApp();
}

class _TrackerApp extends State<TrackerApp> {
  //const TrackerApp({super.key});

  GoogleMapController? _mapController;
  Marker? _marker;
  LatLng _initialPosition = LatLng(23.8103, 90.4125); // Dhaka default
  Timer? _timer;

  static  Color header = Color(0xFF8EA2FF);
  static  Color header2 = Color(0xFF7286FF);
  static  Color canvas = Color(0xFFF2F3F5);
  static  Color accent = Color(0xFFFF5C9A);

  @override
  void initState() {
    super.initState();
    _marker = Marker(
      markerId: MarkerId("live_marker"),
      position: _initialPosition,
    );
    // Start fetching every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchAndUpdateMarker();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // Step 1: Fetch geo location from API
  Future<LatLng> _fetchLocationFromApi() async {

    final uri = Uri.http(
      "192.168.0.112", // host
      "/sbtmonitor/public/api/livemaploc", // path
      {
        "user_id": "1",
        "driver_id": "1",
        "bus_id": "1",
        "route_id": "1",
      }, // query parameters
    );

    try {
      // Dummy API (replace with your real API)
      final response = await http.get(uri);
      //Debug
      print("➡️ Sending GET request: $uri");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double lat = data["latitude"];
        double lng = data["longitude"];
        return LatLng(lat, lng);
      } else {
        throw Exception("Failed to load location");
      }
    } catch (e) {
      print("Error fetching location: $e");
      return _initialPosition;
    }
  }

  // Step 2: Update marker on map
  Future<void> _updateMarker(LatLng newPosition) async {
    setState(() {
      _marker = Marker(
        markerId: MarkerId("live_marker"),
        position: newPosition,
      );
    });

    // Move camera smoothly to new position
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(newPosition),
    );
  }

  // Step 3: Combine API call + update marker
  void _fetchAndUpdateMarker() async {
    LatLng newPos = await _fetchLocationFromApi();
    _updateMarker(newPos);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Live Tracking Theme',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: header2,
          primary: header2,
          secondary: accent,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          bodyMedium: TextStyle(fontSize: 15, height: 1.35),
        ),
      ),
      home: const TrackingScreen(),
    );
  }
}

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _tab = 1;

  get _marker => null;

  set _mapController(GoogleMapController _mapController) {}
 // get _mapController => null;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Curved header with title
              Stack(
                children: [
                  SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: ClipPath(
                      clipper: _HeaderClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF8EA2FF),Color(0xFF7286FF)],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment(0, -0.35),
                      child: Text('Live Tracking', style: theme.textTheme.titleLarge),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Expanded(

                    child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                    target: LatLng(23.8103, 90.4125), //_initialPosition,
                              zoom: 14,
                            ),
                            markers: _marker != null ? {_marker!} : {},
                            onMapCreated: (controller) => _mapController = controller,
                          ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.grey.shade200,
                    child: Text("Other content below the map"),
                  ),


                ],
              ),


              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16),
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(18),
              //     child: Stack(
              //       children: [
              //         Container(
              //           height: 240,
              //           width: double.infinity,
              //           decoration: const BoxDecoration(color: Colors.white),
              //
              //           // child: Stack(children: [
              //           //   // Replace with your own asset if desired
              //           //   Positioned.fill(
              //           //     child: Container(
              //           //       decoration: BoxDecoration(
              //           //         gradient: LinearGradient(
              //           //           begin: Alignment.topLeft,
              //           //           end: Alignment.bottomRight,
              //           //           colors: [Colors.white, Colors.blue.shade50],
              //           //         ),
              //           //       ),
              //           //       child: const Center(
              //           //         child: Icon(Icons.map, size: 72, color: Colors.black26),
              //           //       ),
              //           //     ),
              //           //   ),
              //           //   // A few playful mock markers
              //           //   Positioned(
              //           //     right: 36,
              //           //     top: 72,
              //           //     child: _Marker(
              //           //       icon: Icons.directions_bus_filled,
              //           //       color: Colors.amber.shade700,
              //           //     ),
              //           //   ),
              //           //   const Positioned(
              //           //     left: 28,
              //           //     top: 18,
              //           //     child: _LetterBadge(letter: 'C'),
              //           //   ),
              //           //   const Positioned(
              //           //     left: 120,
              //           //     bottom: 24,
              //           //     child: _LetterBadge(letter: 'B'),
              //           //   ),
              //           //   const Positioned(
              //           //     right: 18,
              //           //     top: 18,
              //           //     child: _LetterBadge(letter: 'A'),
              //           //   ),
              //           // ]),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              const SizedBox(height: 18),

              Text('The Bus is on the way to pickup',
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w600)),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: const [
                    _TwoColRow(
                      left: _Info(icon: Icons.access_time, label: '10.30 min'),
                      right: _Info(icon: Icons.flag_outlined, label: '1.4 KM'),
                    ),
                    SizedBox(height: 14),
                    _TwoColRow(
                      left: _Info(icon: Icons.directions_bus_filled, label: 'Baishakhi'),
                      right: _Info(icon: Icons.person_outline, label: 'Mr. XYZ'),
                    ),
                    SizedBox(height: 14),
                    _TwoColRow(
                      left: _Info(icon: Icons.badge_outlined, label: 'ABCD 123456'),
                      right: _Info(icon: Icons.call_outlined, label: '+880 1754 729 107'),
                    ),
                    _SectionDivider(),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Bottom quick actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _RoundAction(icon: Icons.phone, label: 'Call'),
                    _RoundAction(icon: Icons.chat_bubble, label: 'Chat'),
                    _RoundAction(icon: Icons.info_outline, label: 'Info'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: ''),
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: ''),
          NavigationDestination(icon: Icon(Icons.dashboard_customize_outlined), selectedIcon: Icon(Icons.dashboard), label: ''),
          NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: ''),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: ''),
        ],
      ),
    );
  }
}

class _TwoColRow extends StatelessWidget {
  const _TwoColRow({required this.left, required this.right});
  final Widget left;
  final Widget right;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 26),
        Expanded(child: right),
      ],
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      height: 2,
      width: double.infinity,
      color: Colors.blueAccent //TrackerApp.header2.withOpacity(0.9),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD9DCE3), width: 1.6),
            boxShadow: const [
              BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(icon, size: 26, color: Color(0x11000000)), //color: TrackerApp.accent),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.icon, required this.color});
  final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Icon(icon, size: 24, color: color),
    );
  }
}

class _LetterBadge extends StatelessWidget {
  const _LetterBadge({required this.letter});
  final String letter;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD6DAE3)),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width; final h = size.height;
    return Path()
      ..lineTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.5, h * 1.05, w, h * 0.6)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
