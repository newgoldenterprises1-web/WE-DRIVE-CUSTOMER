import 'package:flutter/material.dart';
import '../../booking/booking_screen.dart';

class FareSection extends StatelessWidget {
  const FareSection({super.key});

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF173B6D),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [

          const Row(
            children: [

              Icon(
                Icons.payments_rounded,
                color: gold,
                size: 28,
              ),

              SizedBox(width: 10),

              Text(
                "Estimated Fare",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "₹2,450",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Premium Chauffeur • Taxes Included",
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [

                Icon(
                  Icons.local_offer,
                  color: gold,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Apply Coupon",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BookingScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                "CONTINUE BOOKING",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}