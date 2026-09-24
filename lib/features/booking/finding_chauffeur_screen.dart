import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chauffeur_assigned_screen.dart';

class FindingChauffeurScreen extends StatefulWidget {
  const FindingChauffeurScreen({
    super.key,
    required this.bookingId,
    required this.pickupLocation,
    required this.dropLocation,
  });

  final String bookingId;
  final String pickupLocation;
  final String dropLocation;

  @override
  State<FindingChauffeurScreen> createState() =>
      _FindingChauffeurScreenState();
}

class _FindingChauffeurScreenState
    extends State<FindingChauffeurScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  Timer? _timer;

  StreamSubscription<
      DocumentSnapshot<Map<String, dynamic>>>? _bookingSubscription;

  int seconds = 0;
  bool _openingAssignedScreen = false;

  @override
  void initState() {
    super.initState();

    _startTimer();
    _listenToBooking();

  }

  // ==========================================================
  // TIMER
  // ==========================================================

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          seconds++;
        });
      },
    );
  }

  // ==========================================================
  // FIRESTORE LISTENER
  // ==========================================================

  void _listenToBooking() {
    _bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .listen(
      (snapshot) {
        if (!snapshot.exists) return;

        final data = snapshot.data();

        if (data == null) return;

        final String status =
            (data['status'] ?? '').toString().toUpperCase();

        debugPrint(
          'Booking ${widget.bookingId} status: $status',
        );

        if (status == 'ACCEPTED' ||
            status == 'ASSIGNED' ||
            status == 'ARRIVING' ||
            status == 'ARRIVED' ||
            status == 'TRIP_STARTED') {
          _openAssignedScreen();
        }

        if (status == 'CANCELLED') {
          _showBookingCancelled();
        }
      },
      onError: (error) {
        debugPrint(
          'Booking listener error: $error',
        );
      },
    );
  }

  // ==========================================================
  // OPEN ASSIGNED SCREEN
  // ==========================================================

  void _openAssignedScreen() {
    if (_openingAssignedScreen) return;

    if (!mounted) return;

    _openingAssignedScreen = true;

    _timer?.cancel();
    _bookingSubscription?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChauffeurAssignedScreen(
          bookingId: widget.bookingId,
          pickupLocation: widget.pickupLocation,
          dropLocation: widget.dropLocation,
        ),
      ),
    );
  }

  // ==========================================================
  // BOOKING CANCELLED
  // ==========================================================

  void _showBookingCancelled() {
    if (!mounted) return;

    _timer?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "This booking has been cancelled.",
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // CANCEL SEARCH
  // ==========================================================

  Future<void> _cancelSearch() async {
    _timer?.cancel();
    await _bookingSubscription?.cancel();

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint(
        'Cancel booking error: $e',
      );
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bookingSubscription?.cancel();
    super.dispose();
  }

  // ==========================================================
  // UI
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
          "Finding Chauffeur",
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

              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_search_rounded,
                  size: 60,
                  color: primary,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Finding Your Chauffeur",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "We are looking for the best available chauffeur near your location.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  minHeight: 5,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    gold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "Searching • ${seconds}s",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 35),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: primary,
                      size: 25,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Only verified chauffeurs are assigned through WE DRIVE.",
                        style: TextStyle(
                          fontSize: 14,
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _cancelSearch,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(
                      color: primary,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Cancel Search",
                    style: TextStyle(
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