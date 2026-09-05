import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../services/location_service.dart';

class PickupLocationScreen extends StatefulWidget {
  const PickupLocationScreen({super.key});

  @override
  State<PickupLocationScreen> createState() =>
      _PickupLocationScreenState();
}

class _PickupLocationScreenState extends State<PickupLocationScreen> {
  static const Color accent = Color(0xFF19A8A3);
  static const Color background = Color(0xFFF5F9F8);
  static const Color dark = Color(0xFF243238);

  final TextEditingController searchController =
      TextEditingController();

  bool _detectingLocation = false;
  String? _detectedLocation;

  final List<Map<String, dynamic>> recentLocations = [
    {
      'title': 'Home',
      'subtitle': 'Banjara Hills, Hyderabad',
      'icon': Icons.home_rounded,
      'color': const Color(0xFF2E9F73),
    },
    {
      'title': 'Office',
      'subtitle': 'Hitech City, Hyderabad',
      'icon': Icons.business_rounded,
      'color': const Color(0xFFE08A36),
    },
    {
      'title': 'Airport',
      'subtitle': 'Rajiv Gandhi International Airport',
      'icon': Icons.flight_takeoff_rounded,
      'color': const Color(0xFF4C86D8),
    },
    {
      'title': 'Railway Station',
      'subtitle': 'Secunderabad Junction',
      'icon': Icons.train_rounded,
      'color': const Color(0xFFD65C5C),
    },
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectCurrentLocation(showError: false);
    });
  }

  Future<String?> _detectCurrentLocation({
    bool showError = true,
  }) async {
    if (_detectingLocation) {
      return _detectedLocation;
    }

    setState(() {
      _detectingLocation = true;
    });

    String? address;

    try {
      address = await LocationService.getCurrentAddress();
    } catch (_) {
      address = null;
    }

    if (!mounted) return address;

    final cleanedAddress = address?.trim();

    setState(() {
      _detectingLocation = false;

      if (cleanedAddress != null &&
          cleanedAddress.isNotEmpty) {
        _detectedLocation = cleanedAddress;
      }
    });

    if (cleanedAddress == null ||
        cleanedAddress.isEmpty) {
      if (showError) {
        _showLocationError();
      }
      return null;
    }

    return cleanedAddress;
  }

  Future<void> _useCurrentLocation() async {
    if (_detectingLocation) return;

    final location = await _detectCurrentLocation();

    if (!mounted) return;

    if (location != null &&
        location.trim().isNotEmpty) {
      Navigator.pop(context, location.trim());
    }
  }

  void _showLocationError() {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: dark,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.location_off_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Unable to detect your location. Please allow location permission and try again.',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _selectLocation(String location) {
    final value = location.trim();

    if (value.isEmpty) return;

    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: dark,
            size: 20,
          ),
        ),
        title: Text(
          'Pickup Location',
          style: GoogleFonts.poppins(
            color: dark,
            fontWeight: FontWeight.w700,
            fontSize: 21,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                0,
              ),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _selectLocation(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search pickup location...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Iconsax.search_normal_1,
                    color: accent,
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Voice search',
                    onPressed: () {},
                    icon: const Icon(
                      Iconsax.microphone_2,
                      color: dark,
                      size: 21,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 17,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: accent.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fade(duration: 300.ms)
                .slideY(begin: -.08),

            const SizedBox(height: 18),

            // CURRENT LOCATION
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: _useCurrentLocation,
                  child: Ink(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Color(0xFFF0FAF8),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(22),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              accent.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color:
                                accent.withValues(alpha: 0.11),
                            borderRadius:
                                BorderRadius.circular(17),
                          ),
                          child: _detectingLocation
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: accent,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location_rounded,
                                  color: accent,
                                  size: 25,
                                ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _detectingLocation
                                    ? 'Detecting Current Location'
                                    : 'Use Current Location',
                                style: GoogleFonts.poppins(
                                  color: dark,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _detectingLocation
                                    ? 'Please wait while we find you...'
                                    : (_detectedLocation ??
                                        'Detect automatically using GPS'),
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: _detectedLocation != null
                                      ? dark
                                      : Colors.grey.shade600,
                                  fontSize: 12.5,
                                  fontWeight:
                                      _detectedLocation != null
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            color:
                                accent.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.arrow_right_3,
                            color: accent,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fade(delay: 120.ms)
                .slideX(begin: -.10),

            const SizedBox(height: 24),

            // RECENT LOCATIONS TITLE
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Locations',
                  style: GoogleFonts.poppins(
                    color: dark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 13),

            // RECENT LOCATIONS
            Expanded(
              child: ListView.separated(
                physics:
                    const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  24,
                ),
                itemCount: recentLocations.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = recentLocations[index];

                  final itemColor =
                      item['color'] as Color;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(21),
                      onTap: () {
                        _selectLocation(
                          item['subtitle'] as String,
                        );
                      },
                      child: Ink(
                        padding:
                            const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(21),
                          border: Border.all(
                            color:
                                Colors.black.withValues(
                              alpha: 0.035,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(
                                alpha: 0.035,
                              ),
                              blurRadius: 16,
                              offset:
                                  const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              decoration:
                                  BoxDecoration(
                                color:
                                    itemColor.withValues(
                                  alpha: 0.11,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  17,
                                ),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: itemColor,
                                size: 27,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    item['title']
                                        as String,
                                    style:
                                        GoogleFonts.poppins(
                                      color: dark,
                                      fontSize: 15.5,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    item['subtitle']
                                        as String,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        GoogleFonts.poppins(
                                      color: Colors
                                          .grey.shade600,
                                      fontSize: 12.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Icon(
                              Iconsax.arrow_right_3,
                              color: accent,
                              size: 19,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fade(
                        delay: Duration(
                          milliseconds:
                              180 + (index * 100),
                        ),
                      )
                      .slideX(begin: .10);
                },
              ),
            ),
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
