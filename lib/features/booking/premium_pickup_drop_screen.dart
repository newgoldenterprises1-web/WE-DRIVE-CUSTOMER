import 'package:flutter/material.dart';

import 'map_location_picker_screen.dart';
import '../confirm_booking/confirm_booking_screen.dart';

class PremiumPickupDropScreen extends StatefulWidget {
  const PremiumPickupDropScreen({
    super.key,
    required this.serviceType,
    required this.fare,
    this.selectedHours,
  });

  final String serviceType;
  final double fare;
  final int? selectedHours;

  @override
  State<PremiumPickupDropScreen> createState() => _PremiumPickupDropScreenState();
}

class _PremiumPickupDropScreenState extends State<PremiumPickupDropScreen> {
  static const Color primary = Color(0xFF174C52);
  static const Color accent = Color(0xFFB99A47);
  static const Color bg = Color(0xFFF6F8F9);
  static const Color border = Color(0xFFE1E8EA);

  String pickup = '';
  String destination = '';

  Future<void> _pickPickup() async {
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const MapLocationPickerScreen()));
    if (result != null && result.trim().isNotEmpty) setState(() => pickup = result.trim());
  }

  Future<void> _pickDestination() async {
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const MapLocationPickerScreen()));
    if (result != null && result.trim().isNotEmpty) setState(() => destination = result.trim());
  }

  void _continue() {
    if (pickup.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select pickup and destination on Google Maps.')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmBookingScreen(
          serviceType: 'Premium ${widget.serviceType} Chauffeur',
          pickupLocation: pickup,
          dropLocation: destination,
          vehicleType: 'Premium Chauffeur Service',
          fare: widget.fare,
          selectedHours: widget.selectedHours,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        title: const Text('Premium Pickup & Destination', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [primary, Color(0xFF1D686F)]), borderRadius: BorderRadius.circular(22)),
            child: const Row(children: [
              Icon(Icons.workspace_premium_rounded, color: accent, size: 28),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('WE DRIVE PREMIUM', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)), SizedBox(height: 4), Text('Choose exactly where your chauffeur should meet you.', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))])),
            ]),
          ),
          const SizedBox(height: 16),
          _locationCard(label: 'Pickup location', value: pickup.isEmpty ? 'Select pickup on Google Maps' : pickup, icon: Icons.radio_button_checked_rounded, color: primary, onTap: _pickPickup),
          const SizedBox(height: 12),
          _locationCard(label: 'Destination', value: destination.isEmpty ? 'Select destination on Google Maps' : destination, icon: Icons.location_on_rounded, color: accent, onTap: _pickDestination),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Premium service', style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 8),
              Text(widget.serviceType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primary)),
              if (widget.selectedHours != null) ...[const SizedBox(height: 5), Text('${widget.selectedHours} hour chauffeur service', style: const TextStyle(color: Colors.black54, fontSize: 12))],
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Estimated fare', style: TextStyle(color: Colors.black54, fontSize: 12)), Text('₹${widget.fare.toStringAsFixed(0)}', style: const TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: 20))]),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: ElevatedButton(
          onPressed: _continue,
          style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(54), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Text('CONTINUE TO REVIEW', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ),
    );
  }

  Widget _locationCard({required String label, required String value, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
        child: Row(children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.black45, fontSize: 10.5, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 13))])),
          const Icon(Icons.map_rounded, color: primary, size: 21),
        ]),
      ),
    );
  }
}
