import 'package:flutter/material.dart';

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({
    super.key,
    required this.onHourlyTap,
    required this.onAirportTap,
    required this.onOutstationTap,
    required this.onAdvanceTap,
  });

  final VoidCallback onHourlyTap;
  final VoidCallback onAirportTap;
  final VoidCallback onOutstationTap;
  final VoidCallback onAdvanceTap;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Services",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: [
              _serviceCard(
                icon: Icons.schedule,
                title: "Hourly Driver",
                subtitle: "Book by hour",
                onTap: onHourlyTap,
              ),
              _serviceCard(
                icon: Icons.flight_takeoff,
                title: "Airport",
                subtitle: "Airport pickup",
                onTap: onAirportTap,
              ),
              _serviceCard(
                icon: Icons.route,
                title: "Outstation",
                subtitle: "Long distance",
                onTap: onOutstationTap,
              ),
              _serviceCard(
                icon: Icons.calendar_month,
                title: "Advance",
                subtitle: "Schedule ride",
                onTap: onAdvanceTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}