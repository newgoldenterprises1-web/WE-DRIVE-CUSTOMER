import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../services/booking_service.dart';
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
  late final Razorpay _razorpay;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'asia-south1');
  String? _pendingBookingId;
  String? _pendingOrderId;
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  String selectedPaymentMethod = "UPI";
  bool isBooking = false;
  DateTime? bookingDate;
  TimeOfDay? bookingTime;

  bool get isAirport => widget.serviceType.toLowerCase().contains('airport');
  bool get isOutstation => widget.serviceType.toLowerCase().contains('outstation');
  bool get requiresBookingSchedule => isAirport || isOutstation;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    if (requiresBookingSchedule) {
      final now = DateTime.now();
      bookingDate = DateTime(now.year, now.month, now.day);
      bookingTime = TimeOfDay(hour: now.hour, minute: now.minute);
    }
  }

  double get driverPayout => widget.fare * 0.85;
  double get weDriveShare => widget.fare * 0.15;

  String _generateBookingId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String _formatDate(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  String _formatTime(TimeOfDay value) {
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  DateTime? get _selectedDateTime {
    if (bookingDate == null || bookingTime == null) return null;
    return DateTime(bookingDate!.year, bookingDate!.month, bookingDate!.day, bookingTime!.hour, bookingTime!.minute);
  }

  Future<void> _selectBookingDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: bookingDate ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: isAirport ? 'Select Airport Booking Date' : 'Select Outstation Booking Date',
    );
    if (selected != null && mounted) {
      setState(() => bookingDate = selected);
    }
  }

  Future<void> _selectBookingTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: bookingTime ?? TimeOfDay.now(),
      helpText: 'Select Booking Time',
    );
    if (selected != null && mounted) {
      setState(() => bookingTime = selected);
    }
  }

  void _selectToday() {
    final now = DateTime.now();
    setState(() => bookingDate = DateTime(now.year, now.month, now.day));
  }

  Future<void> _processBooking() async {
    if (requiresBookingSchedule && (bookingDate == null || bookingTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select booking date and time.')));
      return;
    }

    if (requiresBookingSchedule && _selectedDateTime != null && _selectedDateTime!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a future booking time.')));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in before booking a chauffeur.')));
      return;
    }

    setState(() => isBooking = true);

    try {
      final selectedDateTime = _selectedDateTime;
      final bookingId = await BookingService.createBooking(
        serviceType: widget.serviceType,
        pickupLocation: widget.pickupLocation,
        dropLocation: widget.dropLocation,
        bookingDate: selectedDateTime,
        bookingTime: selectedDateTime == null ? null : _formatTime(TimeOfDay.fromDateTime(selectedDateTime)),
        selectedHours: widget.selectedHours,
        vehicleType: widget.vehicleType,
        fare: widget.fare,
        paymentMethod: selectedPaymentMethod,
        paymentStatus: 'pending',
        additionalData: {
          'specialInstruction': widget.specialInstruction,
          'serviceMode': widget.serviceType,
        },
      );

      if (selectedPaymentMethod == 'Cash') {
        if (!mounted) return;
        setState(() => isBooking = false);
        _openStatusScreen(bookingId);
        return;
      }

      final result = await _functions.httpsCallable('createRazorpayOrder').call({
        'bookingId': bookingId,
      });
      final data = Map<String, dynamic>.from(result.data as Map);

      _pendingBookingId = bookingId;
      _pendingOrderId = data['orderId']?.toString();

      final contact = user.phoneNumber?.replaceFirst('+91', '');
      final options = <String, dynamic>{
        'key': data['keyId'],
        'amount': data['amount'],
        'currency': data['currency'] ?? 'INR',
        'order_id': data['orderId'],
        'name': 'WeDrive247',
        'description': widget.serviceType + ' Chauffeur Service',
        'prefill': {
          if (contact != null && contact.isNotEmpty) 'contact': contact,
          if (user.email != null && user.email!.isNotEmpty) 'email': user.email,
        },
        'theme': {'color': '#173B6D'},
      };

      _razorpay.open(options);
    } catch (e) {
      if (!mounted) return;
      setState(() => isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start payment: ' + e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final bookingId = _pendingBookingId;
    final orderId = response.orderId ?? _pendingOrderId;
    final paymentId = response.paymentId;
    final signature = response.signature;

    if (bookingId == null || orderId == null || paymentId == null || signature == null) {
      if (mounted) {
        setState(() => isBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Razorpay returned incomplete payment details.')));
      }
      return;
    }

    try {
      await _functions.httpsCallable('verifyRazorpayPayment').call({
        'bookingId': bookingId,
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
      });

      if (!mounted) return;
      setState(() => isBooking = false);
      _openStatusScreen(bookingId);
    } catch (e) {
      if (!mounted) return;
      setState(() => isBooking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment verification failed: ' + e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => isBooking = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.message ?? 'Payment was not completed.'), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() => isBooking = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected: ' + (response.walletName ?? 'wallet'))),
    );
  }

  void _openStatusScreen(String bookingId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChauffeurStatusScreen(
          pickupLocation: widget.pickupLocation,
          dropLocation: widget.dropLocation,
          fare: widget.fare,
          vehicleType: widget.vehicleType,
          bookingId: bookingId,
        ),
      ),
    );
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
          if (requiresBookingSchedule) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAirport ? 'Airport Booking Schedule' : 'Outstation Booking Schedule',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primary),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isAirport ? 'Choose today or a future airport pickup/drop time.' : 'Choose the date and time for your outstation trip.',
                    style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectBookingDate,
                          icon: const Icon(Icons.calendar_month_rounded, size: 18),
                          label: Text(bookingDate == null ? 'Select Date' : _formatDate(bookingDate!)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: const BorderSide(color: border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectBookingTime,
                          icon: const Icon(Icons.access_time_rounded, size: 18),
                          label: Text(bookingTime == null ? 'Select Time' : _formatTime(bookingTime!)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primary,
                            side: const BorderSide(color: border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isAirport) ...[
                    const SizedBox(height: 9),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _selectToday,
                        icon: const Icon(Icons.today_rounded, size: 17),
                        label: const Text('Today / Aaj'),
                        style: TextButton.styleFrom(foregroundColor: primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
                    Text("Taxes & Platform Charges", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Included", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const Divider(height: 22, color: Color(0xFFF1F5F9)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Amount Payable", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primary)),
                    Text("₹${widget.fare.toStringAsFixed(0)}", style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: primary)),
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
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Pay ₹${widget.fare.toStringAsFixed(0)}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
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
                style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: primary, fontSize: 14),
              ),
            ),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? primary : Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
