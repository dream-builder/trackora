import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/AppBarTitleProvider.dart';

class FieldTripPage extends StatefulWidget {
  const FieldTripPage({super.key});

  @override
  State<FieldTripPage> createState() => _FieldTripPageState();
}

class _FieldTripPageState extends State<FieldTripPage> {
  void initState() {
    // TODO: implement initState
    super.initState();

    // 🔔 Set title when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppBarTitleProvider>().updateTitle("Trip Detail".tr());
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _headerCard(),
            const SizedBox(height: 12),
            _routeCard(),
            const SizedBox(height: 12),
            _tripInfoCard(),
            const SizedBox(height: 12),
            _vehicleDetailsCard(),
            const SizedBox(height: 12),
            _passengerDetailsCard(),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _headerCard() {
    return _card(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "(#598) Field Trip",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Assigned",
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  // ---------------- Route ----------------
  Widget _routeCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Route"),
          const SizedBox(height: 12),
          _routeItem(
            color: Colors.green,
            title: "Pickup",
            subtitle: "Jamuna Amusement Park, Pragati Sarani, Dhaka",
          ),
          _routeItem(
            color: Colors.orange,
            title: "Stop 1",
            subtitle: "Bashundhara City Shopping Complex",
          ),
          _routeItem(
            color: Colors.red,
            title: "Drop-off",
            subtitle: "Gulshan Badda Link Road, Gulshan 1, Dhaka",
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ---------------- Trip Info ----------------
  Widget _tripInfoCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Trip Information"),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoItem("Pick Up Time", "09:00 AM", Icons.access_time),
              const SizedBox(width: 20),
              _infoItem("Passengers", "4", Icons.people),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Vehicle ----------------
  Widget _vehicleDetailsCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Vehicle Details"),
          const SizedBox(height: 12),
          _keyValue("Model", "Toyota Corolla CROSS"),
          _keyValue("License Plate", "DM-TA1-3787"),
          _keyValue("Vehicle Type", "SUV"),
        ],
      ),
    );
  }

  // ---------------- Passenger ----------------
  Widget _passengerDetailsCard() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title("Passenger Details (4)"),
          const SizedBox(height: 12),
          const Text(
            "Lead Passenger",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Shohail Bin Saifullah",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text("+880 1712-344678"),
                ],
              ),
              CircleAvatar(
                backgroundColor: Colors.red,
                child: IconButton(
                  icon: const Icon(Icons.call, color: Colors.white),
                  onPressed: () {
                    // TODO: Call action
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Reusable Widgets ----------------
  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _routeItem({
    required Color color,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _keyValue(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(key, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
