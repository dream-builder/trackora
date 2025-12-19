import '../helpers/sharedPref.dart';

late Map<String, dynamic> studentProfile;

Future<void> init() async {
  studentProfile = await loadLoginData();

}