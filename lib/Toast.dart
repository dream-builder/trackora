import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  void showToast() {
    Fluttertoast.showToast(
      msg: "This is a Toast message",
      toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
      gravity: ToastGravity.BOTTOM,    // TOP, CENTER, BOTTOM
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flutter Toast Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: showToast,
          child: Text("Show Toast"),
        ),
      ),
    );
  }
}
