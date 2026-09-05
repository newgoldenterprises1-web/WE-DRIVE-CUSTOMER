import 'package:flutter/material.dart';

class TripSummaryCard extends StatelessWidget {
  const TripSummaryCard({
    super.key,
    required this.pickup,
    required this.drop,
    required this.vehicle,
    required this.driverArrival,
  });

  final String pickup;
  final String drop;
  final String vehicle;
  final String driverArrival;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Trip Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.my_location, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text(pickup)),
            ],
          ),

          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: SizedBox(
              height: 25,
              child: VerticalDivider(),
            ),
          ),

          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(child: Text(drop)),
            ],
          ),

          const Divider(height: 30),

          Row(
            children: [
              const Icon(Icons.directions_car, color: primaryColor),
              const SizedBox(width: 10),
              Expanded(child: Text(vehicle)),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.timer, color: accentColor),
              const SizedBox(width: 10),
              Text(driverArrival),
            ],
          ),
        ],
      ),
    );
  }
}