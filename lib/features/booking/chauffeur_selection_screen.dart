import 'package:flutter/material.dart';

import 'booking_summary_screen.dart';

class ChauffeurSelectionScreen extends StatelessWidget {
  const ChauffeurSelectionScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
  });

  final String pickupLocation;
  final String dropLocation;

  static const Color primary = Color(0xFF173B6D);

  Widget driverCard(
    BuildContext context,
    String name,
    String rating,
    String experience,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          radius: 28,
          child: Icon(Icons.person),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "$rating ⭐   •   $experience Experience",
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingSummaryScreen(
                  pickupLocation: pickupLocation,
                  dropLocation: dropLocation,
                ),
              ),
            );
          },
          child: const Text("Select"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Choose Chauffeur",
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          driverCard(
            context,
            "Ahmed Khan",
            "4.9",
            "8 Years",
          ),
          driverCard(
            context,
            "Salman Ali",
            "4.8",
            "6 Years",
          ),
          driverCard(
            context,
            "Imran Sheikh",
            "4.7",
            "10 Years",
          ),
        ],
      ),
    );
  }
}