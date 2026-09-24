import 'package:flutter/material.dart';

class DriverInfoCard extends StatelessWidget {
  const DriverInfoCard({
    super.key,
    required this.name,
    required this.rating,
    required this.trips,
    required this.otp,
    required this.verified,
  });

  final String name;
  final String rating;
  final String trips;
  final String otp;
  final bool verified;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173B6D),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFD4AF37), size: 18),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(
                      trips + ' Trips',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (verified) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.green, size: 16),
                    ],
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
            child: Text(
              'OTP: ' + otp,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF173B6D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
