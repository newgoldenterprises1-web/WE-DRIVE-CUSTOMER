import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'widgets/booking_summary_card.dart';
import 'widgets/cancel_booking_sheet.dart';
import 'widgets/searching_animation.dart';
import '../driver_assigned/driver_assigned_screen.dart';
import '../trip_started/trip_started_screen.dart';

class SearchingDriverScreen extends StatefulWidget {
  const SearchingDriverScreen({
    super.key,
    required this.bookingId,
  });

  final String bookingId;

  @override
  State<SearchingDriverScreen> createState() =>
      _SearchingDriverScreenState();
}

class _SearchingDriverScreenState
    extends State<SearchingDriverScreen> {

  GoogleMapController? mapController;

  int statusIndex = 0;

  final List<String> statusList = [
    "Searching nearby drivers...",
    "Notifying available drivers...",
    "Driver request sent...",
    "Matching the best driver...",
    "Almost done...",
  ];

  Timer? statusTimer;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? bookingSubscription;
  bool navigationStarted = false;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(17.3850, 78.4867),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();

    statusTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (!mounted) return;

        setState(() {
          statusIndex =
              (statusIndex + 1) % statusList.length;
        });
      },
    );

    bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .listen(_handleBooking, onError: (_) {});
  }

  void _handleBooking(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (!mounted || navigationStarted || !snapshot.exists) return;

    final data = snapshot.data() ?? <String, dynamic>{};
    final status = (data['status'] ?? data['bookingStatus'] ?? '')
        .toString()
        .toUpperCase();

    switch (status) {
      case 'ACCEPTED':
      case 'ARRIVING':
      case 'ARRIVED':
        navigationStarted = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DriverAssignedScreen(
              bookingId: widget.bookingId,
              initialBooking: data,
            ),
          ),
        );
        break;
      case 'TRIP_STARTED':
      case 'IN_PROGRESS':
      case 'STARTED':
        navigationStarted = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TripStartedScreen(bookingId: widget.bookingId),
          ),
        );
        break;
      case 'CANCELLED':
      case 'CANCELED':
      case 'REJECTED':
        navigationStarted = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This chauffeur request is no longer active.')),
        );
        Navigator.pop(context);
        break;
    }
  }

  Future<void> _cancelBooking() async {
    try {
      await BookingService.cancelBooking(bookingId: widget.bookingId);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to cancel: ' + e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    statusTimer?.cancel();
    bookingSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  void showCancelSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CancelBookingSheet(
          onKeepSearching: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Continuing to search for a driver.')),
            );
          },
          onCancelBooking: () async {
            Navigator.pop(context);
            await _cancelBooking();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text("Finding Driver"),
        elevation: 0,
        backgroundColor: const Color(0xFF173B6D),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),

      body: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          Container(
            color: Colors.black.withValues(alpha: .15),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  const SizedBox(height: 20),

                  const SearchingAnimation(),

                  const SizedBox(height: 18),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      statusList[statusIndex],
                      key: ValueKey(statusIndex),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173B6D),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Please wait while we connect you\nwith the nearest chauffeur.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const BookingSummaryCard(
                    pickup: "Banjara Hills",
                    destination: "RGIA Airport",
                    vehicle: "Sedan",
                    fare: "₹850",
                    searchTime: "Live search",
                  ),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: showCancelSheet,
                        icon: const Icon(Icons.close),
                        label: const Text(
                          "Cancel Booking",
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(
                            color: Colors.red,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}