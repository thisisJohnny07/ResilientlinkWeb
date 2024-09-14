import 'dart:async'; // Import Timer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resilientlinkweb/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String recieverID;

  ChatPage({
    super.key,
    required this.recieverEmail,
    required this.recieverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Add logic if you need to track scrolling for any reason
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.recieverID,
        _messageController.text,
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 1,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.1),
        title: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 10),
            Text(
              widget.recieverEmail,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _auth.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.recieverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _auth.currentUser!.uid;

    DateTime timestamp = data['timestamp'].toDate();
    DateTime now = DateTime.now();

    bool isToday = timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;

    String formattedTimestamp = isToday
        ? DateFormat('h:mm a').format(timestamp)
        : DateFormat('EEEE h:mm a').format(timestamp);

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            alignment: alignment,
            child: Container(
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? const Color(0xFF015490)
                    : Colors.grey.shade500,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8.0),
              margin: isCurrentUser
                  ? const EdgeInsets.only(left: 100)
                  : const EdgeInsets.only(right: 100),
              child: Text(
                data['message'],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            formattedTimestamp,
            style: TextStyle(
              color: Colors.black.withOpacity(.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter your message',
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF015490),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 35,
                    height: 35,
                    child: IconButton(
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          sendMessage();
                        }
                      },
                      icon: Transform.rotate(
                        angle: -3.14 / 4,
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                      iconSize: 15,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.expand(),
                      disabledColor: Colors.grey,
                    ),
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onChanged: (text) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
