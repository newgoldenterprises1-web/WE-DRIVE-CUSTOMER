import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'booking_review_screen.dart';

class FareSummaryScreen extends StatelessWidget {
  final String pickupLocation;
  final String dropLocation;
  final String selectedVehicle;
  final String vehiclePrice;

  const FareSummaryScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.selectedVehicle,
    required this.vehiclePrice,
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
          "Fare Summary",
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
            /// Vehicle Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Iconsax.car,
                            color: primary,
                            size: 34,
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedVehicle,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Premium Chauffeur",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.orange,
                                    size: 17,
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    "4 mins",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(width: 18),

                                  const Icon(
                                    Icons.people_outline,
                                    size: 17,
                                    color: primary,
                                  ),

                                  const SizedBox(width: 5),

                                  Text(
                                    "4 Seats",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Estimated Total",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  "₹1,280",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Iconsax.wallet_2,
                            color: gold,
                            size: 38,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Fare Breakdown
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Iconsax.receipt_item,
                          color: primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Fare Breakdown",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _fareRow("Base Fare", "₹800"),
                    _fareRow("Distance Charges", "₹250"),
                    _fareRow("Time Charges", "₹100"),
                    _fareRow("Platform Fee", "₹50"),
                    _fareRow("GST", "₹80"),

                    const Divider(height: 30),

                    _fareRow(
                      "Estimated Total",
                      "₹1,280",
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Payment Method
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Iconsax.wallet_2,
                          color: primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Payment Method",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: .06),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: primary.withValues(alpha: .15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.payments_rounded,
                              color: Colors.green,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cash Payment",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  "Pay directly to your chauffeur",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Information Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: primary,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "Estimated fare may vary depending on traffic, waiting time and route changes.",
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

            /// Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingReviewScreen(
                        pickupLocation: pickupLocation,
                        dropLocation: dropLocation,
                        selectedVehicle: selectedVehicle,
                        totalFare: 1280,
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
                  "Continue",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

  Widget _fareRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isTotal ? 16 : 14,
                fontWeight:
                    isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal ? primary : Colors.black87,
              ),
            ),
          ),

          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 15,
              fontWeight:
                  isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}