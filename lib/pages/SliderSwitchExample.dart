import 'package:flutter/material.dart';

class SliderSwitchExample extends StatefulWidget {
  @override
  _SliderSwitchExampleState createState() => _SliderSwitchExampleState();
}

class _SliderSwitchExampleState extends State<SliderSwitchExample> {
  bool _isOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Slider Switch Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: _isOn,
              onChanged: (value) {
                setState(() {
                  _isOn = value;
                });
                print("Switch is now: ${value ? "ON" : "OFF"}");
              },
            ),
            Text(
              _isOn ? "ON" : "OFF",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
