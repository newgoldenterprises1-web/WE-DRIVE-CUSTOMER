import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/location_service.dart';
import 'map_location_picker_screen.dart';

class PickupLocationScreen extends StatefulWidget {
  const PickupLocationScreen({super.key});

  @override
  State<PickupLocationScreen> createState() => _PickupLocationScreenState();
}

class _PickupLocationScreenState extends State<PickupLocationScreen> {
  static const Color accent = Color(0xFF19A8A3);
  static const Color background = Color(0xFFF5F9F8);
  static const Color dark = Color(0xFF243238);

  final TextEditingController searchController = TextEditingController();
  bool _detectingLocation = false;
  String? _detectedLocation;

  final List<Map<String, dynamic>> recentLocations = [
    {'title': 'Home', 'subtitle': 'Banjara Hills, Hyderabad', 'icon': Icons.home_rounded, 'color': const Color(0xFF2E9F73)},
    {'title': 'Office', 'subtitle': 'Hitech City, Hyderabad', 'icon': Icons.business_rounded, 'color': const Color(0xFFE08A36)},
    {'title': 'Airport', 'subtitle': 'Rajiv Gandhi International Airport', 'icon': Icons.flight_takeoff_rounded, 'color': const Color(0xFF4C86D8)},
    {'title': 'Railway Station', 'subtitle': 'Secunderabad Junction', 'icon': Icons.train_rounded, 'color': const Color(0xFFD65C5C)},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectCurrentLocation(showError: false);
    });
  }

  Future<String?> _detectCurrentLocation({bool showError = true}) async {
    if (_detectingLocation) return _detectedLocation;
    setState(() => _detectingLocation = true);
    String? address;
    try {
      address = await LocationService.getCurrentAddress();
    } catch (_) {
      address = null;
    }
    if (!mounted) return address;
    final cleaned = address?.trim();
    setState(() {
      _detectingLocation = false;
      if (cleaned != null && cleaned.isNotEmpty) _detectedLocation = cleaned;
    });
    if ((cleaned == null || cleaned.isEmpty) && showError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to detect your location. Please allow location permission and try again.')),
      );
    }
    return cleaned;
  }

  Future<void> _useCurrentLocation() async {
    final location = await _detectCurrentLocation();
    if (!mounted || location == null || location.trim().isEmpty) return;
    Navigator.pop(context, location.trim());
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(builder: (_) => const MapLocationPickerScreen()),
    );
    if (!mounted || result == null || result.trim().isEmpty) return;
    Navigator.pop(context, result.trim());
  }

  void _selectLocation(String location) {
    final value = location.trim();
    if (value.isNotEmpty) Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: dark, size: 20),
        ),
        title: Text('Pickup Location', style: GoogleFonts.poppins(color: dark, fontWeight: FontWeight.w700, fontSize: 21)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) _selectLocation(value);
              },
              decoration: InputDecoration(
                hintText: 'Search pickup location...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: const Icon(Iconsax.search_normal_1, color: accent),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
              ),
            ).animate().fade(duration: 250.ms),
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _openMapPicker,
                child: Ink(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF174C52), Color(0xFF19A8A3)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 6))],
                  ),
                  child: const Row(
                    children: [
                      Icon(Iconsax.map_1, color: Colors.white, size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Select Pickup on Google Maps', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                            SizedBox(height: 4),
                            Text('Use the live map, move the pin and confirm the exact pickup point.', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ).animate().fade(delay: 80.ms).slideY(begin: -.05),
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _useCurrentLocation,
                child: Ink(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.14)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(color: accent.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(16)),
                        child: _detectingLocation
                            ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2.3, color: accent))
                            : const Icon(Icons.my_location_rounded, color: accent),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_detectingLocation ? 'Detecting Current Location' : 'Use Current Location', style: GoogleFonts.poppins(color: dark, fontSize: 15.5, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(_detectingLocation ? 'Please wait...' : (_detectedLocation ?? 'Detect automatically using GPS'), maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      const Icon(Iconsax.arrow_right_3, color: accent),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Recent Locations', style: GoogleFonts.poppins(color: dark, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 13),
            ...recentLocations.map((item) {
              final color = item['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _selectLocation(item['subtitle'] as String),
                    child: Ink(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.035))),
                      child: Row(
                        children: [
                          Container(height: 54, width: 54, decoration: BoxDecoration(color: color.withValues(alpha: 0.11), borderRadius: BorderRadius.circular(16)), child: Icon(item['icon'] as IconData, color: color, size: 26)),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item['title'] as String, style: GoogleFonts.poppins(color: dark, fontSize: 15.5, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(item['subtitle'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12.5))])),
                          const Icon(Iconsax.arrow_right_3, color: accent, size: 19),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
