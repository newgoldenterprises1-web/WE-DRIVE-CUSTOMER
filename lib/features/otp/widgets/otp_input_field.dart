import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpInputField extends StatelessWidget {
  const OtpInputField({
    super.key,
    required this.onCompleted,
  });

  final ValueChanged<String> onCompleted;

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,

      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: primary,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    return Pinput(
      length: 6,

      autofocus: true,

      keyboardType: TextInputType.number,

      onCompleted: onCompleted,

      defaultPinTheme: defaultPinTheme,

      focusedPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(
          color: primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .15),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      submittedPinTheme: defaultPinTheme.copyDecorationWith(
        color: const Color(0xffFAFBFC),
        border: Border.all(
          color: gold,
          width: 2,
        ),
      ),

      errorPinTheme: defaultPinTheme.copyDecorationWith(
        border: Border.all(
          color: Colors.red,
          width: 2,
        ),
      ),

      cursor: Container(
        width: 2,
        height: 24,
        color: gold,
      ),

      separatorBuilder: (index) =>
          const SizedBox(width: 8),
    );
  }
}