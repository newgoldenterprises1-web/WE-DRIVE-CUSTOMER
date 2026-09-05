import 'package:flutter/material.dart';

class TripActiveScreen extends StatefulWidget {
  const TripActiveScreen({
    super.key,
    this.bookingId = '',
    this.pickupLocation = 'Your Pickup Location',
    this.dropLocation = 'Your Drop Location',
  });

  final String bookingId;
  final String pickupLocation;
  final String dropLocation;

  @override
  State<TripActiveScreen> createState() =>
      _TripActiveScreenState();
}

class _TripActiveScreenState extends State<TripActiveScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FA);

  bool tripStarted = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Trip Active",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ==================================================
            // ACTIVE TRIP HEADER
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary,
                    Color(0xFF1D4A84),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: .20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: gold,
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: primary,
                      size: 38,
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    "Your Trip is Active",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Your chauffeur is driving you to your destination.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // DRIVER CARD
            // ==================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 15,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: .08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: primary,
                          size: 38,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rahul Sharma",
                              style: TextStyle(
                                color: primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Professional Chauffeur",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),

                            SizedBox(height: 5),

                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: gold,
                                  size: 17,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "4.9 Rating",
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22A06B)
                              .withValues(alpha: .10),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "ON TRIP",
                          style: TextStyle(
                            color: Color(0xFF16845A),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: gold,
                          size: 23,
                        ),

                        SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            "Your verified chauffeur is currently driving your trip.",
                            style: TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // TRIP ROUTE
            // ==================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trip Route",
                    style: TextStyle(
                      color: primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _locationRow(
                    icon: Icons.radio_button_checked,
                    iconColor: Colors.green,
                    title: "Pickup",
                    location: widget.pickupLocation,
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10),
                    child: Container(
                      height: 32,
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),

                  _locationRow(
                    icon: Icons.location_on_rounded,
                    iconColor: Colors.red,
                    title: "Destination",
                    location: widget.dropLocation,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // LIVE TRIP STATUS
            // ==================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.navigation_rounded,
                        color: gold,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Trip Status",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18),

                  Text(
                    "On the way to destination",
                    style: TextStyle(
                      color: gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 7),

                  Text(
                    "Estimated arrival: 35 mins",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // FARE
            // ==================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: gold.withValues(alpha: .30),
                ),
              ),
              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Estimated Fare",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  Text(
                    "₹850",
                    style: TextStyle(
                      color: primary,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // CANCEL / SUPPORT
            // ==================================================

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "WE DRIVE support will be available soon.",
                      ),
                      behavior:
                          SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.support_agent_rounded,
                ),
                label: const Text(
                  "Need Help?",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(
                    color: primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(17),
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

  // ==========================================================
  // LOCATION ROW
  // ==========================================================

  Widget _locationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String location,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 22,
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                location,
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

}
