import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color primary = Color(0xFF173B6D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "About WE DRIVE",
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.local_taxi,
                color: Colors.white,
                size: 50,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "WE DRIVE",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Premium Chauffeur Booking Platform",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "WE DRIVE is a premium chauffeur booking application that allows customers to book professional drivers with a modern, secure and reliable experience.\n\nOur mission is to provide luxury chauffeur services with simple booking, live tracking, transparent pricing and world-class customer support.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.7,
              ),
            ),

            const Spacer(),

            const Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "© 2026 WE DRIVE",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}