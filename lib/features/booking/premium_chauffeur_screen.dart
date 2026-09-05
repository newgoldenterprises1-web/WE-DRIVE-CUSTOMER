import 'package:flutter/material.dart';

import 'pickup_drop_screen.dart';

class PremiumChauffeurScreen extends StatefulWidget {
  const PremiumChauffeurScreen({super.key});

  @override
  State<PremiumChauffeurScreen> createState() =>
      _PremiumChauffeurScreenState();
}

class _PremiumChauffeurScreenState
    extends State<PremiumChauffeurScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FA);

  String selectedService = "Hourly";
  int selectedHours = 2;

  final int totalDrivers = 10;
  final int availableDrivers = 6;

  int get bookedDrivers => totalDrivers - availableDrivers;

  final Map<String, Map<String, String>> pricing = {
    "Hourly": {
      "price": "₹799/hr",
      "normal": "₹499/hr",
    },
    "Airport": {
      "price": "₹1,299",
      "normal": "₹899",
    },
    "Outstation": {
      "price": "₹28/km",
      "normal": "₹18/km",
    },
    "Advance": {
      "price": "₹899/hr",
      "normal": "₹599/hr",
    },
  };

  void continuePremiumBooking() {
    final current = pricing[selectedService]!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupDropScreen(
          isPremium: true,
          serviceType: selectedService,
          premiumFare: current["price"]!,
          selectedHours:
              selectedService == "Hourly" ? selectedHours : 2,
        ),
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
        title: const Text(
          "Premium Chauffeur",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _premiumHero(),
              const SizedBox(height: 20),
              _availabilityCard(),
              const SizedBox(height: 26),

              const Text(
                "Choose Service",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),

              const SizedBox(height: 14),
              _serviceSelector(),

              // HOURS ONLY FOR HOURLY
              if (selectedService == "Hourly") ...[
                const SizedBox(height: 22),

                const Text(
                  "Select Hours",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),

                const SizedBox(height: 12),

                _hoursSelector(),
              ],

              const SizedBox(height: 24),
              _premiumPriceCard(),

              const SizedBox(height: 22),
              _premiumBenefits(),

              const SizedBox(height: 26),
              _continueButton(),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  "Premium chauffeurs are subject to availability",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumHero() {
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
            offset: const Offset(0, 9),
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
                size: 30,
              ),
              SizedBox(width: 12),
              Text(
                "WE DRIVE PREMIUM",
                style: TextStyle(
                  color: gold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Text(
            "Premium Chauffeur",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "A carefully selected chauffeur experience for customers who expect premium service.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityCard() {
    final ratio =
        availableDrivers / totalDrivers;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          const Row(
            children: [
              Icon(
                Icons.speed_rounded,
                color: primary,
                size: 23,
              ),
              SizedBox(width: 9),
              Text(
                "Premium Availability",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _availabilityItem(
                  value: "$availableDrivers",
                  label: "Available",
                  color: const Color(0xFF22A06B),
                ),
              ),
              _divider(),
              Expanded(
                child: _availabilityItem(
                  value: "$bookedDrivers",
                  label: "Booked",
                  color: const Color(0xFFE05252),
                ),
              ),
              _divider(),
              Expanded(
                child: _availabilityItem(
                  value: "$totalDrivers",
                  label: "Total",
                  color: gold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor:
                  const Color(0xFFE5E7EB),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Color(0xFF22A06B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          Icons.circle,
          color: color,
          size: 10,
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 48,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _serviceSelector() {
    const services = [
      "Hourly",
      "Airport",
      "Outstation",
      "Advance",
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final service = services[index];
          final selected =
              selectedService == service;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedService = service;

                if (service != "Hourly") {
                  selectedHours = 2;
                }
              });
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 19,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    selected ? primary : Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? primary
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                service,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _hoursSelector() {
    const hours = [2, 4, 6, 8, 12];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: hours.map((hour) {
        final selected =
            selectedHours == hour;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedHours = hour;
            });
          },
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color:
                  selected ? primary : Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? gold
                    : Colors.grey.shade200,
                width: selected ? 2 : 1,
              ),
            ),
            child: Text(
              "$hour Hours",
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _premiumPriceCard() {
    final current = pricing[selectedService]!;

    final price = selectedService == "Hourly"
        ? "₹${799 * selectedHours}"
        : current["price"]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: gold.withValues(alpha: .35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.workspace_premium_rounded,
            color: gold,
            size: 30,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Premium Rate",
                  style: TextStyle(
                    color: primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  price,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumBenefits() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "Premium Experience",
            style: TextStyle(
              color: primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 14),
          Text(
            "✓ Verified and background-checked chauffeur",
            style: TextStyle(color: Color(0xFF4B5563)),
          ),
          SizedBox(height: 10),
          Text(
            "✓ Highly-rated experienced professional",
            style: TextStyle(color: Color(0xFF4B5563)),
          ),
          SizedBox(height: 10),
          Text(
            "✓ Priority access to premium chauffeurs",
            style: TextStyle(color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 57,
      child: ElevatedButton(
        onPressed: availableDrivers > 0
            ? continuePremiumBooking
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
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
              Icons.workspace_premium_rounded,
              color: gold,
            ),
            SizedBox(width: 9),
            Text(
              "Continue with Premium",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}