import 'dart:io';
import 'package:flutter/services.dart';

void exitApp() {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
  } else if (Platform.isIOS) {
    exit(0); // Not recommended for App Store apps
  }
}
