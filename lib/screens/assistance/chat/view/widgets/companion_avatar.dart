import 'package:flutter/material.dart';

class CompanionAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
        ),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'Y',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}