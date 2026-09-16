import 'package:flutter/material.dart';

import 'map_location_picker_screen.dart';
import 'payment_screen.dart';

class PickupDropScreen extends StatefulWidget {
  const PickupDropScreen({
    super.key,
    this.serviceType = 'Hourly Driver',
    this.isPremium = false,
    this.premiumFare,
    this.selectedHours,
    this.vehicleData,
  });

  final String serviceType;
  final bool isPremium;
  final String? premiumFare;
  final int? selectedHours;
  final Map<String, dynamic>? vehicleData;

  @override
  State<PickupDropScreen> createState() => _PickupDropScreenState();
}

class _PickupDropScreenState extends State<PickupDropScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color deep = Color(0xFF0B2341);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF6F8FB);
  static const Color border = Color(0xFFE1E7EF);

  String pickup = '';
  String drop = '';
  int selectedHours = 2;
  DateTime? scheduledDate;
  TimeOfDay? scheduledTime;
  bool isNavigating = false;

  bool get isPremiumLanding => widget.isPremium && widget.serviceType == 'Premium Chauffeur';
  bool get isAirport => widget.serviceType.toLowerCase().contains('airport');
  bool get isOutstation => widget.serviceType.toLowerCase().contains('outstation');
  bool get isAdvance => widget.serviceType.toLowerCase().contains('advance');

  double get fare {
    if (widget.premiumFare != null) {
      return double.tryParse(widget.premiumFare!.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 549;
    }
    if (isAirport) return widget.isPremium ? 1299 : 999;
    if (isOutstation) return 1799;
    final Map<int, double> dayRates = <int, double>{1: 299, 2: 349, 4: 549, 6: 749, 8: 949, 12: 1299};
    return (dayRates[selectedHours] ?? 349) + (widget.isPremium ? 150 : 0);
  }

  String get vehicleType => widget.vehicleData?['vehicleType']?.toString() ?? 'Chauffeur Service';

  @override
  void initState() {
    super.initState();
    selectedHours = widget.selectedHours ?? 2;
    if (![1, 2, 4, 6, 8, 12].contains(selectedHours)) selectedHours = 2;
  }

  Future<void> _pickLocation({required bool pickupLocation}) async {
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(builder: (_) => const MapLocationPickerScreen()),
    );
    if (!mounted || result == null || result.trim().isEmpty) return;
    setState(() {
      if (pickupLocation) {
        pickup = result.trim();
      } else {
        drop = result.trim();
      }
    });
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime first = DateTime(now.year, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: scheduledDate ?? now,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) setState(() => scheduledDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: scheduledTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) setState(() => scheduledTime = picked);
  }

  Future<void> _reviewAndBook() async {
    if (pickup.isEmpty || drop.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and drop locations.')),
      );
      return;
    }

    if ((isAirport || isOutstation || isAdvance) && (scheduledDate == null || scheduledTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select booking date and time.')),
      );
      return;
    }

    if (isNavigating) return;
    setState(() => isNavigating = true);

    if (!mounted) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PaymentScreen(
          serviceType: widget.serviceType,
          pickupLocation: pickup,
          dropLocation: drop,
          vehicleType: vehicleType,
          fare: fare,
          selectedHours: widget.selectedHours ?? (widget.isPremium ? selectedHours : null),
          specialInstruction: scheduledDate != null && scheduledTime != null
              ? 'Scheduled: ${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year} ${scheduledTime!.format(context)}'
              : '',
        ),
      ),
    );

    if (mounted) setState(() => isNavigating = false);
  }

  void _selectPremiumService(String service) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PickupDropScreen(serviceType: service, isPremium: true),
      ),
    );
  }

  Future<void> _showAdvanceSchedule() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(width: 42, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(5))),
            const SizedBox(height: 16),
            const Row(
              children: <Widget>[
                Icon(Icons.event_available_rounded, color: gold, size: 24),
                SizedBox(width: 8),
                Text('Advance Booking', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: primary)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Choose your travel date and preferred pickup time.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
            const SizedBox(height: 14),
            _scheduleTile(Icons.event_rounded, 'Travel date', scheduledDate == null ? 'Select date' : '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}', _pickDate),
            const SizedBox(height: 10),
            _scheduleTile(Icons.access_time_filled_rounded, 'Pickup time', scheduledTime == null ? 'Select time' : scheduledTime!.format(context), _pickTime),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext),
                style: ElevatedButton.styleFrom(backgroundColor: deep, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scheduleTile(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: Row(
          children: <Widget>[
            Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: primary, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.w800))])),
            const Icon(Icons.chevron_right_rounded, color: primary),
          ],
        ),
      ),
    );
  }

  Widget _locationCard({required bool pickupLocation}) {
    final String value = pickupLocation ? pickup : drop;
    final bool hasValue = value.trim().isNotEmpty;
    return InkWell(
      onTap: () => _pickLocation(pickupLocation: pickupLocation),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: hasValue ? primary.withValues(alpha: 0.35) : border), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
        child: Row(
          children: <Widget>[
            Container(width: 42, height: 42, decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)), child: Icon(pickupLocation ? Icons.radio_button_checked_rounded : Icons.location_on_rounded, color: pickupLocation ? primary : gold)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(pickupLocation ? 'Pickup Location' : 'Drop Location', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(hasValue ? value : pickupLocation ? 'Select pickup location' : 'Select drop location', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: hasValue ? primary : Colors.grey.shade500, fontWeight: FontWeight.w700))])),
            const Icon(Icons.chevron_right_rounded, color: primary),
          ],
        ),
      ),
    );
  }

  Widget _hoursSelector() {
    const List<int> hours = <int>[1, 2, 4, 6, 8, 12];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hours.map((int hour) {
        final bool selected = selectedHours == hour;
        return ChoiceChip(
          selected: selected,
          label: Text('$hour hr'),
          onSelected: (_) => setState(() => selectedHours = hour),
          selectedColor: primary,
          backgroundColor: Colors.white,
          side: BorderSide(color: selected ? primary : border),
          labelStyle: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.w700),
        );
      }).toList(),
    );
  }

  Widget _bookingBody() {
    final bool showSchedule = isAirport || isOutstation || isAdvance;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[deep, primary]), borderRadius: BorderRadius.circular(24), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 6))]),
          child: Row(
            children: <Widget>[
              const Icon(Icons.directions_car_filled_rounded, color: gold, size: 30),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('WE DRIVE', style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(widget.serviceType, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text('Select your pickup and drop locations to continue.', style: TextStyle(color: Colors.white70, fontSize: 12))])),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Choose locations', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: primary)),
        const SizedBox(height: 8),
        _locationCard(pickupLocation: true),
        const SizedBox(height: 10),
        _locationCard(pickupLocation: false),
        if (!isAirport && !isOutstation && !isAdvance) ...[
          const SizedBox(height: 18),
          const Text('Duration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: primary)),
          const SizedBox(height: 8),
          _hoursSelector(),
        ],
        if (showSchedule) ...[
          const SizedBox(height: 18),
          const Text('Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: primary)),
          const SizedBox(height: 8),
          _scheduleTile(Icons.event_rounded, 'Travel date', scheduledDate == null ? 'Select date' : '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}', _pickDate),
          const SizedBox(height: 8),
          _scheduleTile(Icons.access_time_filled_rounded, 'Pickup time', scheduledTime == null ? 'Select time' : scheduledTime!.format(context), _pickTime),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[const Text('Estimated fare', style: TextStyle(color: Colors.black54, fontSize: 11)), const SizedBox(height: 5), Text(widget.selectedHours != null ? '${widget.selectedHours} hour package' : 'Transparent fare • No hidden fees', style: const TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 12))]),
            Text('₹${fare.toStringAsFixed(0)}', style: const TextStyle(color: primary, fontSize: 24, fontWeight: FontWeight.w900)),
          ]),
        ),
      ],
    );
  }

  Widget _premiumLanding() {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: deep,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('WE DRIVE', style: TextStyle(fontSize: 12, color: gold, fontWeight: FontWeight.w800)), Text('Premium Chauffeur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))]),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[deep, primary]), borderRadius: BorderRadius.circular(26), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6))]),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Row(children: <Widget>[Icon(Icons.workspace_premium_rounded, color: gold, size: 30), SizedBox(width: 10), Text('Premium Experience', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900))]),
              SizedBox(height: 8),
              Text('Professional chauffeurs, elevated comfort and a booking flow designed for a premium ride.', style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4)),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('Choose a service', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: primary)),
          const SizedBox(height: 4),
          Text('Simple names. Clear choices. Pick what you need.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.98,
            children: <Widget>[
              _premiumCard('Hourly Chauffeur', 'Book a chauffeur by the hour.', Icons.access_time_rounded, () => _selectPremiumService('Premium Hourly Driver'), featured: true),
              _premiumCard('Airport Transfer', 'Smooth pickup or drop at the airport.', Icons.flight_takeoff_rounded, () => _selectPremiumService('Premium Airport Transfer')),
              _premiumCard('Outstation Chauffeur', 'Comfortable long-distance travel.', Icons.alt_route_rounded, () => _selectPremiumService('Premium Outstation')),
              _premiumCard('Advance Booking', 'Schedule your chauffeur ahead of time.', Icons.event_available_rounded, () => _selectPremiumService('Premium Advance Booking')),
            ],
          ),
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)), child: const Row(children: <Widget>[Icon(Icons.verified_rounded, color: Colors.green, size: 20), SizedBox(width: 9), Expanded(child: Text('Professional service • Transparent pricing • Easy booking', style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w700)))])),
        ],
      ),
    );
  }

  Widget _premiumCard(String title, String subtitle, IconData icon, VoidCallback onTap, {bool featured = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: featured ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF102B4F), primary]) : null, color: featured ? null : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: featured ? gold.withValues(alpha: 0.65) : border), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 5))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Row(children: <Widget>[
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: featured ? Colors.white.withValues(alpha: 0.10) : primary.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: featured ? gold : primary, size: 25)),
            const Spacer(),
            if (featured) const Icon(Icons.star_rounded, color: gold, size: 20),
          ]),
          const Spacer(),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: featured ? Colors.white : primary)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11.5, height: 1.25, color: featured ? Colors.white70 : Colors.grey.shade600)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isPremiumLanding) return _premiumLanding();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: deep,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.serviceType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: _bookingBody(),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: ElevatedButton(
          onPressed: isNavigating ? null : _reviewAndBook,
          style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(54), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: isNavigating ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text('₹${fare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const Text('Review & Book  →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))]),
        ),
      ),
    );
  }
}
