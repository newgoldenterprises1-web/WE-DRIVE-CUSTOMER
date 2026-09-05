import 'package:flutter/material.dart';

class PriceBreakdownCard extends StatelessWidget {
  final String baseFare;
  final String distanceCharge;
  final String driverCharge;
  final String tax;
  final String discount;
  final String total;

  const PriceBreakdownCard({
    super.key,
    required this.baseFare,
    required this.distanceCharge,
    required this.driverCharge,
    required this.tax,
    required this.discount,
    required this.total,
  });

  Widget _buildRow(String title, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF173B6D) : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? Colors.green
                  : (isTotal ? const Color(0xFF173B6D) : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Fare Breakdown",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF173B6D),
            ),
          ),
          const SizedBox(height: 12),
          _buildRow("Base Fare", baseFare),
          _buildRow("Distance Charge", distanceCharge),
          _buildRow("Driver Allowance", driverCharge),
          _buildRow("Taxes & Fees", tax),
          _buildRow("Coupon Discount", "-$discount", isDiscount: true),
          const Divider(height: 24, thickness: 1),
          _buildRow("Total Amount", total, isTotal: true),
        ],
      ),
    );
  }
}