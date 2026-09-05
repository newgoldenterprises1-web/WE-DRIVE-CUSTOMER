import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'driver_searching_screen.dart';

class BookingReviewScreen extends StatelessWidget {
  final String pickupLocation;
  final String dropLocation;
  final String selectedVehicle;
  final int totalFare;

  const BookingReviewScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.selectedVehicle,
    required this.totalFare,
  });

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
          "Booking Review",
          style: GoogleFonts.poppins(
            color: primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons.location_on,
                    Colors.green,
                    "Pickup",
                    pickupLocation,
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    Icons.flag,
                    Colors.red,
                    "Destination",
                    dropLocation,
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    Iconsax.car,
                    primary,
                    "Vehicle",
                    selectedVehicle,
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    Icons.person,
                    gold,
                    "Chauffeur",
                    "Professional Driver",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons.calendar_today_rounded,
                    primary,
                    "Date",
                    "Today",
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    Icons.access_time_rounded,
                    Colors.orange,
                    "Time",
                    "Now",
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    Icons.payments_rounded,
                    Colors.green,
                    "Payment",
                    "Cash",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF173B6D),
                    Color(0xFF0F2747),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Fare",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "₹$totalFare",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Iconsax.wallet_2,
                    color: gold,
                    size: 40,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "By confirming this booking, you agree to our Terms & Conditions and Privacy Policy.",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverSearchingScreen(
                        pickupLocation: pickupLocation,
                        dropLocation: dropLocation,
                        selectedVehicle: selectedVehicle,
                        totalFare: totalFare,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  "CONFIRM BOOKING",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    Color iconColor,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}