import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final Function(String) onSendMessage;
  final TextEditingController _controller = TextEditingController();

  MessageInput({required this.onSendMessage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Type your message...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              final text = _controller.text;
              if (text.isNotEmpty) {
                onSendMessage(text);
                _controller.clear();
              }
            },
          ),
        ),
      ],
    );
  }
}