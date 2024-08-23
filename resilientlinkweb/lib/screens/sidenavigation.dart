import 'package:flutter/material.dart';
import 'package:resilientlinkweb/screens/dashboard.dart';
import 'package:resilientlinkweb/screens/donation.dart';
import 'package:resilientlinkweb/screens/profile.dart';

class SideNavigation extends StatefulWidget {
  const SideNavigation({super.key});

  @override
  State<SideNavigation> createState() => _SideNavigationState();
}

class _SideNavigationState extends State<SideNavigation> {
  bool _isDrawerOpen = true;
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    Donations(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isDrawerOpen ? 200 : 60,
            child: Drawer(
              child: Column(
                children: <Widget>[
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isDrawerOpen = !_isDrawerOpen;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        ListTile(
                          leading: const Icon(Icons.home),
                          title: _isDrawerOpen ? const Text('Home') : null,
                          onTap: () {
                            _onItemTapped(0);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: _isDrawerOpen ? const Text('Settings') : null,
                          onTap: () {
                            _onItemTapped(1);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: _isDrawerOpen ? const Text('About') : null,
                          onTap: () {
                            _onItemTapped(2);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
