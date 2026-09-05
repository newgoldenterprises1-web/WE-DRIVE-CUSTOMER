import 'package:flutter/material.dart';

class TripStatusCard extends StatelessWidget {
  const TripStatusCard({
    super.key,
    required this.speed,
    required this.eta,
    required this.distanceRemaining,
    required this.status,
  });

  final String speed;
  final String eta;
  final String distanceRemaining;
  final String status;

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
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 6,
                backgroundColor: Colors.green,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Trip Status",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: _infoCard(
                  Icons.speed,
                  speed,
                  "Speed",
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _infoCard(
                  Icons.schedule,
                  eta,
                  "ETA",
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _infoCard(
                  Icons.route,
                  distanceRemaining,
                  "Remaining",
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _infoCard(
                  Icons.location_on,
                  "Tracking",
                  "GPS Active",
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
    String label,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 12,
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
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}