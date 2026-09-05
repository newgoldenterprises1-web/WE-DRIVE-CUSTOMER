import 'package:flutter/material.dart';

class VerifyButton extends StatelessWidget {
  const VerifyButton({
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
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: (enabled && !loading) ? onPressed : null,

        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: enabled ? 5 : 0,
          shadowColor: primary.withValues(alpha: .25),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),

          child: loading
              ? const SizedBox(
                  key: ValueKey("loading"),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                )
              : const Row(
                  key: ValueKey("button"),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Icon(
                      Icons.verified_rounded,
                      size: 22,
                      color: Color(0xFFD4AF37),
                    ),

                    SizedBox(width: 10),

                    Text(
                      "Verify OTP",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: .3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}