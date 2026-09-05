import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color primary = Color(0xFF173B6D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            '''
WE DRIVE values your privacy.

• Your personal information is stored securely.

• Your live location is only used during active bookings.

• Payment information is processed securely.

• We never sell your personal information.

• Your booking history remains private.

• You can request account deletion anytime from Settings.

Version 1.0
''',
            style: TextStyle(
              fontSize: 16,
              height: 1.7,
            ),
          ),
        ),
      ),
    );
  }
}