import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final String vehicle;
  final String number;

  const VehicleCard({
    super.key,
    this.onCall,
    this.onMessage,
    required this.vehicle,
    required this.number,
  });

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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF173B6D).withValues(alpha: .10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Color(0xFF173B6D),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
