import 'package:flutter/cupertino.dart';

class PageProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changePage(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}