import 'package:flutter/material.dart';

class LocationSearchCard extends StatelessWidget {
  const LocationSearchCard({
    super.key,
    required this.pickupController,
    required this.dropController,
    required this.onPickupTap,
    required this.onDropTap,
  });

  final TextEditingController pickupController;
  final TextEditingController dropController;
  final VoidCallback onPickupTap;
  final VoidCallback onDropTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black12,
          )
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: pickupController,
            readOnly: true,
            onTap: onPickupTap,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.my_location, color: Colors.green),
              hintText: "Pickup Location",
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: dropController,
            readOnly: true,
            onTap: onDropTap,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_on, color: Colors.red),
              hintText: "Drop Location",
            ),
          ),
        ],
      ),
    );
  }
}