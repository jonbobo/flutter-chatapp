import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final DatabaseReference _realtimeDatabase = FirebaseDatabase.instance.ref();

  // Function to get a list of all online users
  Stream<List<Map<String, dynamic>>> getAllOnlineUsersStream() {
    String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return _realtimeDatabase.child('users').onValue.map((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? onlineUsers =
          snapshot.value as Map<dynamic, dynamic>?;

      if (onlineUsers == null) {
        return [];
      }

      List<Map<String, dynamic>> usersList = [];
      onlineUsers.forEach((userId, userData) {
        // Exclude the current user from the stream
        if (userId != currentUserUid) {
          // Log the data for each user
          if (kDebugMode) {
            // print('User data for $userId: $userData');
          }

          usersList.add({
            'userId': userId,
            'username': userData['displayName'] ?? 'Guest',
            'online': userData['online'] == true ? 'true' : 'false',
          });
        }
      });

      // Log the entire list of users
      if (kDebugMode) {
        // print('All online user: $usersList');
      }

      return usersList;
    });
  }

  // Function to create a chat between two users
  Future<String?> createChat(String endUserId) async {
    try {
      // Define the chat ID
      String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
      // Compare user IDs and create a consistent chat ID
      String chatId = currentUserUid.compareTo(endUserId) < 0
            ? '$currentUserUid$endUserId'
          : '$endUserId$currentUserUid';

      // Check if the chat already exists
      DatabaseReference chatRef =
          _realtimeDatabase.child('chats').child(chatId);
      DatabaseEvent chatEvent = await chatRef.once();

      if (chatEvent.snapshot.value != null) {
        return chatId;
      }

      // Create the chat under 'chats' node
      await chatRef.set({});

      // Add participants to the chat
      DatabaseReference participantsRef = chatRef.child('participants');
      await participantsRef.set({
        currentUserUid: true,
        endUserId: true,
      });

      return chatId;
    } catch (e) {
      if (kDebugMode) {
        print("Error creating chat: $e");
      }
      return null;
    }
  }

  // Function to send a message to a chat
  Future<void> sendMessage(String chatId, String message) async {
    try {
      String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      DatabaseReference chatRef =
          _realtimeDatabase.child('chats').child(chatId);
      DatabaseReference messagesRef = chatRef.child('messages');


      // Create a new message
      DatabaseReference newMessageRef = messagesRef.push();
      await newMessageRef.set({
        'senderId': currentUserUid,
        'message': message,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error sending message: $e");
      }
    }
  }

  // Function to get a stream of messages for a chat
  Stream<List<Map<String, dynamic>>> getChatMessagesStream(String chatId) {
    return _realtimeDatabase
        .child('chats')
        .child(chatId)
        .child('messages')
        .onValue
        .map((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? messages =
          snapshot.value as Map<dynamic, dynamic>?;

      if (messages == null) {
        return [];
      }

      List<Map<String, dynamic>> messagesList = [];
      messages.forEach((messageId, messageData) {
        messagesList.add({
          'messageId': messageId,
          'senderId': messageData['senderId'],
          'message': messageData['message'],
          'timestamp': Timestamp.fromMillisecondsSinceEpoch(
            messageData['timestamp']),
        });
      });

      // Sort the messages by timestamp
      messagesList.sort((a, b) {
        return a['timestamp'].compareTo(b['timestamp']);
      });

      // log the entire list of messages
      if (kDebugMode) {
        print('All messages for chat $chatId: $messagesList');
      }

      return messagesList;
    });
  }
}
