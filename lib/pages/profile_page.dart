import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/components/online_users_list.dart';
import 'package:myapp/components/chat_box.dart';
import 'package:myapp/components/chat_message.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfilePage({Key? key, this.onProfileUpdated}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;

  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _isLoading = true;
    });

    _user = _auth.currentUser;

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _changeProfileInfo() async {
    _displayNameController.text = _user!.displayName ?? '';
    _emailController.text = _user!.email ?? '';
    _passwordController.text = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Display Name'),
          content: SingleChildScrollView(
            child: Builder(builder: (context) {
              if (_authService.isGuest()) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Display Name:'),
                    TextField(
                      controller: _displayNameController,
                    ),
                    SizedBox(height: 16),
                    Text('New Email:'),
                    TextField(
                      controller: _emailController,
                    ),
                    SizedBox(height: 16),
                    Text('New Password:'),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Display Name:'),
                    TextField(
                      controller: _displayNameController,
                    ),
                  ],
                );
              }
            }),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _updateProfile();
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    try {
      if (_authService.isGuest()) {
        print('Updating email and password');
        await _user!.updateDisplayName(_displayNameController.text);
        _authService.updateGuestProfile(_emailController.text,
            _passwordController.text, _displayNameController.text);
      }
      // await _user!.updateDisplayName(_displayNameController.text);
      if (!_authService.isGuest()) {
        _authService.updateUsername(_displayNameController.text);
      }

      // Reload the user data
      await _user!.reload();

      // Update the _user object with the new display name
      _user = _auth.currentUser;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Display name updated successfully'),
      ));

      // Call the callback function to notify HomePage
      widget.onProfileUpdated?.call(); // <-- Trigger callback
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update display name: $error'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String _buttonText = _authService.isGuest()
        ? 'Convert to Permanent Account'
        : 'Change Display Name';
    // print(_buttonText);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _user != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome, ${_user!.displayName ?? "Guest"}!',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text('Email: ${_user!.email ?? "None"}'),
                      const SizedBox(height: 16),
                      SizedBox(
                        child: ElevatedButton(
                          onPressed: _changeProfileInfo,
                          child: new Text(_buttonText),
                        ),
                      )
                    ],
                  ),
                )
              : Center(
                  child: Text('User not found. Please log in.'),
                ),
    );
  }
}
