import 'package:flutter/material.dart';
import 'package:resilientlinkweb/screens/chat_page.dart';
import 'package:resilientlinkweb/services/chat_service.dart';
import 'package:resilientlinkweb/widgets/top_navigation.dart';

class Messages extends StatelessWidget {
  Messages({super.key});

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF0F8FF),
        appBar: const TopNavigation(),
        body: _buildUserList());
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("error");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }

        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                recieverEmail: userData['email'],
                recieverID: userData['uid'],
              ),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(34, 1, 84, 144),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 20),
            Text(userData['email']),
          ],
        ),
      ),
    );
  }
}
