import 'package:http/http.dart' as http;

Future<String?> getCsrfToken() async {
  final url = Uri.parse("http://192.168.0.112/sbtmonitor/public/token");

  final response = await http.get(url);

  if (response.statusCode == 204 || response.statusCode == 200) {
    // CSRF token will be stored in cookies (Set-Cookie header)
    String? rawCookie = response.headers['set-cookie'];

    if (rawCookie != null) {
      // Extract the XSRF-TOKEN cookie
      RegExp regExp = RegExp(r"XSRF-TOKEN=([^;]+)");
      var match = regExp.firstMatch(rawCookie);
      if (match != null) {
        return Uri.decodeComponent(match.group(1)!); // decoded token
      }
    }
  }
  return null;
}