import 'package:flutter/material.dart';

enum PaymentMethod {
  upi,
  card,
  cash,
  wallet,
}

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  final PaymentMethod selectedMethod;
  final ValueChanged<PaymentMethod> onChanged;

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
                Icons.account_balance_wallet,
                color: accentColor,
              ),
              SizedBox(width: 10),
              Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _paymentTile(
            method: PaymentMethod.upi,
            icon: Icons.qr_code_rounded,
            title: "UPI",
            subtitle: "PhonePe, Google Pay, Paytm, BHIM",
          ),

          const SizedBox(height: 12),

          _paymentTile(
            method: PaymentMethod.card,
            icon: Icons.credit_card,
            title: "Credit / Debit Card",
            subtitle: "Visa, Mastercard, RuPay",
          ),

          const SizedBox(height: 12),

          _paymentTile(
            method: PaymentMethod.cash,
            icon: Icons.payments_rounded,
            title: "Cash",
            subtitle: "Pay the chauffeur after trip",
          ),

          const SizedBox(height: 12),

          _paymentTile(
            method: PaymentMethod.wallet,
            icon: Icons.account_balance_wallet_outlined,
            title: "Wallet",
            subtitle: "WE DRIVE Wallet Balance",
          ),
        ],
      ),
    );
  }

  Widget _paymentTile({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool selected = selectedMethod == method;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onChanged(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: .12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? accentColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [

            CircleAvatar(
              radius: 24,
              backgroundColor: selected
                  ? accentColor.withValues(alpha: .20)
                  : Colors.white,
              child: Icon(
                icon,
                color: primaryColor,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: selected
                  ? const Icon(
                      Icons.check_circle,
                      key: ValueKey("selected"),
                      color: Colors.green,
                      size: 28,
                    )
                  : const Icon(
                      Icons.radio_button_unchecked,
                      key: ValueKey("unselected"),
                      color: Colors.grey,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}