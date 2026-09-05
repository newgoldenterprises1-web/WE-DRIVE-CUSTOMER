import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../driver_assigned/driver_assigned_screen.dart';

class DriverSearchingScreen extends StatefulWidget {
  final String pickupLocation;
  final String dropLocation;
  final String selectedVehicle;
  final int totalFare;

  const DriverSearchingScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.selectedVehicle,
    required this.totalFare,
  });

  @override
  State<DriverSearchingScreen> createState() =>
      _DriverSearchingScreenState();
}

class _DriverSearchingScreenState
    extends State<DriverSearchingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);

    _timer = Timer(
      const Duration(seconds: 8),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DriverAssignedScreen(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF173B6D),
          ),
        ),
        title: const Text(
          "Searching Driver",
          style: TextStyle(
            color: Color(0xFF173B6D),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 20,
          ),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.03),

              const Icon(
                Icons.local_taxi_rounded,
                size: 70,
                color: Color(0xFFD4AF37),
              ),

              const SizedBox(height: 18),

              const Text(
                "Searching Chauffeur...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173B6D),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Finding the best nearby professional chauffeur for your ride.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.directions_car_filled_rounded,
                          size: 46,
                          color: Color(0xFF173B6D),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 45),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .06),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    _StatusTile(
                      icon: Icons.verified_user_rounded,
                      title: "Verified Drivers",
                    ),
                    SizedBox(height: 18),
                    _StatusTile(
                      icon: Icons.security_rounded,
                      title: "Background Checked",
                    ),
                    SizedBox(height: 18),
                    _StatusTile(
                      icon: Icons.location_on_rounded,
                      title: "Live Tracking",
                    ),
                    SizedBox(height: 18),
                    _StatusTile(
                      icon: Icons.shield_rounded,
                      title: "Safe & Secure Ride",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF173B6D),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  children: [
                    Text(
                      "Estimated Time",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "15 - 30 sec",
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Please don't close this screen while we assign your chauffeur.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Cancel Request",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _StatusTile({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF173B6D)
                .withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF173B6D),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF173B6D),
            ),
          ),
        ),

        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 22,
        ),
      ],
    );
  }
}