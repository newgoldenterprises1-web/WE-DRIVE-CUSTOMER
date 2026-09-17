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
  final List<String> stops = <String>[];
  String tripType = 'One Way';
  int selectedHours = 2;
  DateTime? scheduledDate;
  TimeOfDay? scheduledTime;
  bool isNavigating = false;

  bool get isPremiumLanding =>
      widget.isPremium && widget.serviceType == 'Premium Chauffeur';
  bool get isAirport => widget.serviceType.toLowerCase().contains('airport');
  bool get isOutstation =>
      widget.serviceType.toLowerCase().contains('outstation');
  bool get isAdvance =>
      widget.serviceType.toLowerCase().contains('advance');
  bool get supportsRouteOptions => !isAirport;

  double get fare {
    if (widget.premiumFare != null) {
      return double.tryParse(
            widget.premiumFare!.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          549;
    }
    if (isAirport) return widget.isPremium ? 1299 : 999;
    if (isOutstation) return 1799;
    const Map<int, double> dayRates = <int, double>{
      1: 299,
      2: 349,
      4: 549,
      6: 749,
      8: 949,
      12: 1299,
    };
    return (dayRates[selectedHours] ?? 349) + (widget.isPremium ? 150 : 0);
  }

  String get vehicleType =>
      widget.vehicleData?['vehicleType']?.toString() ?? 'Chauffeur Service';

  @override
  void initState() {
    super.initState();
    selectedHours = widget.selectedHours ?? 2;
    if (![1, 2, 4, 6, 8, 12].contains(selectedHours)) selectedHours = 2;
    if (isAirport) {
      pickup = 'Rajiv Gandhi International Airport, Hyderabad';
    }
  }

  Future<void> _pickLocation({required String field}) async {
    if (isAirport && field == 'pickup') return;

    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => const MapLocationPickerScreen(),
      ),
    );

    if (!mounted || result == null || result.trim().isEmpty) return;
    final value = result.trim();

    setState(() {
      if (field == 'pickup') {
        pickup = value;
      } else if (field == 'drop') {
        drop = value;
      } else {
        final index = int.tryParse(field);
        if (index != null && index >= 0 && index < stops.length) {
          stops[index] = value;
        }
      }
    });
  }

  Future<void> _addStop() async {
    if (stops.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can add up to 4 stops.')),
      );
      return;
    }

    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => const MapLocationPickerScreen(),
      ),
    );

    if (!mounted || result == null || result.trim().isEmpty) return;
    setState(() => stops.add(result.trim()));
  }

  void _removeStop(int index) {
    if (index < 0 || index >= stops.length) return;
    setState(() => stops.removeAt(index));
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

    if ((isAirport || isOutstation || isAdvance) &&
        (scheduledDate == null || scheduledTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select booking date and time.')),
      );
      return;
    }

    if (isNavigating) return;
    setState(() => isNavigating = true);

    final routeLines = <String>[
      'Trip type: $tripType',
      'Pickup: $pickup',
      ...stops.asMap().entries.map(
            (entry) => 'Stop ${entry.key + 1}: ${entry.value}',
          ),
      'Drop: $drop',
      if (tripType == 'Round Trip') 'Return to pickup: $pickup',
    ];

    final schedule = scheduledDate != null && scheduledTime != null
        ? 'Scheduled: ${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year} ${scheduledTime!.format(context)}'
        : '';

    final instructions = [
      routeLines.join(' | '),
      if (schedule.isNotEmpty) schedule,
    ].join(' • ');

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
          selectedHours:
              widget.selectedHours ?? (widget.isPremium ? selectedHours : null),
          specialInstruction: instructions,
        ),
      ),
    );

    if (mounted) setState(() => isNavigating = false);
  }

  Widget _serviceSwitcher() {
    final options = <Map<String, Object>>[
      <String, Object>{
        'title': 'Hourly Driver',
        'subtitle': 'By hour',
        'icon': Icons.access_time_rounded,
        'premium': false,
      },
      <String, Object>{
        'title': 'Airport Transfer',
        'subtitle': 'Airport',
        'icon': Icons.flight_takeoff_rounded,
        'premium': false,
      },
      <String, Object>{
        'title': 'Outstation',
        'subtitle': 'Long distance',
        'icon': Icons.alt_route_rounded,
        'premium': false,
      },
      <String, Object>{
        'title': 'Advance Booking',
        'subtitle': 'Schedule',
        'icon': Icons.calendar_month_rounded,
        'premium': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Services',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: primary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 62,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final option = options[index];
              final title = option['title']! as String;
              final subtitle = option['subtitle']! as String;
              final icon = option['icon']! as IconData;
              final premium = option['premium']! as bool;
              final selected = title == widget.serviceType;

              return InkWell(
                onTap: selected
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => PickupDropScreen(
                              serviceType: title,
                              isPremium: premium,
                              premiumFare: premium ? '₹799' : null,
                              selectedHours: premium ? selectedHours : null,
                              vehicleData: widget.vehicleData,
                            ),
                          ),
                        );
                      },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 132,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: selected ? primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? primary : border,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        icon,
                        size: 20,
                        color: selected ? gold : primary,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected ? Colors.white : primary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _scheduleTile(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Icon(
              fixedAirportPickup
                  ? Icons.lock_rounded
                  : Icons.chevron_right_rounded,
              color: primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationCard({required String field, required String label}) {
    final String value;
    if (field == 'pickup') {
      value = pickup;
    } else if (field == 'drop') {
      value = drop;
    } else {
      final index = int.tryParse(field) ?? -1;
      value = index >= 0 && index < stops.length ? stops[index] : '';
    }

    final hasValue = value.trim().isNotEmpty;

    return InkWell(
      onTap: (isAirport && field == 'pickup') ? null : () => _pickLocation(field: field),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasValue ? primary.withValues(alpha: 0.35) : border,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                field == 'pickup'
                    ? Icons.radio_button_checked_rounded
                    : field == 'drop'
                        ? Icons.location_on_rounded
                        : Icons.add_location_alt_rounded,
                color: field == 'pickup' ? primary : gold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasValue
                        ? value
                        : (isAirport && field == 'pickup')
                            ? 'Rajiv Gandhi International Airport, Hyderabad'
                            : 'Select location on Google Maps',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasValue ? primary : Colors.grey.shade500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              (isAirport && field == 'pickup')
                  ? Icons.lock_rounded
                  : Icons.chevron_right_rounded,
              color: primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tripTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: <Widget>[
          for (final type in const <String>['One Way', 'Round Trip'])
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => tripType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: tripType == type ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tripType == type ? Colors.white : primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stopsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Multiple Stops',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: primary),
              ),
            ),
            Text(
              '${stops.length}/4',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (int index = 0; index < stops.length; index++) ...[
          Row(
            children: <Widget>[
              Expanded(child: _locationCard(field: '$index', label: 'Stop ${index + 1}')),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Remove stop',
                onPressed: () => _removeStop(index),
                icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: _addStop,
          icon: const Icon(Icons.add_location_alt_rounded),
          label: const Text('Add Stop'),
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: BorderSide(color: primary.withValues(alpha: 0.25)),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
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
          labelStyle: TextStyle(
            color: selected ? Colors.white : primary,
            fontWeight: FontWeight.w700,
          ),
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
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[deep, primary],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.directions_car_filled_rounded, color: gold, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('WE DRIVE', style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(widget.serviceType, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    const Text('Select your pickup, stops and drop on the live Google map.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (isPremiumLanding) ...[
          const SizedBox(height: 14),
          _serviceSwitcher(),
          const SizedBox(height: 18),
        ] else
          const SizedBox(height: 14),
        const Text('Pickup & Drop', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: primary)),
        const SizedBox(height: 10),
        _locationCard(field: 'pickup', label: 'Pickup Location'),
        const SizedBox(height: 10),
        if (supportsRouteOptions) ...[
          const Text('Trip Type', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: primary)),
          const SizedBox(height: 8),
          _tripTypeSelector(),
          const SizedBox(height: 14),
        ],
        if (supportsRouteOptions) ...[
          _stopsSection(),
          const SizedBox(height: 14),
        ],
        _locationCard(field: 'drop', label: 'Drop Location'),
        if (widget.isPremium) ...[
          const SizedBox(height: 14),
          const Text('Duration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: primary)),
          const SizedBox(height: 8),
          _hoursSelector(),
        ],
        if (showSchedule) ...[
          const SizedBox(height: 14),
          const Text('Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: primary)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: _scheduleTile(
                  Icons.calendar_today_rounded,
                  'Date',
                  scheduledDate == null
                      ? 'Choose date'
                      : '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}',
                  _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _scheduleTile(
                  Icons.access_time_rounded,
                  'Time',
                  scheduledTime == null ? 'Choose time' : scheduledTime!.format(context),
                  _pickTime,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Estimated fare', style: TextStyle(color: Colors.black54, fontSize: 11)),
                  const SizedBox(height: 5),
                  Text(
                    '$tripType${stops.isEmpty ? '' : ' • ${stops.length} stop${stops.length == 1 ? '' : 's'}'}',
                    style: const TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
              Text('₹${fare.toStringAsFixed(0)}', style: const TextStyle(color: primary, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: isNavigating ? null : _reviewAndBook,
            icon: isNavigating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_forward_rounded),
            label: const Text('Continue to Payment', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.serviceType),
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
      ),
      body: _bookingBody(),
    );
  }
}
