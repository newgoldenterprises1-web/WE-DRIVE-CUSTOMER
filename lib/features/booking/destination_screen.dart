import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'fare_summary_screen.dart';

class DestinationScreen extends StatelessWidget {
  final String pickupLocation;
  final String selectedVehicle;
  final String vehiclePrice;

  const DestinationScreen({
    super.key,
    this.pickupLocation = 'Banjara Hills, Hyderabad',
    this.selectedVehicle = 'Sedan',
    this.vehiclePrice = '₹799',
  });

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Destination",
          style: GoogleFonts.poppins(
            color: primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              _continueToFareSummary(
                context,
                "Hitech City",
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Iconsax.arrow_right_3),
            label: Text(
              "Continue",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Search destination",
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade500,
              ),
              prefixIcon: const Icon(
                Iconsax.search_normal,
                color: primary,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 18,
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
                  color: primary.withValues(alpha: .20),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0F8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.map,
                    size: 60,
                    color: primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Google Maps",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Destination preview",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            "Popular Destinations",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          _DestinationTile(
            icon: Iconsax.airplane,
            title: "Rajiv Gandhi International Airport",
            subtitle: "Shamshabad",
            onTap: () {
              _continueToFareSummary(
                context,
                "Rajiv Gandhi International Airport",
              );
            },
          ),

          _DestinationTile(
            icon: Icons.business_center_rounded,
            title: "Financial District",
            subtitle: "Hyderabad",
            onTap: () {
              _continueToFareSummary(
                context,
                "Financial District",
              );
            },
          ),

          _DestinationTile(
            icon: Icons.local_hospital_rounded,
            title: "Apollo Hospital",
            subtitle: "Jubilee Hills",
            onTap: () {
              _continueToFareSummary(
                context,
                "Apollo Hospital",
              );
            },
          ),

          const SizedBox(height: 24),

          Text(
            "Recent Destinations",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          _DestinationTile(
            icon: Iconsax.clock,
            title: "Hitech City",
            subtitle: "Hyderabad",
            onTap: () {
              _continueToFareSummary(
                context,
                "Hitech City",
              );
            },
          ),

          _DestinationTile(
            icon: Iconsax.clock,
            title: "Banjara Hills",
            subtitle: "Hyderabad",
            onTap: () {
              _continueToFareSummary(
                context,
                "Banjara Hills",
              );
            },
          ),

          _DestinationTile(
            icon: Iconsax.clock,
            title: "Gachibowli",
            subtitle: "Hyderabad",
            onTap: () {
              _continueToFareSummary(
                context,
                "Gachibowli",
              );
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _continueToFareSummary(
    BuildContext context,
    String dropLocation,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FareSummaryScreen(
          pickupLocation: pickupLocation,
          dropLocation: dropLocation,
          selectedVehicle: selectedVehicle,
          vehiclePrice: vehiclePrice,
        ),
      ),
    );
  }
}

class _DestinationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DestinationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const Color primary = Color(0xFF173B6D);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: primary.withValues(alpha: .08),
          child: Icon(
            icon,
            color: primary,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: primary,
        ),
        onTap: onTap,
      ),
    );
  }
}