import 'package:flutter/material.dart';

import 'chauffeur_selection_screen.dart';

class VehicleSelectionScreen extends StatelessWidget {
  const VehicleSelectionScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
  });

  final String pickupLocation;
  final String dropLocation;

  static const Color primary = Color(0xFF173B6D);

  Widget carCard(
    BuildContext context,
    String title,
    String type,
    String price,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: primary.withValues(alpha: .12),
          child: Icon(
            icon,
            color: primary,
            size: 30,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(type),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              price,
              style: const TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChauffeurSelectionScreen(
                pickupLocation: pickupLocation,
                dropLocation: dropLocation,
              ),
            ),
          );
        },
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
          "Select Vehicle",
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          carCard(
            context,
            "Sedan",
            "Honda City • Hyundai Verna",
            "₹699",
            Icons.directions_car,
          ),
          carCard(
            context,
            "SUV",
            "Innova • XUV700",
            "₹999",
            Icons.airport_shuttle,
          ),
          carCard(
            context,
            "Luxury",
            "BMW • Mercedes",
            "₹1999",
            Icons.local_taxi,
          ),
        ],
      ),
    );
  }
}