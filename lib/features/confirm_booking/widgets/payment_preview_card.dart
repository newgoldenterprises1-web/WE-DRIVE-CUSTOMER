import 'package:flutter/material.dart';

class PaymentPreviewCard extends StatelessWidget {
  final String paymentMethod;
  final String paymentDetails;
  final VoidCallback onChange;

  const PaymentPreviewCard({
    super.key,
    required this.paymentMethod,
    required this.paymentDetails,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF173B6D).withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet, color: Color(0xFF173B6D)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paymentMethod,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  paymentDetails,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text(
              "Change",
              style: TextStyle(color: Color(0xFF173B6D), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}