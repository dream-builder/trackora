import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/config.dart';
import '../helpers/getRouteByID.dart';
import '../helpers/getRouteWithWaypoints.dart';
import '../helpers/sharedPref.dart';
import '../provider/AppBarTitleProvider.dart';
import '../provider/PageProvider.dart';

class FieldTripPage extends StatefulWidget {
  const FieldTripPage({super.key});

  @override
  State<FieldTripPage> createState() => _FieldTripPageState();
}

class _FieldTripPageState extends State<FieldTripPage> {

  var routeData;
  List<dynamic> stopPoints = [];
  List<Map<String, String>> passengers = [];


  void initState() {
    // TODO: implement initState
    super.initState();

    // 🔔 Set title when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppBarTitleProvider>().updateTitle("Trip Detail".tr());
    });

    load_bootstrap_data();

  }

  Future<void> get_route(int id) async {

    List<LatLng> waypoints=[];
    String _routeName = "Route name";

    final result = await getRouteByID(id); // Passing id=1 dynamically


    //When got route and return success it will load rout polyline
    if(result["code"]==200){

      setState(() {
        routeData = result["data"]["data"][0];
        //stopPoints=routeData['route_waypoints'];
      });

      print("route data ${routeData}");

      _routeName = routeData["route_name"];

      // final sourceLatLng = jsonDecode(routeData["source_latlng"]);
      // final destinationLatLng = jsonDecode(routeData["destination_latlng"]);
      // final waypoint = jsonDecode(routeData["route_waypoints"]);
      //
      // //print("Source lat: ${sourceLatLng}");
      //
      // waypoint.forEach((wp){
      //   waypoints.add(LatLng((wp["lat"] as num).toDouble(), (wp["lng"] as num).toDouble()));
      // });
      //
      // //print("waypoint");
      // //print(waypoints);




    }
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
  Future<void> get_student(int route_id) async {

    final student = await get_student_by_route_id(route_id);
    final data = student['data'];
    List<Map<String, String>> passenger = [];
    final random = Random();
    data.forEach((d){

      print(d['name']);
      passenger.add(
        {
          "student_id": d['student_id'].toString(),
          "name":d['name']??'',
          "phone":d['phone']??random.nextInt(1837478).toString()
        }
      );
    });



    setState(() {
     passengers=passenger;
    });


    print("passengers : ${passenger}");

  }

  void load_bootstrap_data() async {
    //set route id to shared pref
    final route_id = await getSharedPref("route_id");

    print("Route-id: ${route_id}");
    //Load the routes by student id
    get_route(route_id);

    get_student(route_id);
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    print("phone:${phoneNumber}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _headerCard(),
            const SizedBox(height: 12),
            _routeCard(),
            const SizedBox(height: 12),
            _tripInfoCard(),
            const SizedBox(height: 12),
            _vehicleDetailsCard(),
            const SizedBox(height: 12),
            _passengerDetailsCard(),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _headerCard() {
    return _card(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "(#${routeData?['id']??''}) ${routeData?['route_name']??''}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

            onPressed: (){
            context.read<PageProvider>().changePage(2); //Load Live screen index 2
          },
              child: const Text(
                "Start Travel",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),),

        ],
      ),
    );
  }

  // ---------------- Route ----------------
  Widget _routeCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Route"),
          const SizedBox(height: 12),
          _routeItem(
            color: Colors.green,
            title: "Pickup",
            subtitle: "${routeData?['route_source']??''}",
          ),
        // ✅ Multiple Stops (orange only)
        ...stopPoints.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;

      return _routeItem(
        color: Colors.orange,
        title: "Stop ${index + 1}",
        subtitle: stop,
      );
    }),
          _routeItem(
            color: Colors.red,
            title: "Drop-off",
            subtitle: "${routeData?['route_destination']??''}",
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ---------------- Trip Info ----------------
  Widget _tripInfoCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Trip Information"),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoItem("Pick Up Time", "09:00 AM", Icons.access_time),
              const SizedBox(width: 20),
              _infoItem("Passengers", "${passengers.length}", Icons.people),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Vehicle ----------------
  Widget _vehicleDetailsCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Vehicle Details"),
          const SizedBox(height: 12),
          _keyValue("Model", "Toyota Corolla CROSS"),
          _keyValue("License Plate", "DM-TA1-3787"),
          _keyValue("Vehicle Type", "SUV"),
        ],
      ),
    );
  }

  // ---------------- Passenger ----------------
  Widget _passengerDetailsCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Passenger Details (${passengers.length})"),
          const SizedBox(height: 12),

          ...passengers.asMap().entries.map((entry) {
            final index = entry.key;
            final passenger = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _passengerItem(
                name: passenger['name'] ?? '',
                phone: passenger['phone'] ?? '',
                isLead: index == 0,
              ),
            );
          }),
        ],
      ),
    );
  }


  // ---------------- Reusable Widgets ----------------
  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _routeItem({
    required Color color,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _keyValue(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(key, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _passengerItem({
    required String name,
    required String phone,
    bool isLead = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   // isLead ? "Lead Passenger" : "Passenger",
        //   style: const TextStyle(color: Colors.grey),
        // ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(phone),
              ],
            ),
            CircleAvatar(
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.call, color: Colors.white),
                onPressed: () {
                  // TODO: Call passenger
                  makePhoneCall(phone);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

}
