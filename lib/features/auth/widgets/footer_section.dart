import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  static const Color primaryColor = Color(0xFF173B6D);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              height: 1.6,
            ),
            children: const [
              TextSpan(text: "By continuing you agree to our "),
              TextSpan(
                text: "Terms & Conditions",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(text: " and "),
              TextSpan(
                text: "Privacy Policy",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(text: "."),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.shade300,
        ),

        const SizedBox(height: 16),

        const Text(
          "WE DRIVE",
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Premium Chauffeur Service",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          "Version 1.0.0",
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "© 2026 WE DRIVE. All Rights Reserved.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}