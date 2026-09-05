import 'package:flutter/material.dart';

class BillBreakdownCard extends StatelessWidget {
  const BillBreakdownCard({
    super.key,
    required this.baseFare,
    required this.distanceCharge,
    required this.timeCharge,
    required this.gst,
    required this.discount,
    required this.total,
  });

  final String baseFare;
  final String distanceCharge;
  final String timeCharge;
  final String gst;
  final String discount;
  final String total;

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
        children: [

          const Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                color: accentColor,
              ),
              SizedBox(width: 10),
              Text(
                "Bill Breakdown",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _billRow(
            "Base Fare",
            baseFare,
          ),

          _billRow(
            "Distance Charge",
            distanceCharge,
          ),

          _billRow(
            "Time Charge",
            timeCharge,
          ),

          _billRow(
            "GST",
            gst,
          ),

          _billRow(
            "Coupon Discount",
            "-$discount",
            valueColor: Colors.green,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(
              thickness: 1.2,
            ),
          ),

          _billRow(
            "Grand Total",
            total,
            bold: true,
            valueColor: primaryColor,
            fontSize: 22,
          ),
        ],
      ),
    );
  }

  Widget _billRow(
    String title,
    String value, {
    bool bold = false,
    Color? valueColor,
    double fontSize = 16,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}