import 'package:flutter/material.dart';

class FareSummaryCard extends StatelessWidget {
  const FareSummaryCard({
    super.key,
    required this.totalFare,
    required this.tripDistance,
    required this.tripDuration,
  });

  final String totalFare;
  final String tripDistance;
  final String tripDuration;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [

          const Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: accentColor,
              ),
              SizedBox(width: 10),
              Text(
                "Trip Fare",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            totalFare,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Total Amount Payable",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [

              Expanded(
                child: _infoCard(
                  Icons.route,
                  tripDistance,
                  "Distance",
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _infoCard(
                  Icons.schedule,
                  tripDuration,
                  "Duration",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String value,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Icon(
            icon,
            color: accentColor,
            size: 28,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}