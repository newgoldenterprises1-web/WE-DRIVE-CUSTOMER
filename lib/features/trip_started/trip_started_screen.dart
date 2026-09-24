import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../rating/rating_screen.dart';
import 'widgets/destination_card.dart';
import 'widgets/emergency_button.dart';
import 'widgets/end_trip_button.dart';
import 'widgets/live_trip_map.dart';
import 'widgets/trip_progress.dart';
import 'widgets/trip_status_card.dart';

class TripStartedScreen extends StatefulWidget {
  const TripStartedScreen({
    super.key,
    required this.bookingId,
  });

  final String bookingId;

  @override
  State<TripStartedScreen> createState() => _TripStartedScreenState();
}

class _TripStartedScreenState extends State<TripStartedScreen> {
  GoogleMapController? mapController;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? bookingSubscription;
  bool endingTrip = false;
  bool completionHandled = false;

  TripStage stage = TripStage.tripStarted;
  double progress = .5;

  static const LatLng fallbackCenter = LatLng(17.3850, 78.4867);

  @override
  void initState() {
    super.initState();
    bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .snapshots()
        .listen(_handleBooking, onError: (_) {});
  }

  @override
  void dispose() {
    bookingSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  void _handleBooking(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (!mounted || !snapshot.exists) return;
    final data = snapshot.data() ?? <String, dynamic>{};
    final status = (data['status'] ?? data['bookingStatus'] ?? '')
        .toString()
        .toUpperCase();

    if (status == 'COMPLETED' && !completionHandled) {
      completionHandled = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RatingScreen()),
      );
    }
  }

  double _number(Map<String, dynamic> data, String key, [double fallback = 0]) {
    final value = data[key];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _distanceKm(LatLng a, LatLng b) {
    final p = math.pi / 180;
    final x = 0.5 -
        math.cos((b.latitude - a.latitude) * p) / 2 +
        math.cos(a.latitude * p) *
            math.cos(b.latitude * p) *
            (1 - math.cos((b.longitude - a.longitude) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(x));
  }

  LatLng _readPosition(
    Map<String, dynamic> data,
    String latKey,
    String lngKey,
    LatLng fallback,
  ) {
    final lat = _number(data, latKey, double.nan);
    final lng = _number(data, lngKey, double.nan);
    if (lat.isFinite && lng.isFinite && lat.abs() <= 90 && lng.abs() <= 180) {
      return LatLng(lat, lng);
    }
    return fallback;
  }

  String _formatDistance(double km) {
    if (km < 1) return (km * 1000).round().toString() + ' m';
    return km.toStringAsFixed(1) + ' km';
  }

  String _formatEta(double minutes) {
    if (minutes <= 0) return 'Arriving';
    return minutes.round().toString() + ' mins';
  }

  TripStage _stageFor(String status, double distanceRemaining) {
    switch (status) {
      case 'COMPLETED':
        return TripStage.completed;
      case 'ARRIVED':
        return TripStage.pickupCompleted;
      case 'TRIP_STARTED':
      case 'IN_PROGRESS':
      case 'STARTED':
        if (distanceRemaining <= 1) return TripStage.nearDestination;
        return TripStage.onTheWay;
      default:
        return TripStage.tripStarted;
    }
  }

  double _progressFor(
    Map<String, dynamic> data,
    LatLng pickup,
    LatLng current,
    LatLng destination,
  ) {
    final explicit = data['tripProgress'];
    if (explicit is num) {
      return explicit.toDouble().clamp(0.0, 1.0);
    }

    final total = _distanceKm(pickup, destination);
    if (total <= 0.01) return .5;
    final remaining = _distanceKm(current, destination);
    return (1 - (remaining / total)).clamp(0.0, 1.0);
  }

  Future<void> _onEndTripPressed() async {
    if (endingTrip) return;
    setState(() => endingTrip = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => endingTrip = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip completion is controlled by the chauffeur after the final inspection.'),
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
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? <String, dynamic>{};

        final pickup = _readPosition(
          data,
          'pickupLatitude',
          'pickupLongitude',
          fallbackCenter,
        );
        final destination = _readPosition(
          data,
          'dropLatitude',
          'dropLongitude',
          LatLng(17.4300, 78.5000),
        );
        final chauffeur = _readPosition(
          data,
          'chauffeurLatitude',
          'chauffeurLongitude',
          pickup,
        );

        final speedMps = _number(data, 'chauffeurSpeed', 0);
        final speedKmh = speedMps > 1 ? speedMps * 3.6 : 30;
        final remainingKm = _distanceKm(chauffeur, destination);
        final etaMinutes = remainingKm / math.max(speedKmh, 20) * 60;
        final status = (data['status'] ?? data['bookingStatus'] ?? 'TRIP_STARTED')
            .toString()
            .toUpperCase();

        stage = _stageFor(status, remainingKm);
        progress = _progressFor(data, pickup, chauffeur, destination);

        final markers = <Marker>{
          Marker(
            markerId: const MarkerId("driver"),
            position: chauffeur,
            rotation: _number(data, 'chauffeurHeading', 0),
            infoWindow: const InfoWindow(title: 'Your Chauffeur'),
          ),
          Marker(
            markerId: const MarkerId("destination"),
            position: destination,
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        };

        final polylines = <Polyline>{
          Polyline(
            polylineId: const PolylineId("trip_route"),
            points: [chauffeur, destination],
            width: 5,
            color: const Color(0xFF173B6D),
          ),
        };

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && mapController != null) {
            mapController!.animateCamera(
              CameraUpdate.newLatLng(chauffeur),
            );
          }
        });

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
                  initialPosition: CameraPosition(
                    target: chauffeur,
                    zoom: 14,
                  ),
                  markers: markers,
                  polylines: polylines,
                  onMapCreated: (controller) {
                    mapController = controller;
                    controller.animateCamera(
                      CameraUpdate.newLatLng(chauffeur),
                    );
                  },
                ),
                const SizedBox(height: 5),
                TripStatusCard(
                  speed: speedMps > 0
                      ? speedKmh.toStringAsFixed(0) + " km/h"
                      : "Tracking",
                  eta: _formatEta(etaMinutes),
                  distanceRemaining: _formatDistance(remainingKm),
                  status: status == 'TRIP_STARTED'
                      ? "On Route"
                      : status.replaceAll('_', ' '),
                ),
                const SizedBox(height: 18),
                TripProgress(
                  stage: stage,
                  progress: progress,
                ),
                const SizedBox(height: 18),
                DestinationCard(
                  pickupAddress: (data['pickupLocation'] ?? 'Pickup').toString(),
                  destinationAddress: (data['dropLocation'] ?? 'Destination').toString(),
                  distance: _formatDistance(remainingKm),
                  eta: _formatEta(etaMinutes),
                  fare: "₹" + _number(data, 'fare', 0).toStringAsFixed(0),
                ),
                const SizedBox(height: 20),
                EmergencyButton(
                  onSosPressed: showEmergency,
                ),
                const SizedBox(height: 20),
                EndTripButton(
                  loading: endingTrip,
                  onPressed: _onEndTripPressed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
