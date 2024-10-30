import 'package:flutter/material.dart';
import 'package:resilientlinkweb/screens/chat_page.dart';
import 'package:resilientlinkweb/services/chat_service.dart';
import 'package:resilientlinkweb/widgets/top_navigation.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final ChatService _chatService = ChatService();
  String? _selectedUserEmail;
  String? _selectedUserId;

  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf1f4f4),
      appBar: const TopNavigation(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 150.0, vertical: 20),
            child: Row(
              children: [
                StatefulBuilder(
                  builder: (context, setLocalState) {
                    return Container(
                      width: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(.1, .1),
                            blurRadius: .5,
                            spreadRadius: .2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Chats",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            TextField(
                              onChanged: (value) {
                                // Local state update without rebuilding ChatPage
                                setLocalState(() {
                                  searchText = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "Search Chat",
                                suffixIcon: const Icon(Icons.search),
                                border: const OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF015490),
                                    width: .8,
                                  ),
                                ),
                              ),
                            ),
                            _buildUserList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  width: screenWidth * 0.01,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(.1, .1),
                          blurRadius: .5,
                          spreadRadius: .2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _selectedUserEmail != null
                          ? ChatPage(
                              recieverEmail: _selectedUserEmail!,
                              recieverID: _selectedUserId!,
                            )
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;

        // Automatically select the first user if no user is selected yet
        if (_selectedUserEmail == null && users.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedUserEmail = users[0]['email'];
              _selectedUserId = users[0]['uid'];
            });
          });
        }

        final filteredUsers = users.where((user) {
          final email = user['email'].toString().toLowerCase();
          return email.contains(searchText.toLowerCase());
        }).toList();

        return ListView(
          shrinkWrap: true,
          children: filteredUsers
              .map<Widget>((userData) => _buildUserListItem(userData))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUserEmail = userData['email'];
          _selectedUserId = userData['uid'];
        });
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _selectedUserEmail == userData['email']
                  ? const Color(0xFF015490)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: _selectedUserEmail == userData['email']
                      ? Colors.white
                      : Colors.black,
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Text(
                  userData['email'],
                  style: TextStyle(
                    color: _selectedUserEmail == userData['email']
                        ? Colors.white
                        : Colors.black,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
