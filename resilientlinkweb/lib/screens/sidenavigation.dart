import 'package:flutter/material.dart';
import 'package:resilientlinkweb/screens/dashboard.dart';
import 'package:resilientlinkweb/screens/donation.dart';
import 'package:resilientlinkweb/screens/profile.dart';
import 'package:resilientlinkweb/services/authentication.dart';

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
      appBar: AppBar(
        title: const Text('Your Title'),
        backgroundColor: const Color(0xFF015490),
        centerTitle: true,
        leading: SizedBox(
          width: 80, // Constrain the width of the Row
          child: Row(
            children: [
              Image.asset(
                "images/logo.png",
                height: 40, // Adjust the height to fit better
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isDrawerOpen = !_isDrawerOpen;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isDrawerOpen ? 200 : 60,
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: <Widget>[
                              _buildListTile(Icons.home, 'Home', 0),
                              _buildListTile(Icons.settings, 'Settings', 1),
                              _buildListTile(Icons.info, 'About', 2),
                            ],
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.black,
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.black),
                          ),
                          onTap: () {
                            AuntServices().signout();
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

  Widget _buildListTile(IconData icon, String title, int index) {
    final bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(top: 3, left: 8, right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF015490) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.black,
          ),
          title: AnimatedOpacity(
            opacity: _isDrawerOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _isDrawerOpen
                ? Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          onTap: () {
            _onItemTapped(index);
          },
        ),
      ),
    );
  }
}
