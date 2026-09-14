import 'package:flutter/material.dart';

import '../../services/booking_service.dart';
import '../booking/chauffeur_status_screen.dart';

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
  static const Color primary = Color(0xFF174C52);
  static const Color bg = Color(0xFFF6F8F9);
  static const Color border = Color(0xFFE1E8EA);
  static const Color textMain = Color(0xFF174C52);
  static const Color textSub = Color(0xFF647477);

  bool isSubmitting = false;
  String communicationStyle = 'NORMAL';
  String luggageMode = 'LIGHT';
  String pickupMode = 'CUSTOM_PIN';
  bool privacyMode = false;
  bool conciergeMode = false;
  bool whiteGlove = false;
  final guestNameController = TextEditingController();
  final guestPhoneController = TextEditingController();

  @override
  void dispose() {
    guestNameController.dispose();
    guestPhoneController.dispose();
    super.dispose();
  }

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
        bookingTime: widget.bookingTime,
        paymentMethod: 'Cash',
        paymentStatus: 'pending',
        additionalData: {
          if (widget.bookingDate != null && widget.bookingDate!.isNotEmpty)
            'bookingDate': widget.bookingDate,
          if (widget.specialInstruction != null && widget.specialInstruction!.isNotEmpty)
            'specialInstruction': widget.specialInstruction,
          'requestPreferences': {
            'communicationStyle': communicationStyle,
            'privacyMode': privacyMode,
            'luggageMode': luggageMode,
            'pickupMode': pickupMode,
            'guestName': guestNameController.text.trim().isEmpty ? null : guestNameController.text.trim(),
            'guestPhone': guestPhoneController.text.trim().isEmpty ? null : guestPhoneController.text.trim(),
            'guestRelationship': 'Guest',
            'conciergeMode': conciergeMode,
            'whiteGlove': whiteGlove,
          },
          'signatureMatchRequested': true,
        },
      );

      if (!mounted) return;
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to send chauffeur request: $e')),
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
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
        title: const Text('Review Chauffeur Request', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          _section(
            title: 'Service',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.serviceType, style: const TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Professional chauffeur • Payment handled later', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'Pickup & Destination',
            child: Column(children: [
              _locationRow(Icons.radio_button_checked_rounded, 'Pickup', widget.pickupLocation, primary),
              const SizedBox(height: 12),
              _locationRow(Icons.location_on_rounded, 'Destination', widget.dropLocation, const Color(0xFFB99A47)),
            ]),
          ),
          const SizedBox(height: 12),
          _smartPreferences(),
          const SizedBox(height: 12),
          _section(
            title: 'Schedule & Requirements',
            child: Column(children: [
              _row('Vehicle', widget.vehicleType),
              if (widget.selectedHours != null) _row('Duration', '${widget.selectedHours} hours'),
              if (widget.bookingDate != null && widget.bookingDate!.isNotEmpty) _row('Date', widget.bookingDate!),
              if (widget.bookingTime != null && widget.bookingTime!.isNotEmpty) _row('Time', widget.bookingTime!),
              if (widget.specialInstruction != null && widget.specialInstruction!.isNotEmpty) _row('Notes', widget.specialInstruction!),
            ]),
          ),
          const SizedBox(height: 12),
          _section(
            title: 'Fare',
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('All-inclusive estimated fare', style: TextStyle(color: textSub, fontSize: 13)),
              Text('₹${widget.fare.toStringAsFixed(0)}', style: const TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: 22)),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFEAF4F3), borderRadius: BorderRadius.circular(16)),
            child: const Row(children: [
              Icon(Icons.auto_awesome_rounded, color: primary, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('WE DRIVE will use these preferences to build your Signature Chauffeur match.', style: TextStyle(color: primary, fontSize: 11.5, height: 1.35, fontWeight: FontWeight.w600))),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: ElevatedButton(
          onPressed: isSubmitting ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: primary.withValues(alpha: 0.4),
            minimumSize: const Size.fromHeight(54),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isSubmitting
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('REQUEST CHAUFFEUR • ₹${widget.fare.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ),
    );
  }

  Widget _smartPreferences() => _section(
        title: 'Smart Chauffeur Preferences',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Communication'),
            _chips(['QUIET', 'NORMAL', 'CONVERSATIONAL'], communicationStyle, (value) => setState(() => communicationStyle = value)),
            const SizedBox(height: 14),
            _label('Luggage'),
            _chips(['NONE', 'LIGHT', 'MULTIPLE', 'LARGE'], luggageMode, (value) => setState(() => luggageMode = value)),
            const SizedBox(height: 14),
            _label('Pickup point'),
            _chips(['LOBBY', 'GATE', 'PARKING', 'TERMINAL', 'CUSTOM_PIN'], pickupMode, (value) => setState(() => pickupMode = value)),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Private Journey', style: TextStyle(fontWeight: FontWeight.w700, color: primary, fontSize: 13)),
              subtitle: const Text('Minimal conversation and discreet service instructions', style: TextStyle(fontSize: 11)),
              value: privacyMode,
              onChanged: (value) => setState(() => privacyMode = value),
              activeColor: primary,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Executive Concierge', style: TextStyle(fontWeight: FontWeight.w700, color: primary, fontSize: 13)),
              subtitle: const Text('Prepare the booking for premium support and special assistance', style: TextStyle(fontSize: 11)),
              value: conciergeMode,
              onChanged: (value) => setState(() => conciergeMode = value),
              activeColor: primary,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('White-Glove Service', style: TextStyle(fontWeight: FontWeight.w700, color: primary, fontSize: 13)),
              subtitle: const Text('Early arrival, professional meet-and-greet and extra care', style: TextStyle(fontSize: 11)),
              value: whiteGlove,
              onChanged: (value) => setState(() => whiteGlove = value),
              activeColor: primary,
            ),
            const Divider(height: 16),
            const Text('Guest booking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primary)),
            const SizedBox(height: 7),
            TextField(
              controller: guestNameController,
              decoration: InputDecoration(hintText: 'Guest name (optional)', filled: true, fillColor: const Color(0xFFF8FAFA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: guestPhoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(hintText: 'Guest phone (optional)', filled: true, fillColor: const Color(0xFFF8FAFA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
          ],
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(text, style: const TextStyle(color: textSub, fontSize: 11, fontWeight: FontWeight.w800)),
      );

  Widget _chips(List<String> values, String selected, ValueChanged<String> onSelected) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: values.map((value) {
        final active = value == selected;
        return ChoiceChip(
          label: Text(value.replaceAll('_', ' ')),
          selected: active,
          onSelected: (_) => onSelected(value),
          selectedColor: primary,
          labelStyle: TextStyle(color: active ? Colors.white : primary, fontSize: 11, fontWeight: FontWeight.w700),
          backgroundColor: const Color(0xFFF2F6F6),
          side: BorderSide(color: active ? primary : border),
        );
      }).toList(),
    );
  }

  Widget _section({required String title, required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.w800)), const SizedBox(height: 12), child]),
      );

  Widget _locationRow(IconData icon, String label, String value, Color color) => Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: textSub, fontSize: 10.5, fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: textMain, fontSize: 12.5, fontWeight: FontWeight.w700))]))]);

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: textSub, fontSize: 12)), const SizedBox(width: 18), Expanded(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.w700)))]),
      );
}
