import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'finding_chauffeur_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({
    super.key,
    this.serviceName = "Hourly",
    required this.pickupLocation,
    required this.dropLocation,
    this.hours = 2,
  });

  final String serviceName;
  final String pickupLocation;
  final String dropLocation;
  final int hours;

  @override
  State<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState
    extends State<BookingSummaryScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool isBooking = false;

  String _serviceDurationLabel(String service) {
    switch (service) {
      case "Airport":
        return "Airport Transfer";
      case "Outstation":
        return "Long Distance Trip";
      case "Advance":
        return "Scheduled Booking";
      case "One Way":
        return "One Way Transfer";
      case "Round Trip":
        return "Round Trip";
      default:
        return "Booking Based";
    }
  }


  // ==========================================================
  // CONFIRM BOOKING
  // ==========================================================

  Future<void> _confirmBooking() async {
    if (isBooking) return;

    final User? user = _auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please login before confirming your booking.",
          ),
        ),
      );

      return;
    }

    setState(() {
      isBooking = true;
    });

    try {
      // ======================================================
      // CREATE BOOKING
      // ======================================================

      final DocumentReference<Map<String, dynamic>>
          bookingRef =
          _firestore.collection('bookings').doc();

      await bookingRef.set({
        'bookingId': bookingRef.id,

        // ====================================================
        // CUSTOMER
        // ====================================================

        'customerId': user.uid,
        'customerName': user.displayName ?? '',
        'customerPhone': user.phoneNumber ?? '',
        'customerEmail': user.email ?? '',

        // ====================================================
        // TRIP
        // ====================================================

        'serviceName': widget.serviceName,
        'pickupLocation': widget.pickupLocation,
        'dropLocation': widget.dropLocation,

        // ====================================================
        // BOOKING DETAILS
        // ====================================================

        'date': 'Today',
        'time': 'Now',
        "estimatedDuration": widget.serviceName == "Hourly"
            ? "${widget.hours} Hours"
            : _serviceDurationLabel(widget.serviceName),

        // ====================================================
        // FARE
        // ====================================================

        'estimatedFare': widget.serviceName == 'Hourly' ? 499 * widget.hours : 850,
        'fareDisplay': widget.serviceName == 'Hourly' ? '₹${499 * widget.hours}' : '₹850',

        // ====================================================
        // DRIVER
        // ====================================================

        'driverId': null,
        'driverName': null,

        // ====================================================
        // STATUS
        // ====================================================

        'status': 'searching',
        'paymentStatus': 'pending',

        // ====================================================
        // TIMESTAMPS
        // ====================================================

        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // ======================================================
      // OPEN FINDING CHAUFFEUR
      // ======================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FindingChauffeurScreen(
  bookingId: bookingRef.id,
  pickupLocation: widget.pickupLocation,
  dropLocation: widget.dropLocation,
),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      debugPrint(
        'Firestore Booking Error: ${e.code}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ??
                'Unable to create booking. Please try again.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      setState(() {
        isBooking = false;
      });
    } catch (e) {
      if (!mounted) return;

      debugPrint(
        'Booking Error: $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to create booking: $e',
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      setState(() {
        isBooking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Booking Summary",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Review Your Booking",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Please review your chauffeur booking details.",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // LOCATION CARD
            // ==================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _locationRow(
                    icon:
                        Icons.my_location_rounded,
                    iconColor: Colors.green,
                    title: "Pickup",
                    value:
                        widget.pickupLocation,
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.only(
                      left: 12,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Align(
                      alignment:
                          Alignment.centerLeft,
                      child: SizedBox(
                        height: 28,
                        child: VerticalDivider(
                          color:
                              Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ),
                  ),

                  _locationRow(
                    icon:
                        Icons.location_on_rounded,
                    iconColor: Colors.red,
                    title: "Drop",
                    value:
                        widget.dropLocation,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // BOOKING DETAILS
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons
                        .miscellaneous_services_rounded,
                    "Service",
                    widget.serviceName,
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    Icons.calendar_today_rounded,
                    "Date",
                    "Today",
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    Icons.access_time_rounded,
                    "Time",
                    "Now",
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    Icons.timer_rounded,
                    "Estimated Duration",
                    widget.serviceName == "Hourly"
                        ? "${widget.hours} Hours"
                        : _serviceDurationLabel(widget.serviceName),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // FARE
            // ==================================================

            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Estimated Fare",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "₹850",
                    style: TextStyle(
                      color: gold,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // CONFIRM BOOKING
            // ==================================================

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed:
                    isBooking
                        ? null
                        : _confirmBooking,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      primary.withValues(
                    alpha: .6,
                  ),
                  elevation: 3,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
                child: isBooking
                    ? const SizedBox(
                        width: 25,
                        height: 25,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Text(
                        "Confirm Booking",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
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

  // ==========================================================
  // LOCATION ROW
  // ==========================================================

  Widget _locationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color:
                iconColor.withValues(
              alpha: 0.10,
            ),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DETAIL ROW
  // ==========================================================

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: primary,
          size: 23,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),

        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            style: const TextStyle(
              color: primary,
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}