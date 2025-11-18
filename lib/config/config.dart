import 'package:google_maps_flutter/google_maps_flutter.dart';

const String appTitle = "Trackora";
const String apiBaseUrl = "https://demo.trackora.ca/"; //"http://192.168.0.112/sbtmonitor/public/"; // server URL
//const String apiBaseUrl = "http://192.168.197.253/sbtmonitor/public/"; // server URL
const String googleApiKey= "AIzaSyD_h4klMI1w_Jeueab7FBZ3TAQbc2OJPs0"; //API key for google Map
const bool trafficEnabled = false; // When true, Google map will show traffic on road
final LatLng initialPosition = LatLng(23.8103, 90.4125); // Dhaka default
const bool showStartEndMarker = false;
const int timeOut=5; // call every 5 seconds
bool demoMode = true;