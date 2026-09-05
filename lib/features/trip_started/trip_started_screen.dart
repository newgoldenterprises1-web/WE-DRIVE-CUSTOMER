import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../payment/payment_screen.dart';
import 'widgets/destination_card.dart';
import 'widgets/emergency_button.dart';
import 'widgets/end_trip_button.dart';
import 'widgets/live_trip_map.dart';
import 'widgets/trip_progress.dart';
import 'widgets/trip_status_card.dart';

class TripStartedScreen extends StatefulWidget {
  const TripStartedScreen({super.key});

  @override
  State<TripStartedScreen> createState() =>
      _TripStartedScreenState();
}

class _TripStartedScreenState
    extends State<TripStartedScreen> {

  GoogleMapController? _mapController;

  bool endingTrip = false;

  TripStage stage = TripStage.onTheWay;

  double progress = .65;

  static const CameraPosition initialCamera =
      CameraPosition(
    target: LatLng(17.3850, 78.4867),
    zoom: 14,
  );

  final Set<Marker> markers = {
    const Marker(
      markerId: MarkerId("driver"),
      position: LatLng(17.3850, 78.4867),
    ),
    const Marker(
      markerId: MarkerId("destination"),
      position: LatLng(17.4300, 78.5000),
    ),
  };

  final Set<Polyline> polylines = {
    const Polyline(
      polylineId: PolylineId("trip_route"),
      points: [
        LatLng(17.3850, 78.4867),
        LatLng(17.3920, 78.4890),
        LatLng(17.4050, 78.4940),
        LatLng(17.4300, 78.5000),
      ],
      width: 5,
      color: Color(0xFF173B6D),
    ),
  };

  Future<void> endTrip() async {

    setState(() {
      endingTrip = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentScreen(),
      ),
    );
  }

  void showEmergency() {
    EmergencyButton.showEmergencyDialog(
      context,
      onCallPolice: () async {
        final uri = Uri.parse('tel:112');
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      onCallAmbulance: () async {
        final uri = Uri.parse('tel:108');
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      onEmergencyContact: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency contact action opened.')),
        );
      },
      onShareLocation: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current trip location ready to share.')),
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF173B6D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Trip Started"),
      ),

      body: SafeArea(
        child: ListView(
          children: [

            LiveTripMap(
              initialPosition: initialCamera,
              markers: markers,
              polylines: polylines,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),

            const SizedBox(height: 5),

            const TripStatusCard(
              speed: "45 km/h",
              eta: "18 mins",
              distanceRemaining: "9.4 km",
              status: "On Route",
            ),

            const SizedBox(height: 18),

            TripProgress(
              stage: stage,
              progress: progress,
            ),

            const SizedBox(height: 18),

            const DestinationCard(
              pickupAddress:
                  "Hitech City Metro Station, Hyderabad",

              destinationAddress:
                  "Rajiv Gandhi International Airport",

              distance: "28 km",

              eta: "42 mins",

              fare: "₹850",
            ),

            const SizedBox(height: 20),

            EmergencyButton(
              onSosPressed: showEmergency,
            ),

            const SizedBox(height: 20),

            EndTripButton(
              loading: endingTrip,
              onPressed: endTrip,
            ),

          ],
        ),
      ),
    );
  }
}