import 'package:flutter/material.dart';

import 'premium_find_chauffeur_screen.dart';

class PremiumBookingSummaryScreen extends StatelessWidget {
  const PremiumBookingSummaryScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    this.serviceType = "Hourly",
    this.fare = "₹799",
    this.hours = 2,
    this.distance = "18 km",
    this.estimatedTime = "35 mins",
  });

  final String pickupLocation;
  final String dropLocation;
  final String serviceType;
  final String fare;
  final int hours;
  final String distance;
  final String estimatedTime;

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FA);

  void _continue(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PremiumFindChauffeurScreen(
          pickupLocation: pickupLocation,
          dropLocation: dropLocation,
          serviceType: serviceType,
          fare: fare,
        ),
      ),
    );
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
        title: const Text(
          "Premium Booking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _premiumBanner(),

            const SizedBox(height: 20),

            _routeCard(),

            const SizedBox(height: 18),

            _serviceCard(),

            const SizedBox(height: 18),

            _fareCard(),

            const SizedBox(height: 18),

            _premiumBenefits(),

            const SizedBox(height: 28),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _continue(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: gold,
                      size: 23,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Find Premium Chauffeur",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _premiumBanner() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: gold,
                size: 32,
              ),
              SizedBox(width: 10),
              Text(
                "PREMIUM CHAUFFEUR",
                style: TextStyle(
                  color: gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            "Your Premium Booking",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            "A verified, highly-rated chauffeur will be selected specially for your booking.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Trip Route",
            style: TextStyle(
              color: primary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _locationRow(
            icon: Icons.radio_button_checked,
            iconColor: Colors.green,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _serviceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: gold,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Premium Chauffeur",
                  style: TextStyle(
                    color: primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Verified premium service",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            serviceType,
            style: const TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fareCard() {
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
              "Booking Summary",
              style: TextStyle(
                color: primary,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          _summaryRow(
            "Service",
            "Premium Chauffeur",
          ),

          const Divider(height: 24),

          _summaryRow(
            "Distance",
            distance,
          ),

          const Divider(height: 24),

          _summaryRow(
            "Estimated Time",
            estimatedTime,
          ),

          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget _premiumBenefits() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primary.withValues(alpha: .10),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Premium Included",
            style: TextStyle(
              color: primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 14),
          _Benefit(
            text: "Verified & background-checked chauffeur",
          ),
          SizedBox(height: 10),
          _Benefit(
            text: "Highly-rated professional driver",
          ),
          SizedBox(height: 10),
          _Benefit(
            text: "Priority premium chauffeur matching",
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.text,
  });

  final String text;

  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: gold,
          size: 19,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}