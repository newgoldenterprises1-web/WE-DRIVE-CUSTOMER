import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chauffeur_status_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.serviceType,
    required this.pickupLocation,
    required this.dropLocation,
    required this.vehicleType,
    required this.fare,
    this.selectedHours,
    this.specialInstruction = '',
  });

  final String serviceType;
  final String pickupLocation;
  final String dropLocation;
  final String vehicleType;
  final double fare;
  final int? selectedHours;
  final String specialInstruction;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  String selectedPaymentMethod = "UPI";
  bool isBooking = false;

  double get driverPayout => widget.fare * 0.85;
  double get weDriveShare => widget.fare * 0.15;

  String _generateBookingId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _processBooking() async {
    setState(() => isBooking = true);

    final newBookingId = _generateBookingId();
    final user = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance.collection('bookings').doc(newBookingId).set({
        'bookingId': newBookingId,
        'userId': user?.uid ?? 'guest_user',
        'userName': user?.displayName ?? 'Valued Customer',
        'userPhone': user?.phoneNumber ?? '',
        'serviceType': widget.serviceType,
        'pickupLocation': widget.pickupLocation,
        'dropLocation': widget.dropLocation,
        'vehicleType': widget.vehicleType,
        'fare': widget.fare,
        'driverPayout': double.parse(driverPayout.toStringAsFixed(2)),
        'weDriveShare': double.parse(weDriveShare.toStringAsFixed(2)),
        'selectedHours': widget.selectedHours,
        'specialInstruction': widget.specialInstruction,
        'paymentMethod': selectedPaymentMethod,
        'paymentStatus': selectedPaymentMethod == 'Cash' ? 'pending' : 'paid',
        'status': 'searching',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChauffeurStatusScreen(
            pickupLocation: widget.pickupLocation,
            dropLocation: widget.dropLocation,
            fare: widget.fare,
            vehicleType: widget.vehicleType,
            bookingId: newBookingId,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => isBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book chauffeur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment & Confirm",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.selectedHours != null
                          ? "${widget.serviceType} (${widget.selectedHours}h Package)"
                          : widget.serviceType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primary,
                      ),
                    ),
                    Text(
                      widget.vehicleType,
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.radio_button_checked, color: primary, size: 16),
                        Container(width: 1.5, height: 26, color: Colors.grey.shade300),
                        const Icon(Icons.location_on, color: gold, size: 18),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pickupLocation,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primary),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.dropLocation,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.specialInstruction.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes_rounded, color: primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.specialInstruction.trim(),
                          style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Payment Options",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primary),
          ),
          const SizedBox(height: 12),

          _paymentOptionTile("UPI (GPay / PhonePe / Paytm)", Icons.qr_code_2_rounded, "UPI"),
          const SizedBox(height: 10),
          _paymentOptionTile("Credit / Debit Card", Icons.credit_card_rounded, "Card"),
          const SizedBox(height: 10),
          _paymentOptionTile("Cash to Driver", Icons.payments_outlined, "Cash"),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Chauffeur Service Package",
                      style: TextStyle(fontSize: 13.5, color: Colors.black87, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "₹${widget.fare.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Taxes & Platform Charges",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      "Included",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const Divider(height: 22, color: Color(0xFFF1F5F9)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount Payable",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primary),
                    ),
                    Text(
                      "₹${widget.fare.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          child: ElevatedButton(
            onPressed: isBooking ? null : _processBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: isBooking
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pay ₹${widget.fare.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Row(
                        children: [
                          Text("Book Chauffeur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _paymentOptionTile(String title, IconData icon, String value) {
    final isSelected = selectedPaymentMethod == value;
    return InkWell(
      onTap: () => setState(() => selectedPaymentMethod = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? primary : border, width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primary : Colors.grey.shade600, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: primary,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? primary : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
