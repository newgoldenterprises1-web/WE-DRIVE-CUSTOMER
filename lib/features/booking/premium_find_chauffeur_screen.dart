import 'dart:async';

import 'package:flutter/material.dart';

import 'premium_chauffeur_assigned_screen.dart';

class PremiumFindChauffeurScreen extends StatefulWidget {
  const PremiumFindChauffeurScreen({
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

  @override
  State<PremiumFindChauffeurScreen> createState() =>
      _PremiumFindChauffeurScreenState();
}

class _PremiumFindChauffeurScreenState
    extends State<PremiumFindChauffeurScreen>
    with SingleTickerProviderStateMixin {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FA);

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  Timer? _timer;

  int _secondsRemaining = 4;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _startSearching();
  }

  void _startSearching() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining > 1) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          timer.cancel();
          _openAssignedScreen();
        }
      },
    );
  }

  void _openAssignedScreen() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PremiumChauffeurAssignedScreen(
          pickupLocation: widget.pickupLocation,
          dropLocation: widget.dropLocation,
          serviceType: widget.serviceType,
          fare: widget.fare,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),

              _premiumSearchingAnimation(),

              const SizedBox(height: 35),

              const Text(
                "Finding Premium Chauffeur",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Searching verified and highly-rated premium chauffeurs near you.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              _searchStatus(),

              const SizedBox(height: 20),

              _bookingInfo(),

              const Spacer(),

              Text(
                "Please wait while we find the best premium chauffeur for you.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumSearchingAnimation() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: .07),
              border: Border.all(
                color: gold.withValues(alpha: .35),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                height: 105,
                width: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary,
                      Color(0xFF1D4A84),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          primary.withValues(alpha: .25),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: gold,
                  size: 52,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: primary,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  "Searching premium chauffeurs",
                  style: TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                "${_secondsRemaining}s",
                style: const TextStyle(
                  color: gold,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            child: LinearProgressIndicator(
              minHeight: 7,
              backgroundColor: Color(0xFFE5E7EB),
              valueColor:
                  AlwaysStoppedAnimation<Color>(gold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primary.withValues(alpha: .10),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            color: gold,
            size: 23,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Premium service • ${widget.serviceType} • ${widget.fare}",
              style: const TextStyle(
                color: primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}