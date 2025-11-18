import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({
  required String message,
  Toast toastLength = Toast.LENGTH_SHORT,
  ToastGravity gravity = ToastGravity.BOTTOM,
  int timeInSecForIosWeb = 1,
  Color backgroundColor = Colors.orangeAccent,
  Color textColor = Colors.white,
  double fontSize = 16.0,
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: toastLength,
    gravity: gravity,
    timeInSecForIosWeb: timeInSecForIosWeb,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: fontSize,
  );
}
