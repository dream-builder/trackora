
import 'package:flutter/material.dart';

import 'Dashboard.dart';
import 'helpers/sharedPref.dart';



class SafeGoApp extends StatelessWidget {
  const SafeGoApp({super.key});

  static const Color header = Color(0xFF7587FF);
  static const Color header2 = Color(0xFF8EA2FF);
  static const Color accent = Color(0xFF1B1B1B);
  static const Color canvas = Color(0xFFF2F3F5);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile Theme',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: header,
          primary: header,
          secondary: header2,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          bodyMedium: TextStyle(fontSize: 14, height: 1.35),
        ),
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _tab = 2;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    checkLoginData();
  }


  void checkLoginData() async {
    Map<String, dynamic> data = await loadLoginData();
    setState(() {
      userData = data;

      //print("Saved Shared Preference");
      //print (userData);
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);



    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with curve and name
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: ClipPath(
                      clipper: _HeaderClipper(),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [SafeGoApp.header2, SafeGoApp.header],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 20,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(userData!['name'], style: theme.textTheme.titleLarge?.copyWith(color: Colors.black)),
                    ),
                  ),
                  // Avatar floating
                  Positioned(
                    bottom: -44,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 44,
                          backgroundColor: Color(0xFFF4F5F7),
                          child: Icon(Icons.person, size: 56, color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    Row(
                      children:  [
                        Expanded(child: _InfoItem(label: 'Institute', value: userData!['pickupPoint'])),
                        SizedBox(width: 26),
                        Expanded(child: _InfoItem(label: 'Class', value: '12 Grade')),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: const [
                        Expanded(child: _InfoItem(label: 'ID', value: 'ABCD 123456')),
                        SizedBox(width: 26),
                        Expanded(child: _InfoItem(label: 'BUS NAME', value: 'Baishakhi')),
                      ],
                    ),
                    const _SectionDivider(),
                    Row(
                      children: const [
                        Expanded(child: _InfoItem(label: 'Guardina', value: 'Name of the Guardina')),
                        SizedBox(width: 26),
                        Expanded(child: _InfoItem(label: 'Contact', value: '+880 1745 729 107')),
                      ],
                    ),
                    const SizedBox(height: 18),
                     _InfoItem(label: 'E-mail', value: userData!['email']),
                    const _SectionDivider(),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16, height: 1.45),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) {
          setState(() => _tab = i);
          _onBottomNavClick(context, i);  // ✅ handle click here
        },
        height: 64,   // ✅ handle click here
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: ''),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: ''),
          NavigationDestination(icon: Icon(Icons.dashboard_customize_outlined), selectedIcon: Icon(Icons.dashboard), label: ''),
          NavigationDestination(icon: Icon(Icons.apps_outlined), selectedIcon: Icon(Icons.apps), label: ''),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: ''),
        ],
      ),
    );
  }

  _onBottomNavClick(BuildContext context, i) {
    switch (i) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 3:
        Navigator.pushNamed(context, '/apps');
        break;
      case 4:
        Navigator.pushNamed(context, '/location');
        break;
    }
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 0.4,
            color: Color(0xFF7B7D86),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      height: 2,
      width: double.infinity,
      color: SafeGoApp.header.withOpacity(0.7),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width; final h = size.height;
    final p = Path()
      ..lineTo(0, h * 0.6)
      ..quadraticBezierTo(w * 0.5, h * 1.05, w, h * 0.55)
      ..lineTo(w, 0)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
