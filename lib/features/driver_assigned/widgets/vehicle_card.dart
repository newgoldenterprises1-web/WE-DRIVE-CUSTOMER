import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  const VehicleCard({
    super.key,
    this.onCall,
    this.onMessage,
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
            child: const Icon(Icons.directions_car, color: Color(0xFF173B6D), size: 30),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Honda City (Sedan)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text("TS09 AB 4587", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}