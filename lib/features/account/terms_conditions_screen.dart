import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color primary = Color(0xFF173B6D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Terms & Conditions",
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
Welcome to WE DRIVE.

• Customers must provide accurate booking information.

• Chauffeur bookings are subject to availability.

• Cancellation charges may apply according to the cancellation policy.

• Drivers reserve the right to refuse unsafe or illegal requests.

• WE DRIVE is not responsible for delays caused by traffic, weather, or force majeure.

• Payment must be completed before the trip ends unless Cash payment is selected.

• Misuse of the application may result in account suspension.

Thank you for choosing WE DRIVE.
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