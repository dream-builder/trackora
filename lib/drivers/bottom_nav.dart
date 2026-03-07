import 'package:flutter/material.dart';

class BottomNavExample extends StatefulWidget {
  const BottomNavExample({super.key});

  @override
  State<BottomNavExample> createState() => _BottomNavExampleState();
}

class _BottomNavExampleState extends State<BottomNavExample> {

  int selectedIndex = 0;

  final List<IconData> navIcons = [
    Icons.chat_bubble_outline,
    Icons.search,
    Icons.access_time,
    Icons.notifications_none,
    Icons.person_outline
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Text(
          "Page ${selectedIndex + 1}",
          style: const TextStyle(fontSize: 26),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: const LinearGradient(
              colors: [
                Color(0xff5B5B73),
                Color(0xff3B3B52),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.3),
                blurRadius: 10,
              )
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navIcons.length, (index) {

              bool isActive = selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 6),
                      height: 4,
                      width: isActive ? 24 : 0,
                      decoration: BoxDecoration(
                        color: const Color(0xff8FA8FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    Icon(
                      navIcons[index],
                      size: 26,
                      color: isActive
                          ? const Color(0xff8FA8FF)
                          : Colors.white70,
                    ),
                  ],
                ),
              );

            }),
          ),
        ),
      ),
    );
  }
}