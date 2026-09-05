import 'package:flutter/material.dart';
import 'booking_summary_screen.dart';

class ServiceSelectionScreen extends StatefulWidget {
  const ServiceSelectionScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
  });

  final String pickupLocation;
  final String dropLocation;

  @override
  State<ServiceSelectionScreen> createState() =>
      _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState
    extends State<ServiceSelectionScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  int selectedIndex = 0;

  final List<Map<String, dynamic>> services = [
    {
      "title": "Hourly Driver",
      "subtitle": "Book a chauffeur by the hour",
      "icon": Icons.access_time_rounded,
    },
    {
      "title": "Airport Chauffeur",
      "subtitle": "Professional airport transfer",
      "icon": Icons.flight_takeoff_rounded,
    },
    {
      "title": "Outstation Chauffeur",
      "subtitle": "Professional long-distance driver",
      "icon": Icons.directions_car_rounded,
    },
    {
      "title": "One Way Chauffeur",
      "subtitle": "One-way professional chauffeur",
      "icon": Icons.arrow_forward_rounded,
    },
    {
      "title": "Round Trip Chauffeur",
      "subtitle": "Return journey professional chauffeur",
      "icon": Icons.sync_alt_rounded,
    },
    {
      "title": "Advance Booking",
      "subtitle": "Schedule your chauffeur in advance",
      "icon": Icons.calendar_month_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Select Service"),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Choose Chauffeur Service",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Select the service that best suits your journey.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            ...List.generate(
              services.length,
              (index) {
                final service = services[index];
                final selected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? gold
                            : Colors.grey.shade200,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            service["icon"] as IconData,
                            color: primary,
                            size: 27,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                service["title"] as String,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                service["subtitle"] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 200),
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? primary
                                : Colors.transparent,
                            border: Border.all(
                              color: selected
                                  ? primary
                                  : Colors.grey.shade400,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  color: gold,
                                  size: 16,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingSummaryScreen(
                        serviceName:
                            services[selectedIndex]["title"] as String,
                        pickupLocation: widget.pickupLocation,
                        dropLocation: widget.dropLocation,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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
}