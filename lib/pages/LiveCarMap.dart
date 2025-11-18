import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LiveCarTracking extends StatefulWidget {
  @override
  _LiveCarTrackingState createState() => _LiveCarTrackingState();
}

class _LiveCarTrackingState extends State<LiveCarTracking> {
  Completer<GoogleMapController> _controller = Completer();
  late BitmapDescriptor carIcon;

  LatLng _carPosition = LatLng(23.8103, 90.4125); // Initial (Dhaka)
  double _carBearing = 0; // গাড়ির দিক

  @override
  void initState() {
    super.initState();
    _setCustomCarIcon();
    _startLocationUpdates();
  }

  /// Custom Car Icon সেট করা
  void _setCustomCarIcon() async {

    carIcon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(24, 48)),
      "assets/school_bus_top.png", // আপনার assets-এ car.png রাখতে হবে
    );
  }

  /// লোকেশন আপডেট শুরু করা
  void _startLocationUpdates() {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // 5 মিটার পরপর আপডেট
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      setState(() {
        _carPosition = LatLng(position.latitude, position.longitude);
        _carBearing = position.heading; // দিক পরিবর্তন
      });
      _moveCamera(_carPosition);
    });
  }

  /// ক্যামেরা গাড়ির সাথে মুভ করানো
  Future<void> _moveCamera(LatLng newPos) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newPos,
          zoom: 16,
          bearing: _carBearing, // ক্যামেরাও গাড়ির দিকে ঘুরবে
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Uber Style Car Tracking")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _carPosition,
          zoom: 14,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          Marker(
            markerId: MarkerId("car"),
            position: _carPosition,
            icon: carIcon,
            rotation: _carBearing, // গাড়ি ঘুরবে
            //anchor: Offset(0.5, 0.5), // মাঝখানে marker বসানো
          ),
        },
        myLocationEnabled: true,
        trafficEnabled: true,
      ),
    );
  }
}



// import 'dart:async';
// import 'dart:math' show atan2, cos, pi, sin;
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
//
// class LiveCarTracking extends StatefulWidget {
//   const LiveCarTracking({super.key});
//
//   @override
//   State<LiveCarTracking> createState() => _LiveCarTrackingState();
// }
//
// class _LiveCarTrackingState extends State<LiveCarTracking> {
//   GoogleMapController? _mapController;
//   Marker? _carMarker;
//   LatLng _lastPosition = const LatLng(23.8103, 90.4125); // initial pos
//   double _lastRotation = 0;
//
//   StreamSubscription<Position>? _positionStream;
//
//   @override
//   void initState() {
//     super.initState();
//     _startLocationUpdates();
//   }
//
//   @override
//   void dispose() {
//     _positionStream?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: _lastPosition,
//           zoom: 16,
//         ),
//         markers: _carMarker != null ? {_carMarker!} : {},
//         onMapCreated: (controller) async {
//           _mapController = controller;
//           await _addCarMarker(_lastPosition);
//         },
//       ),
//     );
//   }
//
//   /// Add initial car marker
//   Future<void> _addCarMarker(LatLng position) async {
//     final icon = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(5, 5)),
//       "assets/school_bus.png", // your car icon
//     );
//
//     setState(() {
//       _carMarker = Marker(
//         markerId: const MarkerId("car"),
//         position: position,
//         icon: icon,
//         rotation: _lastRotation,
//         anchor: const Offset(0.5, 0.5),
//         flat: true,
//       );
//     });
//   }
//
//   /// Start listening to device live location
//   void _startLocationUpdates() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       return;
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return;
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return; // user must enable manually
//     }
//
//     _positionStream = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 5, // update every 5 meters
//       ),
//     ).listen((Position position) {
//       LatLng newPos = LatLng(position.latitude, position.longitude);
//       _updateCarLocation(newPos);
//     });
//   }
//
//   /// Update car marker with new location & direction
//   void _updateCarLocation(LatLng newPosition) {
//     final bearing = _getBearing(_lastPosition, newPosition);
//
//     setState(() {
//       _carMarker = _carMarker!.copyWith(
//         positionParam: newPosition,
//         rotationParam: bearing,
//       );
//     });
//
//     _mapController?.animateCamera(
//       CameraUpdate.newLatLng(newPosition),
//     );
//
//     _lastPosition = newPosition;
//     _lastRotation = bearing;
//   }
//
//   /// Calculate direction between two LatLng points
//   double _getBearing(LatLng start, LatLng end) {
//     double lat1 = start.latitude * pi / 180.0;
//     double lon1 = start.longitude * pi / 180.0;
//     double lat2 = end.latitude * pi / 180.0;
//     double lon2 = end.longitude * pi / 180.0;
//
//     double dLon = lon2 - lon1;
//     double y = sin(dLon) * cos(lat2);
//     double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
//
//     double bearing = atan2(y, x) * 180 / pi;
//     return (bearing + 360) % 360;
//   }
// }
