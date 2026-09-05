import 'package:flutter/material.dart';

class OtpHeader extends StatelessWidget {
  const OtpHeader({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: .18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: gold,
            size: 42,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          "Verify Your Number",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "Enter the 6-digit verification code",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          phoneNumber,
          style: const TextStyle(
            color: primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 18),

        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            color: gold,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }
}