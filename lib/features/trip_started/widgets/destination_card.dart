import 'package:flutter/material.dart';

class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.distance,
    required this.eta,
    required this.fare,
  });

  final String pickupAddress;
  final String destinationAddress;
  final String distance;
  final String eta;
  final String fare;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.route_rounded,
                color: accentColor,
              ),
              SizedBox(width: 10),
              Text(
                "Trip Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _locationTile(
            color: Colors.green,
            icon: Icons.my_location,
            title: "Pickup",
            address: pickupAddress,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Container(
              width: 2,
              height: 30,
              color: Colors.grey.shade300,
            ),
          ),

          _locationTile(
            color: Colors.red,
            icon: Icons.location_on,
            title: "Destination",
            address: destinationAddress,
          ),

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: _infoCard(
                  Icons.route,
                  distance,
                  "Distance",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoCard(
                  Icons.schedule,
                  eta,
                  "ETA",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoCard(
                  Icons.currency_rupee,
                  fare,
                  "Fare",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _locationTile({
    required Color color,
    required IconData icon,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: .15),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoCard(
    IconData icon,
    String value,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: accentColor,
            size: 26,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}