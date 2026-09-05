import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'widgets/booking_summary_card.dart';
import 'widgets/cancel_booking_sheet.dart';
import 'widgets/searching_animation.dart';
import '../driver_assigned/driver_assigned_screen.dart';

class SearchingDriverScreen extends StatefulWidget {
  const SearchingDriverScreen({super.key});

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
  Timer? navigationTimer;

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

    navigationTimer = Timer(
      const Duration(seconds: 10),
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
    statusTimer?.cancel();
    navigationTimer?.cancel();
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
          onCancelBooking: () {
            Navigator.pop(context);
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
                    searchTime: "10-20 seconds",
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