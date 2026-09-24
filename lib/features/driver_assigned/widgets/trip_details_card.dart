import 'package:flutter/material.dart';

class TripDetailsCard extends StatelessWidget {
  const TripDetailsCard({
    super.key,
    required this.pickup,
    required this.drop,
  });

  final String pickup;
  final String drop;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pickup,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.square, color: Colors.red, size: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  drop,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
