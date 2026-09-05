import 'package:flutter/material.dart';

class ResendOtpButton extends StatelessWidget {
  const ResendOtpButton({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Didn't receive the code?",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 46,
          child: TextButton(
            onPressed: (enabled && !loading) ? onPressed : null,

            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              foregroundColor: gold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),

              child: loading
                  ? const SizedBox(
                      key: ValueKey("loading"),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(primary),
                      ),
                    )
                  : Row(
                      key: const ValueKey("text"),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: enabled
                              ? gold
                              : Colors.grey.shade400,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          "Resend OTP",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: enabled
                                ? gold
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}