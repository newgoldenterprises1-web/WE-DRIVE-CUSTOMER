import 'package:flutter/material.dart';

class LiveEtaCard extends StatelessWidget {
  final String eta;
  final String distance;

  const LiveEtaCard({super.key, required this.eta, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF173B6D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("ESTIMATED ARRIVAL", style: TextStyle(color: Colors.white60, fontSize: 11)),
              Text(eta, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text("DISTANCE", style: TextStyle(color: Colors.white60, fontSize: 11)),
              Text(distance, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}