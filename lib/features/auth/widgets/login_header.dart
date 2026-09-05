import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: .25),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.drive_eta_rounded,
            color: accentColor,
            size: 50,
          ),
        ),

        const SizedBox(height: 22),

        const Text(
          "WE DRIVE",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: primaryColor,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "Your Car • Your Driver • Your Journey",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 35),
      ],
    );
  }
}