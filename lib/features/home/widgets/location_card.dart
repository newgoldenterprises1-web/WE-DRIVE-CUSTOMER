import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.pickupController,
    required this.dropController,
    required this.onContinue,
    required this.onSwap,
  });

  final TextEditingController pickupController;
  final TextEditingController dropController;
  final VoidCallback onContinue;
  final VoidCallback onSwap;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: pickupController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.my_location,
                color: Colors.green,
              ),
              hintText: "Pickup Location",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: onSwap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: .12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_vert,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          TextField(
            controller: dropController,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.location_on,
                color: Colors.red,
              ),
              hintText: "Drop Location",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                "Continue",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}