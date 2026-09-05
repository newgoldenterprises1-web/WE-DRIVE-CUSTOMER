import 'package:flutter/material.dart';

class DriverInfoCard extends StatelessWidget {
  const DriverInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFF173B6D),
            child: Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rajesh Kumar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF173B6D)),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFD4AF37), size: 18),
                    SizedBox(width: 4),
                    Text("4.85", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Text("(120+ Trips)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: .15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "OTP: 4587",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF173B6D)),
            ),
          ),
        ],
      ),
    );
  }
}