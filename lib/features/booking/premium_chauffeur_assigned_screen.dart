import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class PremiumChauffeurAssignedScreen extends StatelessWidget {
  const PremiumChauffeurAssignedScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.serviceType,
    required this.fare,
  });

  final String pickupLocation;
  final String dropLocation;
  final String serviceType;
  final String fare;

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FA);

  Future<void> _contactChauffeur(
    BuildContext context,
  ) async {
    const String chauffeurPhone = "9876543210";

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: chauffeurPhone,
    );

    try {
      final bool launched = await launchUrl(
        phoneUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Unable to open phone dialer.",
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to contact chauffeur.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
          "Premium Chauffeur",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
          children: [
            _successHeader(),

            const SizedBox(height: 20),

            _chauffeurCard(),

            const SizedBox(height: 20),

            _routeCard(),

            const SizedBox(height: 20),

            _bookingSummary(),

            const SizedBox(height: 24),

            _callButton(context),

            const SizedBox(height: 12),

            _continueButton(context),
          ],
        ),
      ),
    );
  }

  Widget _successHeader() {
    return Container(
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
            radius: 32,
            backgroundColor: gold,
            child: Icon(
              Icons.check_rounded,
              color: primary,
              size: 38,
            ),
          ),

          SizedBox(height: 16),

          Text(
            "Premium Chauffeur Assigned",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 7),

          Text(
            "Your verified premium chauffeur is on the way.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chauffeurCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: gold.withValues(alpha: .30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 68,
                width: 68,
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

              const SizedBox(width: 15),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rahul Sharma",
                      style: TextStyle(
                        color: primary,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Premium Chauffeur",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: gold,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "4.9 • 500+ Trips",
                          style: TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22A06B)
                      .withValues(alpha: .10),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Text(
                  "VERIFIED",
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: gold,
                  size: 23,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Premium verified professional selected for your booking",
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
    );
  }

  Widget _routeCard() {
    return Container(
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

          const SizedBox(height: 18),

          _locationRow(
            icon: Icons.radio_button_checked,
            color: Colors.green,
            title: "Pickup",
            location: pickupLocation,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10),
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
    );
  }

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

  Widget _bookingSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Text(
            "Booking Summary",
            style: TextStyle(
              color: primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _summaryRow(
            "Service",
            "$serviceType Premium",
          ),

          const Divider(height: 25),

          _summaryRow(
            "Chauffeur",
            "Rahul Sharma",
          ),

          const Divider(height: 25),

          _summaryRow(
            "Estimated Fare",
            fare,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: primary,
              fontSize: 14,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _callButton(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _contactChauffeur(context);
        },
        icon: const Icon(
          Icons.phone_rounded,
          color: primary,
        ),
        label: const Text(
          "Contact Chauffeur",
          style: TextStyle(
            color: primary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _continueButton(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.popUntil(
            context,
            (route) => route.isFirst,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primary,
          elevation: 0,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_rounded,
              size: 21,
            ),
            SizedBox(width: 9),
            Text(
              "Back to Home",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}