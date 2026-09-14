import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../payment_success/payment_success_screen.dart';

class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({
    super.key,
    required this.serviceType,
    required this.pickupLocation,
    required this.dropLocation,
    required this.vehicleType,
    required this.fare,
    this.selectedHours,
    this.bookingDate,
    this.bookingTime,
    this.specialInstruction,
  });

  final String serviceType;
  final String pickupLocation;
  final String dropLocation;
  final String vehicleType;
  final double fare;
  final int? selectedHours;
  final String? bookingDate;
  final String? bookingTime;
  final String? specialInstruction;

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color bg = Color(0xFFF5F7FA);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF173B6D);
  static const Color textSub = Color(0xFF64748B);

  bool isSubmitting = false;

  Future<void> _handleConfirm() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    try {
      final bookingId = await BookingService.createBooking(
        serviceType: widget.serviceType,
        pickupLocation: widget.pickupLocation,
        dropLocation: widget.dropLocation,
        vehicleType: widget.vehicleType,
        fare: widget.fare,
        selectedHours: widget.selectedHours,
        // Payment is intentionally deferred; no amount is marked as paid.
        paymentMethod: 'Cash',
        paymentStatus: 'pending',
        additionalData: {
          'bookingDate': widget.bookingDate,
          'bookingTime': widget.bookingTime,
          if (widget.specialInstruction != null &&
              widget.specialInstruction!.isNotEmpty)
            'specialInstruction': widget.specialInstruction,
        },
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: widget.fare.toStringAsFixed(0),
            paymentMethod: 'Cash',
            bookingId: bookingId,
            bookingDate: widget.bookingDate,
            bookingTime: widget.bookingTime,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
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
        title: const Text(
          'Confirm Booking',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 14),
                _row('Service', widget.serviceType),
                _row('Vehicle', widget.vehicleType),
                _row('Pickup', widget.pickupLocation),
                _row('Drop', widget.dropLocation),
                if (widget.bookingDate != null)
                  _row('Date', widget.bookingDate!),
                if (widget.bookingTime != null)
                  _row('Time', widget.bookingTime!),
                const Divider(height: 22, color: border),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Payment',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSub,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Payment later',
                      style: TextStyle(
                        fontSize: 13,
                        color: textMain,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Fare',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    Text(
                      '₹${widget.fare.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your request will be sent to the WE DRIVE Partner app for driver assignment.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSub, fontSize: 12, height: 1.4),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: border)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Confirm & Hire Chauffeur • ₹${widget.fare.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: textSub, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: textMain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
