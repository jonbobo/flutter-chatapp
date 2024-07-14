import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/themes/theme.dart';
import 'package:myapp/services/chat_service.dart';

class OnlineUsersList extends StatefulWidget {
  final void Function(Map<String, String>? selectedUser) onUserSelected;

  const OnlineUsersList({Key? key, required this.onUserSelected})
      : super(key: key);

  @override
  State<OnlineUsersList> createState() => _OnlineUsersListState();
}

class _OnlineUsersListState extends State<OnlineUsersList> {
  Map<String, String>? selectedUser;
  late ChatService _chatService;
  late Stream<List<Map<String, dynamic>>> _onlineUsersStream;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _onlineUsersStream = _chatService.getAllOnlineUsersStream();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.0,
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Online Users',
              style: textmd,
            ),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _onlineUsersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error loading online users');
              } else {
                List<Map<String, dynamic>> onlineUsers = snapshot.data ?? [];

                // Sort by online status , then alphabetically by username
                onlineUsers.sort((a, b) {
                  if (a['online'] == b['online']) {
                    return a['username'].compareTo(b['username']);
                  } else {
                    return b['online'].compareTo(a['online']);
                  }
                });

                return Expanded(
                  child: ListView.builder(
                    itemCount: onlineUsers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          setState(() {
                            selectedUser =
                                onlineUsers[index].cast<String, String>();
                            widget.onUserSelected(selectedUser);
                          });
                          if (kDebugMode) {
                            print(
                                'Selected user: ${onlineUsers[index]['username']}');
                          }
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Colored dot based on online status
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 8.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: onlineUsers[index]['online'] == 'true'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            Text(
                              onlineUsers[index]['username']!,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: selectedUser != null &&
                                        selectedUser!['userId'] ==
                                            onlineUsers[index]['userId']
                                    ? Colors.blue
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
