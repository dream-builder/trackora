import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

Future<Map<String, dynamic>> fetchRouteData(int id) async {
  const String url = "${apiBaseUrl}api/get_route_by_student_id"; // Replace with your API
  final Map<String, String> params = {"id": id.toString()};

  try {
    final uri = Uri.parse(url).replace(queryParameters: params);
    final response = await http.get(uri);

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
