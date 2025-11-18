import 'package:flutter/material.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the SidebarPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SidebarPage()),
            );
          },
          child: const Text("Open Sidebar Page"),
        ),
      ),
    );
  }
}

class SidebarPage extends StatefulWidget {
  const SidebarPage({super.key});

  @override
  State<SidebarPage> createState() => _SidebarPageState();
}

class _SidebarPageState extends State<SidebarPage> {
  bool showSidebar = false;

  void toggleSidebar() {
    setState(() {
      showSidebar = !showSidebar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sidebar Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: toggleSidebar,
          ),
        ],
      ),
      body:
      Stack(
        children: [
          // Main content of this page
          const Center(
            child: Text("This is Sidebar Page Content"),
          ),

          // Floating sidebar
          if (showSidebar)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              width: 250,
              child: Material(
                elevation: 8,
                color: Colors.white,
                child: Column(
                  children: [
                    // Sidebar Header
                    Container(
                      height: 120,
                      color: Colors.blue,
                      alignment: Alignment.center,
                      child: const Text(
                        "My Sidebar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    // Sidebar Items (Scrollable)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text("Profile"),
                              onTap: () {},
                            ),
                            ListTile(
                              leading: const Icon(Icons.settings),
                              title: const Text("Settings"),
                              onTap: () {},
                            ),
                            ListTile(
                              leading: const Icon(Icons.logout),
                              title: const Text("Logout"),
                              onTap: () {},
                            ),
                            // Extra items to test scrolling
                            for (int i = 1; i <= 20; i++)
                              ListTile(
                                leading: const Icon(Icons.star),
                                title: Text("Item $i"),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
