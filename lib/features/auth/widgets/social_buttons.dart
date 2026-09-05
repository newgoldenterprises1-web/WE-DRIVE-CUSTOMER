import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
    required this.onGuestPressed,
  });

  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;
  final VoidCallback onGuestPressed;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "OR",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: onGooglePressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: SvgPicture.asset(
              "assets/images/google.svg",
              width: 22,
              height: 22,
            ),
            label: const Text(
              "Continue with Google",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: onApplePressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.apple, size: 22),
            label: const Text(
              "Continue with Apple",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        TextButton(
          onPressed: onGuestPressed,
          child: const Text(
            "Continue as Guest",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}