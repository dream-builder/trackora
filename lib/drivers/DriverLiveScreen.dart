import 'dart:async';
import 'dart:convert';
import 'dart:ffi' hide Size;
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:trackora/helpers/ToastHelper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:trackora/config/config.dart';
import '../helpers/GeoFence.dart';
import '../helpers/carDirection.dart';
import '../helpers/getCurrentLocation.dart';
import '../helpers/getDistanceAndTime.dart';
import '../helpers/getRouteByID.dart';
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


class DriverliveScreen extends StatefulWidget {
  @override
  _DriverliveScreenState createState() => _DriverliveScreenState();
}

class NavStep {
  final String instruction;
  final LatLng position;
  bool announced = false;
  bool completed = false;

  NavStep({
    required this.instruction,
    required this.position,
  });
}

class _DriverliveScreenState extends State<DriverliveScreen> {
  GoogleMapController? _mapController;
  Marker? _schoolBusMarker;
  final Set<Marker> _markers = {};
  LatLng _initialPosition = initialPosition; //From config
  LatLng _lastPosition = initialPosition;
  Timer? _timer;
  int _tab = 2; // select navigation item in bottom

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

  List<Map<String, dynamic>> studentList = []; //{"name": "Student A", "status": "Active", "id": 1, "pickup_point":{"latitude":23.9484764, "longitude":90.232546545}},

  bool isEnabledPickup = false;

  bool _isLoading = true;

  double carBearing = 0;
  double _currentZoom = 16.0; // default zoom

  final FlutterTts _tts = FlutterTts();
  List<NavStep> _steps = [];
  int _currentStepIndex = 0;


  /// Load image from assets and convert to BitmapDescriptor
  // Future<void> _loadCustomMarker() async {
  //   schoolBusIcon = await BitmapDescriptor.asset(
  //     const ImageConfiguration(size: Size(48, 48)), // marker size
  //     'assets/school_bus.png',
  //   );
  //   setState(() {});
  // }

  void initTTS() {
    _tts.setLanguage("en-US");
    _tts.setSpeechRate(0.9);
    _tts.setVolume(1.0);
  }

  @override
  void initState() {
    super.initState();

    load_bootstrap_data();
    initTTS();

    //_loadCustomMarker();
    // _marker = Marker(
    //   markerId: MarkerId("live_marker"),
    //   position: _initialPosition,
    // );


    //***************************************
    //TIMER IS DISABLED TEPORARILY FOR TESTING. IN PRODUCTION IT WILL BE UNCOMENTED

    // Start fetching every 5 seconds
    _timer = Timer.periodic(Duration(seconds: timeOut), (timer) {

      if(demoMode){
        _fetchAndUpdateMarkerDemo();
      }else{
        //School bus live location
        _updateSchoolBusPosition();
      }

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

        //_getUserDefaultLocation();

        //Get the Distance and time
        _busLocation = LatLng(lat, lng); // Dhaka
        _userLocation = LatLng(23.76806067045547, 90.41874745709367); // start


        //_userLiveLocation();

        void fetchData() async {
          final result = await getDistanceAndTime(_busLocation!, _userLocation!);
          print("Distance: ${result['distance']}, Duration: ${result['duration']}");

          setState(() {
            // Update however you like (from API, DB, etc.)
            timeLabel = result['duration'];
            distanceLabel = result['distance'];

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

  //Show all the students on the map
  Future<void> showStudentMarker() async {

    setState(() {
      for (var item in studentList) {

        var pickup_point = jsonDecode(item['pickup_point']);
        LatLng pos = LatLng((pickup_point[0] as num).toDouble(), (pickup_point[1]as num).toDouble());

        print ("student pos: ${pickup_point}");
        _addMarker(pos, title: "${item['name']}", markerId:"std${item['student_id']}",icon: 2);

      }
    });


  }

  // Step 2: Update marker on map
  Future<void> _updateSchoolBusMarker(LatLng newPosition) async {
    //final customIcon = await _getCustomIcon(4);

    final bearing = getBearing(_lastPosition, newPosition);

    carBearing = bearing;

    _lastPosition= newPosition;

    // Move camera smoothly to new position
    // _mapController?.animateCamera(
    //   CameraUpdate.newLatLngZoom(newPosition,14.0),
    // );
    // print("Bearing: ${bearing}");

    setState(() {

      _addMarker(newPosition, title: "School Bus", markerId:"school-bus",icon: 4);



      //print("All markers: ${_markers[MarkerId("school-bus")]}");
      //var distance = calculateDistance(newPosition.latitude, newPosition.longitude, _userLocation!.latitude, _userLocation!.longitude) * 1000 ;

      // print("BUS distance ${distance}");
      // if(distance<200){
      //  // showToast(message: "Your Bus is reached to you");
      //   //Notification will appear in status bar
      //   NotificationService.showStatusBarMessage(
      //     "Bus Status",
      //     "Your bus will be reached to your location within 5 minutes!",
      //   );
      //   SoundHelper.playAlertSound();
      //
      // }

    });

    // 🚀 Move camera OUTSIDE setState (required!)
    print("moving camera to $_mapController");

    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newPosition,
          zoom: _currentZoom,
          bearing: carBearing,
          tilt: 0,   // set 0 if map is rotated
        ),
      ),
    );

  }

  Future<void> animateCameraSmoothly({
    required LatLng from,
    required LatLng to,
    required double zoom,
    required double bearing,
    Duration duration = const Duration(seconds: 5),
  }) async {
    final int frames = 60; // smooth frames
    final int totalTicks = frames * duration.inSeconds;

    for (int i = 0; i <= totalTicks; i++) {
      await Future.delayed(
        Duration(milliseconds: (duration.inMilliseconds ~/ totalTicks)),
      );

      final double t = i / totalTicks;

      // Linear interpolation
      final double lat = from.latitude + (to.latitude - from.latitude) * t;
      final double lng = from.longitude + (to.longitude - from.longitude) * t;

      await _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(lat, lng),
            zoom: zoom,
            bearing: bearing,
            tilt: 0,
          ),
        ),
      );
    }
  }


