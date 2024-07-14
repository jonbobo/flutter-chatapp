import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/themes/theme.dart';
import 'package:myapp/components/online_users_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<User?> currentUser;
  final AuthService _authService = AuthService();

  List<String> onlineUsers = ['User1', 'User2', 'User3']; // Sample online users

  @override
  void initState() {
    super.initState();
    currentUser = getCurrentUser();
  }

  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
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
          // const OnlineUsersList(onUserSelected: (Map<String, String>? selectedUser) { 
            
          //  },),
          Expanded(
            child: Center(
              child: FutureBuilder<User?>(
                future: currentUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading user');
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return FutureBuilder<User?>(
      future: currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error loading user');
        } else {
          final User? user = snapshot.data;
          final String displayName = user?.displayName ?? 'Guest';
          return const Text('Chat App', style: TextStyle(fontSize: 24.0, color: Colors.white));
        }
      },
    );
  }
}
