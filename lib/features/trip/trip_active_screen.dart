import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../trip_started/trip_started_screen.dart';

class TripActiveScreen extends StatelessWidget {
  const TripActiveScreen({
    super.key,
    required this.bookingId,
    required this.pickupLocation,
    required this.dropLocation,
    this.fare = 799.0,
    this.vehicleType = "Car (Manual)",
    this.chauffeurName = "Mohammed Arif",
    this.chauffeurPhone = "+919876543210",
    this.chauffeurRating = 4.9,
  });

  final String bookingId;
  final String pickupLocation;
  final String dropLocation;
  final double fare;
  final String vehicleType;
  final String chauffeurName;
  final String chauffeurPhone;
  final double chauffeurRating;

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  // ==========================================================
  // CALL CHAUFFEUR
  // ==========================================================

  Future<void> _callChauffeur(BuildContext context) async {
    final Uri uri = Uri.parse('tel:$chauffeurPhone');
    try {
      final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open phone dialer.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open phone dialer.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Active Journey",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ==================================================
            // 1. LIVE STATUS BANNER
            // ==================================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF173B6D),
                    Color(0xFF224F8F),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.navigation_rounded,
                      color: gold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "JOURNEY ASSIGNED",
                          style: TextStyle(
                            color: gold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Chauffeur on Standby",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // 2. ROUTE CARD
            // ==================================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Journey Route",
                    style: TextStyle(
                      color: primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _locationRow(
                    icon: Icons.radio_button_checked_rounded,
                    iconColor: primary,
                    title: "Pickup",
                    location: pickupLocation,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 11),
                    child: Container(
                      height: 28,
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  _locationRow(
                    icon: Icons.location_on_rounded,
                    iconColor: gold,
                    title: "Destination",
                    location: dropLocation,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // 3. CHAUFFEUR DETAILS
            // ==================================================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Chauffeur",
                    style: TextStyle(
                      color: primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primary.withOpacity(0.08),
                        child: const Icon(
                          Icons.person_rounded,
                          color: primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chauffeurName,
                              style: const TextStyle(
                                color: primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Verified Executive Chauffeur",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: gold,
                                  size: 16,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  "$chauffeurRating",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _callChauffeur(context),
                        style: IconButton.styleFrom(
                          backgroundColor: primary.withOpacity(0.08),
                        ),
                        icon: const Icon(
                          Icons.call_rounded,
                          color: primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // 4. VEHICLE & TRIP INFO
            // ==================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _infoItem(
                      Icons.route_rounded,
                      "Booking",
                      bookingId.length > 8 ? bookingId.substring(0, 8) : bookingId,
                    ),
                  ),
                  Container(height: 38, width: 1, color: border),
                  Expanded(
                    child: _infoItem(
                      Icons.directions_car_filled_rounded,
                      "Class",
                      vehicleType,
                    ),
                  ),
                  Container(height: 38, width: 1, color: border),
                  Expanded(
                    child: _infoItem(
                      Icons.payments_rounded,
                      "Total Fare",
                      "₹${fare.toStringAsFixed(0)}",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==================================================
            // 5. START / TRACK IN LIVE MAP ACTION
            // ==================================================
            ElevatedButton.icon(
              onPressed: () {
                // Seedhe trip_started folder ki live screen kholega
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TripStartedScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.map_rounded, color: Colors.white, size: 20),
              label: const Text(
                "Open Live Trip Tracking",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  Widget _locationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String location,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                location.isEmpty ? "Location unavailable" : location,
                style: const TextStyle(
                  color: primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}