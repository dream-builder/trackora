import 'package:flutter/material.dart';

class AppBarTitleProvider extends ChangeNotifier {
  String _title = "Trackora";

  String get title => _title;

  void updateTitle(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }
}
