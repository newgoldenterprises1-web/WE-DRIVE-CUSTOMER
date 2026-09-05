import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'map_location_picker_screen.dart';

class DestinationLocationScreen extends StatefulWidget {
  const DestinationLocationScreen({super.key});

  @override
  State<DestinationLocationScreen> createState() =>
      _DestinationLocationScreenState();
}

class _DestinationLocationScreenState
    extends State<DestinationLocationScreen> {
  static const Color primary = Color(0xFF2563EB);
  static const Color background = Color(0xFFF8FAFC);
  static const Color dark = Color(0xFF172033);

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> destinations = [
    {
      'title': 'Rajiv Gandhi International Airport',
      'subtitle': 'Shamshabad, Hyderabad',
      'icon': Iconsax.airplane,
      'color': Colors.blue,
    },
    {
      'title': 'Hitech City',
      'subtitle': 'Madhapur, Hyderabad',
      'icon': Iconsax.buildings,
      'color': Colors.deepPurple,
    },
    {
      'title': 'Secunderabad Railway Station',
      'subtitle': 'Secunderabad',
      'icon': Icons.directions_railway,
      'color': Colors.orange,
    },
    {
      'title': 'Charminar',
      'subtitle': 'Old City, Hyderabad',
      'icon': Iconsax.location,
      'color': Colors.green,
    },
    {
      'title': 'Inorbit Mall',
      'subtitle': 'Madhapur, Hyderabad',
      'icon': Iconsax.shop,
      'color': Colors.red,
    },
    {
      'title': 'Gachibowli',
      'subtitle': 'Financial District',
      'icon': Iconsax.building,
      'color': Colors.teal,
    },
  ];

  List<Map<String, dynamic>> get filteredList {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return destinations;
    }

    return destinations.where((item) {
      final title = item['title'].toString().toLowerCase();
      final subtitle = item['subtitle'].toString().toLowerCase();

      return title.contains(query) || subtitle.contains(query);
    }).toList();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const MapLocationPickerScreen(),
      ),
    );

    if (!mounted || result == null || result.trim().isEmpty) {
      return;
    }

    Navigator.pop(context, result.trim());
  }

  void _selectDestination(String value) {
    final destination = value.trim();

    if (destination.isEmpty) {
      return;
    }

    Navigator.pop(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: dark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Iconsax.arrow_left,
            color: dark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Destination',
          style: GoogleFonts.poppins(
            color: dark,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _openMapPicker,
                  child: Ink(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.035),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Iconsax.map_1,
                            color: primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Drop Location on Map',
                                style: GoogleFonts.poppins(
                                  color: dark,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Choose the exact destination on the map',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Iconsax.arrow_right_3,
                          color: primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fade(duration: 250.ms)
                .slideY(begin: -.08),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: TextField(
                controller: searchController,
                onChanged: (_) {
                  setState(() {});
                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search destination...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 13.5,
                  ),
                  prefixIcon: const Icon(
                    Iconsax.search_normal,
                    color: primary,
                  ),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.grey,
                          ),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: primary.withValues(alpha: 0.20),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Iconsax.location_cross,
                                color: primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No destination found',
                              style: GoogleFonts.poppins(
                                color: dark,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Try another search or choose a location from the map.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _openMapPicker,
                              icon: const Icon(Iconsax.map_1),
                              label: const Text('Select on Map'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primary,
                                side: BorderSide(
                                  color: primary.withValues(alpha: 0.22),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        20,
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final itemColor = item['color'] as Color;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                _selectDestination(
                                  item['title'].toString(),
                                );
                              },
                              child: Ink(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        Colors.black.withValues(alpha: 0.03),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.035),
                                      blurRadius: 12,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 56,
                                      width: 56,
                                      decoration: BoxDecoration(
                                        color:
                                            itemColor.withValues(alpha: 0.11),
                                        borderRadius:
                                            BorderRadius.circular(17),
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
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'].toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: dark,
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['subtitle'].toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey.shade600,
                                              fontSize: 12.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Iconsax.arrow_right_3,
                                      color: primary,
                                      size: 19,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fade(
                              delay: Duration(
                                milliseconds: 100 + (index * 80),
                              ),
                            )
                            .slideX(begin: .08);
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