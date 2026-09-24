import 'package:flutter/material.dart';

import '../../services/booking_service.dart';
import '../payment_success/payment_success_screen.dart';

enum PaymentMethod {
  upi,
  card,
  cash,
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.serviceType = 'Standard',
    this.pickupLocation = '',
    this.dropLocation = '',
    this.selectedHours,
    this.fare = 0,
    this.vehicleType = 'Sedan',
    this.paymentMethod = 'UPI',
    this.bookingDate,
    this.bookingTime,
    this.specialInstruction = '',
  });

  final String serviceType;
  final String pickupLocation;
  final String dropLocation;
  final int? selectedHours;
  final double fare;
  final String vehicleType;
  final String paymentMethod;
  final DateTime? bookingDate;
  final String? bookingTime;
  final String specialInstruction;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color primary = Color(0xFF174C52);
  static const Color gold = Color(0xFF19A8A3);

  final TextEditingController couponController = TextEditingController();

  PaymentMethod selectedMethod = PaymentMethod.upi;

  bool paying = false;
  bool applyingCoupon = false;

  String? couponError;
  double discountAmount = 0;

  @override
  void initState() {
    super.initState();
    selectedMethod = _methodFromString(widget.paymentMethod);
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  PaymentMethod _methodFromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'upi':
      default:
        return PaymentMethod.upi;
    }
  }

  String get paymentMethodName {
    switch (selectedMethod) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  double get baseFare {
    return widget.fare > 0 ? widget.fare : 0;
  }

  double get total {
    final value = baseFare - discountAmount;
    return value < 0 ? 0 : value;
  }

  Future<void> applyCoupon() async {
    if (applyingCoupon) return;

    setState(() {
      applyingCoupon = true;
      couponError = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final code = couponController.text.trim().toUpperCase();

    if (code == 'WEDRIVE100') {
      setState(() {
        discountAmount = baseFare >= 100 ? 100 : baseFare;
        applyingCoupon = false;
        couponError = null;
      });
    } else {
      setState(() {
        discountAmount = 0;
        applyingCoupon = false;
        couponError = 'Invalid Coupon Code';
      });
    }
  }

  Future<void> payNow() async {
    if (paying) return;

    if (baseFare <= 0) {
      _showError('Invalid booking fare.');
      return;
    }

    if (widget.pickupLocation.trim().isEmpty) {
      _showError('Pickup location is missing.');
      return;
    }

    if (widget.dropLocation.trim().isEmpty) {
      _showError('Drop location is missing.');
      return;
    }

    setState(() {
      paying = true;
    });

    try {
      final bookingId = await BookingService.createBooking(
        serviceType: widget.serviceType,
        pickupLocation: widget.pickupLocation,
        dropLocation: widget.dropLocation,
        bookingDate: widget.bookingDate,
        bookingTime: widget.bookingTime,
        selectedHours: widget.selectedHours,
        vehicleType: widget.vehicleType,
        fare: total,
        paymentMethod: paymentMethodName,
        paymentStatus: 'pending',
        additionalData: {
          'specialInstruction': widget.specialInstruction,
          'originalFare': baseFare,
          'discount': discountAmount,
          'couponCode': couponController.text.trim().isEmpty
              ? null
              : couponController.text.trim().toUpperCase(),
          'paymentGateway': 'not_integrated',
        },
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: total.toStringAsFixed(0),
            paymentMethod: paymentMethodName,
            bookingId: bookingId,
            bookingDate: widget.bookingDate == null
                ? null
                : '${widget.bookingDate!.day}/${widget.bookingDate!.month}/${widget.bookingDate!.year}',
            bookingTime: widget.bookingTime,
            pickupLocation: widget.pickupLocation,
            dropLocation: widget.dropLocation,
            serviceType: widget.serviceType,
            vehicleType: widget.vehicleType,
            fare: total,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        paying = false;
      });

      _showError(
        'Booking failed: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _paymentMethodTile({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = selectedMethod == method;

    return InkWell(
      onTap: paying
          ? null
          : () {
              setState(() {
                selectedMethod = method;
              });
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primary,
              size: 26,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
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
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? gold : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalText = '₹${total.toStringAsFixed(0)}';

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Fare',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    totalText,
                    style: const TextStyle(
                      color: primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        color: primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${widget.serviceType} • ${widget.vehicleType}',
                          style: const TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.selectedHours != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: gold,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${widget.selectedHours} hours',
                          style: const TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
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
              'Payment Method',
              style: TextStyle(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _paymentMethodTile(
              method: PaymentMethod.upi,
              icon: Icons.account_balance_wallet,
              title: 'UPI',
              subtitle: 'Google Pay, PhonePe, Paytm',
            ),
            _paymentMethodTile(
              method: PaymentMethod.card,
              icon: Icons.credit_card,
              title: 'Card',
              subtitle: 'Credit or Debit Card',
            ),
            _paymentMethodTile(
              method: PaymentMethod.cash,
              icon: Icons.payments,
              title: 'Cash',
              subtitle: 'Pay the chauffeur directly',
            ),
            const SizedBox(height: 12),
            const Text(
              'Coupon',
              style: TextStyle(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponController,
                    textCapitalization: TextCapitalization.characters,
                    enabled: !paying && !applyingCoupon,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: applyingCoupon ? null : applyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: applyingCoupon
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Apply'),
                  ),
                ),
              ],
            ),
            if (couponError != null) ...[
              const SizedBox(height: 8),
              Text(
                couponError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (discountAmount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Discount applied: ₹${discountAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bill Summary',
                      style: TextStyle(
                        color: primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _billRow('Base Fare', '₹${baseFare.toStringAsFixed(0)}'),
                  _billRow('Discount', '- ₹${discountAmount.toStringAsFixed(0)}'),
                  const Divider(height: 24),
                  _billRow('Total', totalText, bold: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: paying ? null : payNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: paying
                  ? const SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: gold,
                      ),
                    )
                  : Text(
                      'Confirm & Book • $totalText',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _billRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: primary,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
