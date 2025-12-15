import 'dart:async';
import 'dart:convert';
import 'dart:ffi' hide Size;
import 'package:flutter/services.dart';
import 'package:trackora/SingInPage.dart';
import 'package:trackora/config/config.dart';
import 'package:trackora/helpers/exitApp.dart';
import 'package:trackora/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../GoogleMapExample.dart';
import '../Tracker.dart';
import '../helpers/DialogManager.dart';
import '../helpers/FlutterTTS.dart';
import '../helpers/GeoFence.dart';
import '../helpers/ToastHelper.dart';
import '../helpers/getCurrentLocation.dart';
import '../helpers/getDistanceAndTime.dart' hide calculateDistance;
import '../helpers/getLatLngFromAddress.dart';
import '../helpers/getRouteWithWaypoints.dart';
import '../helpers/get_route_info_by_student_id.dart';
import '../helpers/notification_service.dart';
import '../helpers/sharedPref.dart';
import '../helpers/sound_helper.dart';


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
  const _Info({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16,  color: Colors.black87),
          ),
        ),
      ],
    );
  }
}

class LiveMapScreen extends StatefulWidget {
  @override
  _LiveMapScreenState createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  GoogleMapController? _mapController;
  Marker? _marker;
  final Set<Marker> _markers = {};
  LatLng _initialPosition = initialPosition; //From config
  Timer? _timer;
  int _index = 2; // center tab selected

  LatLng? userDefaultPickupLocation;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? routeData;
  String timeLabel = "";
  String _routeName = "Route name";
  String distanceLabel = "";
  String busLabel = "Baishakhi";
  String personLabel = "Mr. XYZ";

  bool _useLiveLocation = false;
  LatLng? _busLocation;
  LatLng? _userLocation;

