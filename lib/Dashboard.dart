import 'package:trackora/students/LiveMapScreen.dart';
import 'package:trackora/pages/SliderSwitchExample.dart';
import 'package:trackora/pages/drawer.dart';
import 'package:trackora/profile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'Tracker.dart';
import 'helpers/DialogManager.dart';
import 'helpers/LoaderController.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _index = 2; // center tab selected

  final List<_DashItem> _items =  [
    _DashItem(icon: Icons.person, label: "profile".tr()),
    _DashItem(icon: Icons.location_pin, label: "location".tr()),
    _DashItem(icon: Icons.sos, label: "sos".tr()),
    _DashItem(icon: Icons.chat_bubble, label: "chat".tr()),
    _DashItem(icon: Icons.info, label: "information".tr()),
    _DashItem(icon: Icons.directions_bus_filled, label: "transport".tr()),
  ];

  void _onItemClick(BuildContext context, int id) {
    print("clicked ${id}");
    switch (id) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
      case 1:
       Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => DrawerPage()),
         );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>LiveMapScreen()),
        );
        break;
      case 3:

        DialogManager.showInfoDialog(context, "Info", "This is an info dialog");
       // Navigator.pushNamed(context, '/chat');
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Info Clicked")),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TrackerApp()),
        );
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Curved header
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipPath(
                    clipper: _HeaderClipper(),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF8EA2FF), Color(0xFF7286FF)],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment(0, -0.2),
                      child: Text("dashboard".tr(), style: TextStyle(fontSize: 25, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            // Grid of action tiles
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final padding = constraints.maxWidth * 0.07; // responsive side padding
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(padding, 8, padding, 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      childAspectRatio: 1,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      return _DashTile(
                        item: _items[i],
                        accent: accent,
                        onTap: () {
                          _onItemClick(context,i); // ✅ handle clicks
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),


      // Bottom nav to match the theme
      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: ''),
          NavigationDestination(icon: Icon(Icons.star_border), selectedIcon: Icon(Icons.star), label: ''),
          NavigationDestination(icon: Icon(Icons.dashboard_customize_outlined), selectedIcon: Icon(Icons.dashboard), label: ''),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: ''),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on), label: ''),
        ],
      ),
    );
  }
  
}

// class _DashTile extends StatelessWidget {
//   const _DashTile({required this.item, required this.accent});
//   final _DashItem item;
//   final Color accent;
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(18),
//       clipBehavior: Clip.antiAlias,
//       elevation: 0,
//       child: InkWell(
//         onTap: () {},
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: const Color(0xFFE0E3E8), width: 1.6),
//             borderRadius: BorderRadius.circular(18),
//             boxShadow: const [
//               BoxShadow(
//                 color: Color(0x11000000),
//                 blurRadius: 8,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(item.icon, size: 44, color: accent),
//                 const SizedBox(height: 10),
//                 Text(
//                   item.label,
//                   style: TextStyle(
//                     color: accent,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.2,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _DashTile extends StatelessWidget {
  final _DashItem item;
  final Color accent;
  final VoidCallback? onTap;

  const _DashTile({Key? key, required this.item, required this.accent, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,  // ✅ handle click
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 40, color: accent),
            const SizedBox(height: 8),
            Text(item.label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}


class _DashItem {
  final IconData icon;
  final String label;
  const _DashItem({required this.icon, required this.label});
}

/// Creates a soft curved header similar to the provided theme image.
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final h = size.height;
    final w = size.width;
    final path = Path()
      ..lineTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.5, h * 0.95, w, h * 0.55)
      ..lineTo(w, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
