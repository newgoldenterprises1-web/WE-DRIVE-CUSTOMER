import 'package:flutter/material.dart';

enum DriverTripStatus { arriving, arrived, inTrip, completed }

class DriverStatusCard extends StatelessWidget {
  final DriverTripStatus status;

  const DriverStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String getStatusText() {
      switch (status) {
        case DriverTripStatus.arriving:
          return "Driver is arriving at pickup location";
        case DriverTripStatus.arrived:
          return "Driver has arrived at pickup point";
        case DriverTripStatus.inTrip:
          return "Trip in progress";
        case DriverTripStatus.completed:
          return "Trip Completed";
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF173B6D).withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF173B6D)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              getStatusText(),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF173B6D)),
            ),
          ),
        ],
      ),
    );
  }
}