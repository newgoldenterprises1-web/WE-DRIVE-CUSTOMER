import 'package:flutter/material.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({
    super.key,
    required this.controller,
    required this.discount,
    required this.loading,
    required this.onApply,
    this.errorText,
  });

  final TextEditingController controller;
  final String? discount;
  final bool loading;
  final String? errorText;
  final VoidCallback onApply;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [
              Icon(
                Icons.local_offer,
                color: accentColor,
              ),
              SizedBox(width: 10),
              Text(
                "Promo Code",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: "Enter coupon code",
              prefixIcon: const Icon(Icons.discount),
              suffixIcon: loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: onApply,
                      child: const Text("Apply"),
                    ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          if (errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          if (discount != null) ...[
            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.green.shade300,
                ),
              ),
              child: Row(
                children: [

                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Coupon Applied Successfully",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Text(
                    "-$discount",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}