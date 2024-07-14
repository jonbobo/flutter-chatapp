import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String message;
  final DateTime timestamp;
  final bool isSender;

  ChatMessage({
    required this.senderId,
    required this.message,
    required this.timestamp,
    this.isSender = false,
  });

  // Factory method to create ChatMessage from Firestore snapshot
  factory ChatMessage.fromMap(Map<String, dynamic> map, String currentUserId) {
    return ChatMessage(
      senderId: map['senderId'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isSender: map['senderId'] == currentUserId,
    );
  }

  // Convert ChatMessage to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'message': message,
      'timestamp': timestamp,
      'isSender': isSender,
    };
  }
}
