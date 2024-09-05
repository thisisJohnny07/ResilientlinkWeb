import 'package:flutter/material.dart';
import 'package:resilientlinkweb/screens/profile.dart';
import 'package:resilientlinkweb/screens/sidenavigation.dart';
import 'package:resilientlinkweb/services/authentication.dart';
import 'package:resilientlinkweb/widgets/pop_menu.dart';
import 'package:resilientlinkweb/widgets/profile_logout.dart';

class TopNavigation extends StatelessWidget implements PreferredSizeWidget {
  const TopNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SideNavigation()),
                  );
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
              PopMenu(
                text1: "Profile",
                text2: "Logout",
                width: 130,
                icon1: Icons.person,
                icon2: Icons.logout,
                v1: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Profile()),
                  );
                },
                v2: () {
                  AuntServices().signout();
                },
                offset: 40,
                child: const ProfileLogout(),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  // Implement the preferredSize getter for AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(60);
}
