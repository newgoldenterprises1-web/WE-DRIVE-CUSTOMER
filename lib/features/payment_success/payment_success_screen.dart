import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../rating/rating_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    this.paymentMethod = 'UPI',
    this.bookingId,
    this.bookingDate,
    this.bookingTime,
  });

  final String amount;
  final String paymentMethod;
  final String? bookingId;
  final String? bookingDate;
  final String? bookingTime;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color bg = Color(0xFFF5F7FA);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF173B6D);
  static const Color textSub = Color(0xFF64748B);

  late final String transactionId;

  @override
  void initState() {
    super.initState();
    transactionId = 'WD${DateTime.now().millisecondsSinceEpoch}';
  }

  String _receiptText() {
    return '''
WE DRIVE CHAUFFEUR
Booking Confirmation

Amount: ₹${widget.amount}
Payment Mode: ${widget.paymentMethod}
Booking ID: ${widget.bookingId ?? 'N/A'}
Txn ID: $transactionId
Date: ${widget.bookingDate ?? "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"}
${widget.bookingTime != null ? "Time: ${widget.bookingTime}" : ""}
''';
  }

  Future<void> _copyReceipt() async {
    await Clipboard.setData(ClipboardData(text: _receiptText()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 44, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                "Booking Confirmed!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textMain),
              ),
              const SizedBox(height: 4),
              const Text(
                "Your chauffeur request has been accepted.",
                style: TextStyle(fontSize: 13, color: textSub),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    Text(
                      "₹${widget.amount}",
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: primary),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: border),
                    const SizedBox(height: 10),
                    _infoRow("Booking ID", widget.bookingId ?? 'N/A'),
                    _infoRow("Payment Method", widget.paymentMethod),
                    _infoRow("Transaction ID", transactionId),
                    _infoRow("Status", "Chauffeur Assigned"),
                    _infoRow(
                      "Date",
                      widget.bookingDate ??
                          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                    ),
                    if (widget.bookingTime != null)
                      _infoRow("Time", widget.bookingTime!),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _copyReceipt,
                      icon: const Icon(Icons.copy_rounded, size: 18, color: primary),
                      label: const Text(
                        "Copy Receipt",
                        style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: border),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RatingScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  "Go to Rating / Home",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: textSub, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textMain),
          ),
        ],
      ),
    );
  }
}
