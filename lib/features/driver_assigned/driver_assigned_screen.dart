import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/action_buttons.dart';
import 'widgets/driver_info_card.dart';
import 'widgets/driver_status_card.dart';
import 'widgets/live_eta_card.dart';
import 'widgets/route_map_card.dart';
import 'widgets/sos_button.dart';
import 'widgets/trip_details_card.dart';
import 'widgets/vehicle_card.dart';

class DriverAssignedScreen extends StatefulWidget {
  const DriverAssignedScreen({super.key});

  @override
  State<DriverAssignedScreen> createState() => _DriverAssignedScreenState();
}

class _DriverAssignedScreenState extends State<DriverAssignedScreen> {
  GoogleMapController? mapController;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(17.3850, 78.4867),
    zoom: 14,
  );

  DriverTripStatus tripStatus = DriverTripStatus.arriving;

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  void verifyOtp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip OTP verified successfully.')),
    );
  }

  Future<void> callDriver() async {
    final uri = Uri.parse('tel:+919876543210');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open phone dialer.')),
      );
    }
  }

  void chatDriver() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Driver Chat'),
        content: const Text('Chat is ready. Real-time messaging will be connected with the backend.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void trackDriver() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live driver tracking opened.')),
    );
  }

  void shareTrip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip sharing opened.')),
    );
  }

  void showSos() {
    SosButton.showSosDialog(
      context,
      onCallPolice: () async {
        final uri = Uri.parse('tel:112');
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      onCallAmbulance: () async {
        final uri = Uri.parse('tel:108');
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      onShareLocation: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current trip location ready to share.')),
        );
      },
      onEmergencyContact: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency contact action opened.')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF173B6D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Driver Assigned"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 18),
          RouteMapCard(
            initialPosition: initialPosition,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),
          const SizedBox(height: 18),
          const LiveEtaCard(
            eta: "5 mins",
            distance: "1.8 km",
          ),
          const SizedBox(height: 18),
          const DriverInfoCard(),
          const SizedBox(height: 18),
          ActionButtons(
            onCall: callDriver,
            onChat: chatDriver,
            onTrack: trackDriver,
            onShare: shareTrip,
          ),
          const SizedBox(height: 18),
          VehicleCard(
            onCall: callDriver,
            onMessage: chatDriver,
          ),
          const SizedBox(height: 18),
          const TripDetailsCard(),
          const SizedBox(height: 18),
          DriverStatusCard(
            status: tripStatus,
          ),
          const SizedBox(height: 18),
          SosButton(
            onSosPressed: showSos,
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF173B6D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Verify Trip OTP",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}