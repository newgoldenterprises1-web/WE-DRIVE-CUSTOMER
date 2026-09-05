import 'package:flutter/material.dart';

class SearchingDriverScreen extends StatefulWidget {
  const SearchingDriverScreen({super.key});

  // WE DRIVE Brand Theme Colors
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF6F8FC);
  static const Color white = Color(0xFFFFFFFF);

  @override
  State<SearchingDriverScreen> createState() => _SearchingDriverScreenState();
}

class _SearchingDriverScreenState extends State<SearchingDriverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SearchingDriverScreen.background,
      appBar: AppBar(
        backgroundColor: SearchingDriverScreen.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: SearchingDriverScreen.primary),
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "SEARCHING ",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: SearchingDriverScreen.primary,
                  letterSpacing: 1.2,
                ),
              ),
              TextSpan(
                text: "DRIVER",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: SearchingDriverScreen.gold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Animated Radar Pulse
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140 + (_controller.value * 30),
                          height: 140 + (_controller.value * 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: SearchingDriverScreen.primary
                                .withValues(alpha: 1.0 - _controller.value),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: SearchingDriverScreen.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_car_filled,
                            size: 55,
                            color: SearchingDriverScreen.gold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "Finding the best chauffeur for you...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: SearchingDriverScreen.primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Please wait while we match you with a nearby professional driver.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              // Booking Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SearchingDriverScreen.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildLocationRow(
                      icon: Icons.my_location,
                      iconColor: SearchingDriverScreen.primary,
                      title: "Pickup",
                      address: "Madhapur, Hyderabad",
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    _buildLocationRow(
                      icon: Icons.location_on,
                      iconColor: Colors.redAccent,
                      title: "Destination",
                      address: "RGIA Airport",
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Estimated Arrival",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "2 - 5 mins",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SearchingDriverScreen.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Cancel Booking Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cancel Request",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String address,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SearchingDriverScreen.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}