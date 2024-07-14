import 'package:flutter/material.dart';
import 'package:myapp/components/chat_message.dart';
import 'package:myapp/themes/theme.dart';

class ChatBox extends StatefulWidget {
  final List<ChatMessage> messages;
  final Map<String, String>? endUser;
  final String? currentUserId;

  const ChatBox({Key? key, required this.messages, this.endUser, this.currentUserId})
      : super(key: key);

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.endUser != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Chatting with: ${widget.endUser!['username']}',
              style: textmd,
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment:
          message.isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isSender ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          message.message,
          style: TextStyle(
            color: message.isSender ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
