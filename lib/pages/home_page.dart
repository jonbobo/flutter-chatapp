import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/components/online_users_list.dart';
import 'package:myapp/components/chat_box.dart';
import 'package:myapp/components/chat_message.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/pages/login_page.dart';
import 'package:myapp/services/chat_service.dart';
import 'package:myapp/pages/profile_page.dart';
import 'dart:html';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<User?> _currentUser;
  Map<String, String>? _endUser;

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  String? _currentChatId;
  late String _currentUserId;

  final List<ChatMessage> _messages = []; // List of ChatMessages
  final _messageController =
      TextEditingController(); // TextEditingController for the TextField

  @override
  void initState() {
    super.initState();
    _currentUser = getCurrentUser();

    // on window unload
    window.onUnload.listen((event) {
      if (_authService.isGuest()) {
        _authService.signOut();
      } else {
        _authService.setOnlineStatus(false);
      }
    });

    if (!_authService.isGuest()) {
      _authService.setOnlineStatus(true);
    }
  }

  void handleChat() async {
    _currentChatId = await _chatService.createChat(_endUser!['userId']!);
    if (kDebugMode) {
      print('Current Chat ID: $_currentChatId');
      print('Current User ID: $_currentUserId');
    }
    if (_currentChatId != null) {
      _chatService.getChatMessagesStream(_currentChatId!).listen((messages) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages
              .map((message) => ChatMessage.fromMap(message, _currentUserId)));
        });
      });
    }
  }

  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  void _updateDisplayName() {
    setState(() {
      _currentUser = getCurrentUser(); // Refresh user data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: _buildAppBarTitle(),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          OnlineUsersList(
            onUserSelected: (user) async {
              // Handle the selected user in the home page
              setState(() {
                _endUser = user;
              });

              handleChat();

              // Add any other logic you need
              if (kDebugMode) {
                print('Selected user in HomePage: $_endUser');
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ChatBox(
                    messages: _messages,
                    endUser: _endUser,
                  ), // Display ChatBox with messages
                ),
                _buildChatInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        const Text('ChatApp', style: TextStyle(color: Colors.white)),
        const Spacer(),
        FutureBuilder<User?>(
          future: _currentUser,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error loading user');
            } else {
              final User? user = snapshot.data;
              final String displayName =
                  user?.displayName ?? 'Guest ${user?.uid.substring(0, 5)}';
              _currentUserId = user?.uid ?? '';
              return Text('Welcome $displayName',
                  style: const TextStyle(color: Colors.white));
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            _authService.signOut();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginPage()));
          },
        ),

        //profile button
        IconButton(
          icon: const Icon(Icons.person_outlined, color: Colors.white),
          onPressed: () {
            print('current user id: $_currentUserId');
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          onProfileUpdated: _updateDisplayName,
                        )));
          },
        ),
      ],
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController, // Assign the controller here
              decoration: const InputDecoration(
                hintText: 'Enter your message...',
                border: OutlineInputBorder(),
              ),
              // Implement sending message functionality
              onSubmitted: (message) {
                _sendMessage(message);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              // Get message from TextField and send
              final message = _messageController.text;
              _sendMessage(message);
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) async {
    if (_currentChatId != null) {
      await _chatService.sendMessage(_currentChatId!, message);
    }
    // Clear the message input field
    _messageController.clear();
  }
}
