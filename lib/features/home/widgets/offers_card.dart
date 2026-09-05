import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class OffersCard extends StatelessWidget {
  const OffersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF173B6D),
              Color(0xFF0E2B52),
            ],
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Iconsax.discount_shape,
              color: Color(0xFFD4AF37),
              size: 42,
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "15% OFF",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Use code WEDRIVE15 on your next chauffeur booking.",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coupon WEDRIVE15 applied.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
              ),
              child: const Text("Apply"),
            ),
          ],
        ),
      ),
    );
  }
}