  // Step 3: Combine API call + update marker
  void _fetchAndUpdateMarkerDemo() async {
    LatLng newPos = await getLocationFromApi();

    //Update marker on Map
    _updateSchoolBusMarker(newPos);

  }

  @override
  Widget build(BuildContext context) {

    // Set status bar icon brightness (dark icons)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xFFBB4D05), // OR same as AppBar
        statusBarIconBrightness: Brightness.dark, // Android → dark icons
        statusBarBrightness: Brightness.light, // iOS
      ),
    );
    const String _googleDriveMapStyle = '''
[
  {
    "featureType": "all",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#ffffff" }
    ]
  },
  {
    "featureType": "all",
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#000000" },
      { "lightness": 13 }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.fill",
    "stylers": [
      { "color": "#000000" }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#144b53" },
      { "lightness": 14 },
      { "weight": 1.4 }
    ]
  },
  {
    "featureType": "landscape",
    "elementType": "all",
    "stylers": [
      { "color": "#08304b" }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      { "color": "#0c4152" },
      { "lightness": 5 }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [
      { "color": "#000000" }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#0b434f" },
      { "lightness": 25 }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry.fill",
    "stylers": [
      { "color": "#000000" }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.fill",
    "stylers": [
      { "color": "#000000" }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "all",
    "stylers": [
      { "color": "#146474" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "all",
    "stylers": [
      { "color": "#021019" }
    ]
  }
]
''';

    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          // Image.asset(
          //   "assets/trackora_logo.png", // your custom icon path
          //   height: 28,
          //   width: 28,
          // ), // your icon
          // const SizedBox(width: 8),
          const Text("Driver Live", style: TextStyle(color: Colors.white)),
        ],
      ),
        backgroundColor: Color(0xFFFF6600), // 👈 change color here
        elevation: 0,
      ),
      body: SafeArea(child:

      Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (CameraPosition position) {
              _currentZoom = position.zoom;   // store updated zoom level
            },
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: _currentZoom,
            ),
            //markers: _marker != null ? {_marker!} : {},
            markers: _markers,
            polylines: _polylines,
            //
            // Map styling (NEW API)
           // style: _googleDriveMapStyle,
            circles: _circles,

            trafficEnabled: trafficEnabled,
            // ✅ Show current location (blue dot)
            myLocationEnabled: true,

            // ✅ Enable default "My Location" button
            myLocationButtonEnabled: true,

            // ✅ Enable zoom gestures (pinch, double-tap, etc.)
            zoomGesturesEnabled: true,

            // ✅ Enable zoom controls (little + / - buttons)
            zoomControlsEnabled: true,
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.2,  // শুরুতে 20% স্ক্রিন
            minChildSize: 0.2,      // মিনিমাম 20%
            maxChildSize: 0.8,      // সর্বোচ্চ 80%
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),

                child:
                _isLoading
                    ? const Center(
                  child: CircularProgressIndicator(), // ✅ Loader
                )
                    :ListView.builder(
                  controller: scrollController,
                  itemCount: studentList.length,
                  itemBuilder: (context, index) {
                    if(studentList[index]['status']=='Active'){
                      isEnabledPickup=true;
                    }
                    else{
                      isEnabledPickup=false;
                    }
                    return ListTile(
                      leading: Icon(Icons.account_box),
                      title: Text("${studentList[index]['name']}"),
                      subtitle: Text("Status: ${studentList[index]['status']}"),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF6600) ), //Colors.blueAccent
                        onPressed: isEnabledPickup? () async {
                            //print ("student List ${studentList[index]}");
                            update_student_status(studentList[index]['student_id'], studentList[index]['name'],studentList[index]['status'] );

                            //update status label
                            studentList[index]['status']="check in";

                        }:null,
                        child: Text("Pick-up".tr(),style:TextStyle(color:Colors.white)),
                      ),
                    );
                  },
                ),
              );
            },
          ),


        ],

      )),

      // Bottom nav to match the theme
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: 56, // reduce bottom bar height
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // remove labels
          ),
          child: NavigationBar(
            backgroundColor: Color(0xB2FF6600),
            selectedIndex: _tab,
            onDestinationSelected: (i) {
              setState(() => _tab = i);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.dashboard_customize_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.apps_outlined),
                selectedIcon: Icon(Icons.apps),
                label: '',
              ),
              NavigationDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: '',
              ),
            ],
          ),
        )
    );
  }

  //  //Get user default pickup location
  // void _getUserDefaultLocation() async {
  //   Map<String, dynamic> data = await loadLoginData();
  //   setState(() {
  //     userData = data;
  //
  //     Map<String, dynamic> locationJson = jsonDecode(userData!['pickupPoint']);
  //
  //     //Set user default location getting form the database
  //     userDefaultPickupLocation = LatLng(locationJson!['latitude'], locationJson!['longitude']);
  //
  //     print("Debug - User default location: ${userDefaultPickupLocation}");
  //
  //     //load user icon
  //     if(_useLiveLocation==false){
  //       _addMarker(userDefaultPickupLocation!, title: "Student", markerId: "student",icon: 2);
  //
  //       //Showing GeoFence
  //       _circles.add(
  //         createGeofenceCircle(center: userDefaultPickupLocation!, radius: 300, id: "Student"),
  //       );
  //     }
  //
  //
  //   });
  // }
  //
  // //Get Current location of android device
  // void _userLiveLocation() async {
  //
  //   if(_useLiveLocation){
  //     try {
  //       var location = await getCurrentLocation();
  //       print("User Live Location");
  //       print("Latitude: ${location['latitude']}, Longitude: ${location['longitude']}");
  //       _userLocation = LatLng(location['latitude']!, location['longitude']!);
  //
  //     } catch (e) {
  //       print("Error: $e");
  //     }
  //   }
  //   else{
  //     _userLocation = userDefaultPickupLocation;
  //
  //   }
  //
  //   //load user icon
  //   _addMarker(_userLocation!, title: "Student", markerId: "student",icon: 2);
  //
  // }

  Future<void> get_route(int id) async {

    LatLng start;  // Dhaka
    LatLng end;    // Destination
    List<LatLng> waypoints=[];

    final result = await getRouteByID(id); // Passing id=1 dynamically
    var routeData = result["data"]["data"][0];

    print("route data ${result}");

    //When got route and return success it will load rout polyline
    if(result["code"]==200){

      _routeName = routeData["route_name"];

      final sourceLatLng = jsonDecode(routeData["source_latlng"]);
      final destinationLatLng = jsonDecode(routeData["destination_latlng"]);
      final waypoint = jsonDecode(routeData["route_waypoints"]);

      //print("Source lat: ${sourceLatLng}");

      waypoint.forEach((wp){
        waypoints.add(LatLng((wp["lat"] as num).toDouble(), (wp["lng"] as num).toDouble()));
      });

      //print("waypoint");
      //print(waypoints);

      start = LatLng((sourceLatLng["latitude"] as num).toDouble(), (sourceLatLng ["longitude"] as num).toDouble());
      end = LatLng((destinationLatLng["latitude"] as num).toDouble(), (destinationLatLng ["longitude"] as num).toDouble());

      //print("Source: ${sourceLatLng} Destination: ${destinationLatLng}");

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
            color: Colors.indigo,
            width: 6,
            points: route,
          ));

          // load marker on map initialization of route
          if(showStartEndMarker) {
            _addMarker(start, title: "Source Location");
            _addMarker(end, title: "Destination Location");
          }
          _initialPosition = start; //LatLng( (sourceLatLng["latitude"] as num).toDouble(), (sourceLatLng["longitude"] as num).toDouble());

          //load school bus icon in start location
          _addMarker(_initialPosition!, title: "School Bus", markerId: "school-bus",icon: 4);

          // Move/animate camera to new location
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(_initialPosition),
          );

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
      anchor: const Offset(0.5, 0.5), // center of the icon
      flat: true, // important for rotation
      rotation: carBearing, // heading/direction of the car

    );

    setState(() {
      _markers.add(marker);
      print("car Bearing: ${carBearing}");
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
          const ImageConfiguration(size: Size(48, 48)), // optional size
          'assets/car_top.png',
        );
        break;
    }
    return BitmapDescriptor.defaultMarker;

  }

  Future<Map<String, dynamic>> get_student_by_route_id(int id) async {
    const String url = "${apiBaseUrl}api/get_student_by_route_id"; // Replace with your API
    final Map<String, String> params = {"route_id": id.toString()};


    try {
      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri);
      //print("ROute- ${uri}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          "status": "success",
          "code": 200,
          "error": null,
          "data": data
        };
      } else {
        return {
          "status": "error",
          "code": response.statusCode,
          "error": "Failed to fetch data",
          "data": null
        };
      }
    } catch (e) {
      return {
        "status": "error",
        "code": 500,
        "error": e.toString(),
        "data": null
      };
    }
  }

  //load the students information from server who are registerd in this route
  Future<void> get_student(int route_id) async {

    final student = await get_student_by_route_id(route_id);
    final data = student['data'];

    print("students : ${student['data']}");

    setState(() {
      studentList.clear();

      for (var item in data) {
        print("Items: ${item}");
        studentList.add(Map<String, dynamic>.from(item));
      }

    });
    _isLoading = false; //Hide circular loader
    showStudentMarker();


  }

  void load_bootstrap_data() async {
    //set route id to shared pref
    final route_id = await getSharedPref("route_id");

    print("Route-id: ${route_id}");
    //Load the routes by student id
    get_route(route_id);

    get_student(route_id);
  }

  Future<void> _updateSchoolBusPosition() async {
    try {
      var location = await getCurrentLocation();
      print("School Bus Live Location");
      print("Latitude: ${location['latitude']}, Longitude: ${location['longitude']}");

      //_userLocation = LatLng(location['latitude']!, location['longitude']!);

      //print("School Bus Locaion: ${_userLocation}");

      LatLng newPosition = LatLng((location['latitude'] as num).toDouble(), (location['longitude'] as num).toDouble());

      //_updateSchoolBusMarker(newPosition);

      await animateCameraSmoothly(
        from: _lastPosition,
        to: newPosition,
        zoom: _currentZoom,
        bearing: carBearing,
        duration: const Duration(seconds: 5),
      );

    } catch (e) {
      print("Error: $e");
    }
  }

  //For Demo only
  Future<LatLng> getLocationFromApi() async {

    const String url = "${apiBaseUrl}api/livemaploc"; // Replace with your API
    final Map<String, String> params = {"user_id": "1","driver_id": "1","bus_id": "1","route_id": "1"};
    LatLng latLng = initialPosition;

    try {
      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        latLng = LatLng((data["latitude"] as num).toDouble(), (data["longitude"] as num).toDouble());

        print("Demo Location ${latLng}");

        return latLng;

      } else {

      }
    } catch (e) {
      return latLng;
    }

    return latLng;
  }

  void update_student_status(int student_id,  String student_name, String status) {
    showToast(message: "Pick me up ${student_id}");
  }

}
