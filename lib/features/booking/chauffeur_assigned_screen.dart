import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChauffeurAssignedScreen extends StatelessWidget {
  const ChauffeurAssignedScreen({
    super.key,
    required this.bookingId,
    required this.pickupLocation,
    required this.dropLocation,
  });

  final String bookingId;
  final String pickupLocation;
  final String dropLocation;

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  // ==========================================================
  // CALL CHAUFFEUR
  // ==========================================================

  Future<void> _callChauffeur(
    BuildContext context,
  ) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: '9876543210',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

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
  // MESSAGE CHAUFFEUR
  // ==========================================================

  Future<void> _messageChauffeur(
    BuildContext context,
  ) async {
    final Uri uri = Uri(
      scheme: 'sms',
      path: '9876543210',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open messaging app.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open messaging app.'),
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
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Chauffeur Assigned",
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
            // CHAUFFEUR CARD
            // ==================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 52,
                      color: primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Chauffeur Assigned",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Your chauffeur is ready for your trip",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Divider(),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFEAF0F7),
                        child: Icon(
                          Icons.person_rounded,
                          color: primary,
                          size: 30,
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primary,
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
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: gold,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "4.9",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // CHAUFFEUR DETAILS
            // ==================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chauffeur Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _detailRow(
                    Icons.verified_user_rounded,
                    "Verification",
                    "Verified Chauffeur",
                  ),

                  const Divider(height: 26),

                  _detailRow(
                    Icons.work_history_rounded,
                    "Experience",
                    "5+ Years",
                  ),

                  const Divider(height: 26),

                  _detailRow(
                    Icons.star_rounded,
                    "Rating",
                    "4.9 / 5.0",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // PICKUP & DROP
            // ==================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trip Route",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _locationRow(
                    icon: Icons.my_location_rounded,
                    color: Colors.green,
                    title: "Pickup",
                    location: pickupLocation,
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.only(left: 10),
                    child: Container(
                      height: 30,
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),

                  _locationRow(
                    icon: Icons.location_on_rounded,
                    color: Colors.red,
                    title: "Destination",
                    location: dropLocation,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // BOOKING ID
            // ==================================================

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_number_rounded,
                    color: primary,
                    size: 22,
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "Booking ID",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const Spacer(),

                  Flexible(
                    child: Text(
                      bookingId,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // PICKUP STATUS
            // ==================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: gold,
                    size: 28,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pickup Status",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Your chauffeur is heading to your pickup location.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
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
            // CALL + MESSAGE
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _callChauffeur(context);
                      },
                      icon: const Icon(
                        Icons.call_rounded,
                        size: 20,
                      ),
                      label: const Text("Call"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: const BorderSide(
                          color: primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _messageChauffeur(context);
                      },
                      icon: const Icon(
                        Icons.chat_rounded,
                        size: 20,
                      ),
                      label: const Text("Message"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: const BorderSide(
                          color: primary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DETAIL ROW
  // ==========================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: primary,
          size: 23,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),

        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // LOCATION ROW
  // ==========================================================

  Widget _locationRow({
    required IconData icon,
    required Color color,
    required String title,
    required String location,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),

        const SizedBox(width: 12),

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