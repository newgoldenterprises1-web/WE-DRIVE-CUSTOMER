import 'package:flutter/material.dart';

class TripDetailsCard extends StatelessWidget {
  const TripDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 14),
              SizedBox(width: 12),
              Expanded(
                child: Text("Banjara Hills, Road No. 12", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Divider(height: 24),
          Row(
            children: [
              Icon(Icons.square, color: Colors.red, size: 14),
              SizedBox(width: 12),
              Expanded(
                child: Text("RGIA Hyderabad Airport, Terminal 1", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}