import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resilientlinkweb/screens/advisory.dart';
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

  static final List<Widget> _pages = <Widget>[
    Advisory(),
    const Donations(),
    Advisory(),
    const Donations(),
    const Profile(),
    const HomePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String email = user?.email ?? 'No email found';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0; // Navigate to the HomePage
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Image.asset(
                      "images/logo.png",
                      width: 130,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(width: 55),
                IconButton(
                  icon: const Icon(Icons.menu, color: Color(0xFF015490)),
                  onPressed: () {
                    setState(() {
                      _isDrawerOpen = !_isDrawerOpen;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.mail, color: Color(0xFF015490)),
                  onPressed: () {},
                ),
                const SizedBox(width: 15),
                Container(
                  width: 1,
                  height: 35,
                  color: const Color.fromARGB(255, 58, 58, 58),
                ),
                const SizedBox(width: 15),
                PopupMenuTheme(
                  data: const PopupMenuThemeData(
                    color: Colors.white,
                  ),
                  child: PopupMenuButton<int>(
                    tooltip: '',
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<int>>[
                        const PopupMenuItem<int>(
                          value: 1,
                          child: SizedBox(
                            width: 130,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Color(0xFF015490),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text('Profile'),
                              ],
                            ),
                          ),
                        ),
                        const PopupMenuItem<int>(
                          value: 2,
                          child: SizedBox(
                            width: 130,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Color(0xFF015490),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    offset: const Offset(0, 40),
                    onSelected: (int result) {
                      if (result == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Profile()),
                        );
                      } else if (result == 2) {
                        AuntServices().signout();
                      }
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: ClipOval(
                            child: Image.network(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTszA7eMyFT_3WLcS-q04bOYoPBzyRtMNzx5g&s",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Row(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isDrawerOpen ? 220 : 72,
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
                              const SizedBox(height: 15),
                              _buildListTile(Icons.dashboard, 'Dashboard', 0),
                              const Divider(),
                              _buildListTile(
                                  Icons.volunteer_activism, 'Donations', 1),
                              _buildListTile(Icons.campaign, 'Advisories', 2),
                              _buildListTile(Icons.how_to_reg, 'Members', 3),
                              _buildListTile(
                                  Icons.insert_chart, 'Statistics', 4),
                              _buildListTile(Icons.feedback, 'Feedbacks', 5),
                            ],
                          ),
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
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: SizedBox(
        height: 40,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF015490) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              Future.delayed(const Duration(milliseconds: 10), () {
                setState(() {});
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Colors.white : const Color(0xFF015490),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _isDrawerOpen ? 1.0 : 0.0,
                      duration: _isDrawerOpen
                          ? const Duration(milliseconds: 600)
                          : const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black.withOpacity(0.7),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
