import 'package:flutter/material.dart';

class PremiumAssignedScreen extends StatelessWidget {
  const PremiumAssignedScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    this.serviceType = "Hourly",
    this.fare = "₹799/hr",
  });

  final String pickupLocation;
  final String dropLocation;
  final String serviceType;
  final String fare;

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FA);

  void _contactChauffeur(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Calling premium chauffeur..."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _messageChauffeur(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Opening chat with chauffeur..."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Premium Chauffeur Assigned",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _successCard(),

            const SizedBox(height: 20),

            _chauffeurCard(context),

            const SizedBox(height: 18),

            _routeCard(),

            const SizedBox(height: 18),

            _bookingCard(),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _messageChauffeur(context),
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        "Message",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _contactChauffeur(context),
                      icon: const Icon(
                        Icons.phone_rounded,
                        size: 20,
                      ),
                      label: const Text(
                        "Contact Chauffeur",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(17),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: gold.withValues(alpha: .25),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: gold,
                    size: 25,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Your premium chauffeur has been specially selected for this booking.",
                      style: TextStyle(
                        color: primary,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _successCard() {
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
            radius: 31,
            backgroundColor: gold,
            child: Icon(
              Icons.check_rounded,
              color: primary,
              size: 38,
            ),
          ),

          SizedBox(height: 15),

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
            "Your premium chauffeur is ready for your trip.",
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

  Widget _chauffeurCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 16,
            offset: const Offset(0, 7),
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
                    Row(
                      children: [
                        Text(
                          "Rahul Sharma",
                          style: TextStyle(
                            color: primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 7),
                        Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF22A06B),
                          size: 18,
                        ),
                      ],
                    ),

                    SizedBox(height: 6),

                    Text(
                      "Premium Chauffeur",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),

                    SizedBox(height: 7),

                    Row(
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
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "• 248 trips",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: gold,
                  size: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Verified • Background Checked • Premium Rated",
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
            iconColor: Colors.green,
            title: "Pickup",
            location: pickupLocation,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              height: 28,
              width: 2,
              color: Colors.grey.shade300,
            ),
          ),

          _locationRow(
            icon: Icons.location_on_rounded,
            iconColor: Colors.red,
            title: "Destination",
            location: dropLocation,
          ),
        ],
      ),
    );
  }

  Widget _locationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String location,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bookingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: gold.withValues(alpha: .30),
        ),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Booking Details",
              style: TextStyle(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 18),

          _infoRow(
            "Service",
            serviceType,
          ),

          const Divider(height: 24),

          _infoRow(
            "Distance",
            "18 km",
          ),

          const Divider(height: 24),

          _infoRow(
            "Estimated Time",
            "35 mins",
          ),

          const Divider(height: 24),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Premium Fare",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                fare,
                style: const TextStyle(
                  color: primary,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}