  BitmapDescriptor? schoolBusIcon;

  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};

  String _busName="";
  String _driverName="";
  String _busRegistrationNumber="";
  String _driverPhone="";

  bool showSidebar = false;

  void toggleSidebar() {
    setState(() {
      showSidebar = !showSidebar;
    });
  }

  /// Load image from assets and convert to BitmapDescriptor
  Future<void> _loadCustomMarker() async {
    schoolBusIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // marker size
      'assets/school_bus.png',
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();


    //get login and user informaiton
    init();

    //Load the routes by student id
    //get_route_by_student_id();

    //_loadCustomMarker();
    // _marker = Marker(
    //   markerId: MarkerId("live_marker"),
    //   position: _initialPosition,
    // );
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

    String apiUrl = "${apiBaseUrl}api/livemaploc";

    final uri = Uri.parse(apiUrl).replace(queryParameters: {
      "user_id": "1",
      "driver_id": "1",
      "bus_id": "1",
      "route_id": "1",
    });

    try {
      // Dummy API (replace with your real API)
      final response = await http.get(uri);

      //Debug
      print("➡️ Sending GET request: $uri");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double lat = data["latitude"];
        double lng = data["longitude"];


        //_getUserDefaultLocation();

        //Get the Distance and time
        _busLocation = LatLng(lat, lng); // Dhaka
        //_userLocation = LatLng(45.4631641, -73.4274669); // start
        //print(response.body);

        // User live location feature is disabled due to requirement
        // _userLiveLocation();

         void fetchData() async {
          final result = await getDistanceAndTime(_busLocation!, _userLocation!);
          print("Distance: ${result['distance']}, Duration: ${result['duration']}");

          setState(() {
            // Update however you like (from API, DB, etc.)
            timeLabel = result['duration'];
            distanceLabel = result['distance'];
            // busLabel = busLabel == "Baishakhi" ? "Shurjo" : "Baishakhi";
            // personLabel = "Mr. Updated ${DateTime.now().second}";
          });
         }


        fetchData();


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

      //Load school bus icon
      _addMarker(newPosition, title: "School Bus", markerId:"school-bus",icon: 4);
      var distance = calculateDistance(newPosition.latitude, newPosition.longitude, _userLocation!.latitude, _userLocation!.longitude) * 1000 ;

      print("BUS distance ${distance}");
      if(distance<200){
       // showToast(message: "Your Bus is reached to you");
        //Notification will appear in status bar
        NotificationService.showStatusBarMessage(
          "Bus Status",
          "Your bus will be reached to your location within 5 minutes!",
        );

        speak("Your bus will be reached to your location within 5 minutes!");
        SoundHelper.playAlertSound();
        // FlutterRingtonePlayer.play(
        //   android: AndroidSounds.notification, // You can use alarm, ringtone, notification
        //   ios: IosSounds.glass,
        //   looping: false, // set to true for looping sound
        //   volume: 1.0, // from 0.0 to 1.0
        //   asAlarm: false, // if true, plays as alarm
        // );
      }
      // _circles.add(
      //   createGeofenceCircle(center: newPosition, radius: 200, id: "School Bus")
      // );

      // _marker = Marker(
      //   markerId: MarkerId("live_marker"),
      //
      //   position: newPosition,
      // );

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

    //disable for temp
    _updateMarker(newPos);
  }

  //Phone Dialer
  Future<void> _launchDialer(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);



    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {

    // Set status bar icon brightness (dark icons)
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarColor: Color(0xFFBB4D05), // OR same as AppBar
    //     statusBarIconBrightness: Brightness.dark, // Android → dark icons
    //     statusBarBrightness: Brightness.light, // iOS
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Image.asset(
            "assets/trackora_logo.png", // your custom icon path
            height: 28,
            width: 28,
          ), // your icon
          const SizedBox(width: 8),
          const Text("Live"),
        ],
      ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: toggleSidebar,
          ),
        ],
      ),
      body:
      Stack(
        children: [
          SafeArea(
              child: Column(
                children: [
                  Expanded(child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14,
                    ),
                    //markers: _marker != null ? {_marker!} : {},
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (controller) => _mapController = controller,
                    circles: _circles,
                  ),
                  ),

                  //const SizedBox(height: 18),

                  Container(
                    color: Colors.deepPurpleAccent,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // keeps row tight around content
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/school_bus.png',
                          width: 32,
                          height: 32,
                        ),

                        SizedBox(width: 8),
                        Text(
                          "The Bus is on the way to pickup",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     children: [
                  //       Text(
                  //         "Enable user location:",
                  //         style: TextStyle(fontSize: 18),
                  //       ),
                  //       SizedBox(width: 10), // spacing between label and switch
                  //       Switch(
                  //         value: _useLiveLocation,
                  //         onChanged: (value) {
                  //           setState(() {
                  //             _useLiveLocation = value;
                  //           });
                  //           //print("Enable user location: ${value ? "ON" : "OFF"}");
                  //         },
                  //       ),
                  //
                  //     ],
                  //   ),
                  //
                  //   decoration: BoxDecoration(
                  //     border: Border(
                  //       bottom: BorderSide(
                  //         color: Colors.grey, // line color
                  //         width: 1.0,        // line thickness
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 10), // spacing between label and switch
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Route: "+ _routeName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey, // line color
                            width: 1.0,        // line thickness
                          ),
                        ),
                      ),
                  ),
                  const SizedBox(height: 26),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children:  [
                        _TwoColRow(
                          left: _Info(icon: Icons.access_time, label: timeLabel, color: Colors.deepPurple),
                          right: _Info(icon: Icons.flag_outlined, label: distanceLabel, color: Colors.deepPurple),
                        ),
                        SizedBox(height: 14),
                        _TwoColRow(
                          left: _Info(icon: Icons.person_outline, label: _driverName, color: Colors.deepPurple,),
                          right: _Info(icon: Icons.call_outlined, label: _driverPhone, color: Colors.deepPurple),

                        ),
                        SizedBox(height: 54),
                        // _TwoColRow(
                        //   left: _Info(icon: Icons.badge_outlined, label: _busRegistrationNumber, color: Colors.deepPurple),
                        //   right: _Info(icon: Icons.directions_bus_filled, label: _busName, color: Colors.deepPurple,),
                        //
                        // ),
                        // _SectionDivider(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Bottom quick actions
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     children: [
                  //       _RoundAction(icon: Icons.phone, label: 'Call', onPressed: () { _launchDialer("1234567890");}), // your dialer function },),
                  //       _RoundAction(icon: Icons.chat_bubble, label: 'Chat', onPressed: () { _launchDialer("1234567890");}),
                  //       _RoundAction(icon: Icons.info_outline, label: 'Info', onPressed: () { _launchDialer("1234567890");}),
                  //     ],
                  //   ),
                  // ),
                ],
              )),
          // Floating sidebar
          if (showSidebar)
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              width: 250,
              child: Material(
                elevation: 8,
                color: Colors.white,
                child: Column(
                  children: [
                    // Sidebar Header
                    Container(
                      height: 120,
                      color: Colors.blue,
                      alignment: Alignment.center,
                      child: const Text(
                        "My Sidebar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    // Sidebar Items (Scrollable)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text("Profile"),
                              onTap: () {},
                            ),
                            ListTile(
                              leading: const Icon(Icons.settings),
                              title: const Text("Settings"),
                              onTap: () {},
                            ),
                            ListTile(
                              leading: const Icon(Icons.logout),
                              title: const Text("Logout"),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignInPage()),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.settings),
                              title: const Text("Exit App"),
                              onTap: () {
                                exitApp();
                              },
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom nav to match the theme
          // // bottomNavigationBar: NavigationBar(
          // //   height: 64,
          // //   selectedIndex: _index,
          // //   onDestinationSelected: (i) => setState(() => _index = i),
          // //   destinations: const [
          // //     NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: ''),
          // //     NavigationDestination(icon: Icon(Icons.star_border), selectedIcon: Icon(Icons.star), label: ''),
          // //     NavigationDestination(icon: Icon(Icons.dashboard_customize_outlined), selectedIcon: Icon(Icons.dashboard), label: ''),
          // //     NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: ''),
          // //     NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: ''),
          // //   ],
          // ),
        ],
      )
    );
  }

   //Get user default pickup location
  void _getUserDefaultLocation() async {
    Map<String, dynamic> data = await loadLoginData();

    print ("catch data ${data}");

    setState(() {
      userData = data['user_data'];

      print("Pickup point test ${userData}");

      Map<String, dynamic> locationJson={};

      print("Location JS ${userData}");

      locationJson = userData!['pickup_point'];

      // double lat = double.parse(locationJson!['latitude'].toString());
      // double lng = double.parse(locationJson!['longitude'].toString());

      //Set user default location getting form the database
      userDefaultPickupLocation = LatLng(locationJson['latitude'], locationJson['longitude']);

      print("Debug - User default location: ${userDefaultPickupLocation}");

      //load user icon
      // if(_useLiveLocation==false){
      //   _addMarker(userDefaultPickupLocation!, title: "Student", markerId: "student",icon: 2);
      //
      //   //Showing GeoFence
      //   _circles.add(
      //     createGeofenceCircle(center: userDefaultPickupLocation!, radius: 300, id: "Student"),
      //   );
      // }


    });
  }

  //Get Current location of android device
  void _userLiveLocation() async {

    if(_useLiveLocation){
      try {
        var location = await getCurrentLocation();
        print("User Live Location");
        print("Latitude: ${location['latitude']}, Longitude: ${location['longitude']}");
        _userLocation = LatLng(location['latitude']!, location['longitude']!);



      } catch (e) {
        print("Error: $e");
      }
    }
    else{
      _userLocation = userDefaultPickupLocation;

    }

    //load user icon
    _addMarker(_userLocation!, title: "Student", markerId: "student",icon: 2);



  }


  //this function will load the routes to MAP
  // Future<void> loadRoute(LatLng start, LatLng end, List<LatLng> waypoints) async {
  //
  //
  //   // LatLng start = LatLng(23.759654273685218, 90.41905309662167);  // Dhaka
  //   // LatLng end = LatLng(23.76333006323084, 90.38534018312988);    // Destination
  //   // List<LatLng> waypoints=[];
  //
  //   //get lat nlg from address
  //   try {
  //     LatLng result = await getLatLngFromAddress(
  //       address: "Gulshan 1,Dhaka",
  //       googleApiKey: googleApiKey,
  //     );
  //
  //     print("Latitude: ${result.latitude}, Longitude: ${result.longitude}");
  //
  //     waypoints.add(LatLng(result.latitude, result.longitude));               // Example waypoint
  //       //LatLng(23.75339969602647, 90.39185962132213),               // Another waypoint
  //
  //
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  //
  //
  //
  //   try {
  //     List<LatLng> route = await getRouteWithWaypoints(
  //       start: start,
  //       end: end,
  //       waypoints:  waypoints,
  //       googleApiKey: googleApiKey ,
  //     );
  //
  //     // Now use this route for Polyline
  //     setState(() {
  //       _polylines.add(Polyline(
  //         polylineId: PolylineId("custom_route"),
  //         color: Colors.purpleAccent,
  //         width: 6,
  //         points: route,
  //       ));
  //     });
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

  Future<void> get_route_by_student_id(int student_id) async {

    LatLng start;  // Dhaka
    LatLng end;    // Destination
    List<LatLng> waypoints=[];

    final result = await fetchRouteData(student_id); // Passing id=1 dynamically
    var routeData = result["data"]["data"][0];

    print("route data: ${routeData}");

    //When got route and return success it will load rout polyline
    if(result["code"]==200){
      final sourceLatLng = jsonDecode(routeData["source_latlng"]);
      final destinationLatLng = jsonDecode(routeData["destination_latlng"]);
      final waypoint = jsonDecode(routeData["route_waypoints"]);

      //_initialPosition = LatLng(sourceLatLng.latitude, sourceLatLng.longitude);
      _routeName = routeData["route_name"];
      _busName = "";
      _driverName=routeData["driver_name"];
      _busRegistrationNumber="";
      _driverPhone=routeData["driver_phone"];

      var pikuppoints= jsonDecode(routeData["pickup_point"]);

      userDefaultPickupLocation = LatLng(pikuppoints[0], pikuppoints[1]);
      _userLocation = userDefaultPickupLocation;
      print("pickup point ${pikuppoints[0]}");

      waypoint.forEach((wp){
        waypoints.add(LatLng((wp["lat"] as num).toDouble(), (wp["lng"] as num).toDouble()));
      });

      print("waypoint");
      print(waypoints);

      start = LatLng((sourceLatLng["latitude"] as num).toDouble(), (sourceLatLng ["longitude"] as num).toDouble());
      end = LatLng((destinationLatLng["latitude"] as num).toDouble(), (destinationLatLng ["longitude"] as num).toDouble());


      print("Source: ${sourceLatLng} Destination: ${destinationLatLng}");

      //waypoints.add(LatLng(23.76333006323084, 90.38534018312988));

      try {
        List<LatLng> route = await getRouteWithWaypoints(
          start: start,
          end: end,
          waypoints:  waypoints,
          googleApiKey: googleApiKey ,
        );

        // Now use this route for Polyline
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("custom_route"),
            color: Colors.purpleAccent,
            width: 6,
            points: route,
          ));

          // load marker on map initialization of route
          //_addMarker(start, title: "Source Location");
          //_addMarker(end, title: "Destination Location");

          //Showing GeoFence
          //Disable on demand
          // _circles.add(
          //   createGeofenceCircle(center: userDefaultPickupLocation!, radius: 300, id: "Student"),
          // );

          _addMarker(userDefaultPickupLocation!, title: routeData['name'], markerId: "student",icon: 2);

        });

      } catch (e) {
        print("Error: $e");
      }
    }
  }

  // ✅ Function to add marker by LatLng
  Future<void> _addMarker(
      LatLng position, {
        String title = "Marker",
        String? markerId, // optional marker ID
        int? icon=1, //optional icon ID 1=Marker, 2= Male student, 3= Female Student, 4= Bus
       }) async {


    final customIcon = await _getCustomIcon(icon as int);

    final marker = Marker(
      markerId: MarkerId(markerId ?? position.toString()),
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: customIcon, //BitmapDescriptor.defaultMarker,
    );

    setState(() {
      _markers.add(marker);
    });
  }

  Future<BitmapDescriptor> _getCustomIcon(int icon) async {

    switch (icon) {
      case 1:
        return BitmapDescriptor.defaultMarker;
        break;

      case 2:
        return await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(24, 24)), // optional size
          'assets/student.png',
        );
        break;

      case 4:
        return await BitmapDescriptor.asset(
          const ImageConfiguration(size: Size(24, 24)), // optional size
          'assets/school_bus.png',
        );
        break;
    }

    return BitmapDescriptor.defaultMarker;


  }

  Future<void> init() async {
    //get login and user informaiton
    Map<String, dynamic> data = await loadLoginData();

    int student_id = data['user_data']['student_id'];

    print ("student id ${student_id}");

    //get student and route detail
    get_route_by_student_id(student_id);

    print("login user data: ${data['user_data']['student_id']}");
  }

}
