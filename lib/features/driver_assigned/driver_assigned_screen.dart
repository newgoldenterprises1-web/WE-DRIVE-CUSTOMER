import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../trip_started/trip_started_screen.dart';
import 'widgets/action_buttons.dart';
import 'widgets/driver_info_card.dart';
import 'widgets/driver_status_card.dart';
import 'widgets/live_eta_card.dart';
import 'widgets/route_map_card.dart';
import 'widgets/sos_button.dart';
import 'widgets/trip_details_card.dart';
import 'widgets/vehicle_card.dart';

class DriverAssignedScreen extends StatefulWidget {
  const DriverAssignedScreen({
    super.key,
    required this.bookingId,
    this.initialBooking,
  });

  final String bookingId;
  final Map<String, dynamic>? initialBooking;

  @override
  State<DriverAssignedScreen> createState() => _DriverAssignedScreenState();
}

class _DriverAssignedScreenState extends State<DriverAssignedScreen> {
  GoogleMapController? mapController;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? bookingSubscription;
  LatLng? lastDriverPosition;
  bool navigatingToTrip = false;

  static const CameraPosition fallbackPosition = CameraPosition(
    target: LatLng(17.3850, 78.4867),
    zoom: 14,
  );

  DriverTripStatus tripStatus = DriverTripStatus.arriving;

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

    if (status == 'TRIP_STARTED' || status == 'IN_PROGRESS' || status == 'STARTED') {
      if (navigatingToTrip) return;
      navigatingToTrip = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TripStartedScreen(bookingId: widget.bookingId),
        ),
      );
    }
  }

  double _number(Map<String, dynamic> data, String key, [double fallback = 0]) {
    final value = data[key];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    final p = math.pi / 180;
    final a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lng2 - lng1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  String _formatDistance(double km) {
    if (km < 1) return (km * 1000).round().toString() + ' m';
    return km.toStringAsFixed(1) + ' km';
  }

  String _formatEta(double minutes) {
    if (minutes <= 0) return 'Arriving';
    if (minutes < 1) return '<1 min';
    return minutes.round().toString() + ' mins';
  }

  LatLng _coordinate(Map<String, dynamic> data, String latKey, String lngKey, LatLng fallback) {
    final lat = _number(data, latKey, double.nan);
    final lng = _number(data, lngKey, double.nan);
    if (lat.isFinite && lng.isFinite && lat.abs() <= 90 && lng.abs() <= 180) {
      return LatLng(lat, lng);
    }
    return fallback;
  }

  void _animateToDriver(LatLng position) {
    if (mapController == null) return;
    if (lastDriverPosition != null &&
        _distanceKm(
              lastDriverPosition!.latitude,
              lastDriverPosition!.longitude,
              position.latitude,
              position.longitude,
            ) <
            0.01) {
      return;
    }
    lastDriverPosition = position;
    mapController!.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  Future<void> callDriver(String phone) async {
    if (phone.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chauffeur phone number is not available.')),
      );
      return;
    }
    final uri = Uri.parse('tel:' + phone);
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
        content: const Text(
          'Chat is not enabled yet. Booking status and location remain available live.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
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
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? widget.initialBooking ?? <String, dynamic>{};

        final pickup = (data['pickupLocation'] ?? 'Pickup location').toString();
        final drop = (data['dropLocation'] ?? 'Destination').toString();
        final driverName = (data['driverName'] ?? 'WE DRIVE Chauffeur').toString();
        final driverPhone = (data['driverPhone'] ?? '').toString();
        final rating = _number(data, 'driverRating', 5).toStringAsFixed(1);
        final trips = (_number(data, 'completedTrips', 0) > 0
                ? _number(data, 'completedTrips', 0)
                : _number(data, 'driverTrips', 0))
            .round()
            .toString();
        final otp = (data['otp'] ?? '----').toString();
        final verified = data['driverVerified'] == true;

        final pickupPosition = _coordinate(
          data,
          'pickupLatitude',
          'pickupLongitude',
          fallbackPosition.target,
        );
        final driverPosition = _coordinate(
          data,
          'chauffeurLatitude',
          'chauffeurLongitude',
          pickupPosition,
        );
        final heading = _number(data, 'chauffeurHeading', 0);

        final assignedVehicle = data['assignedVehicle'];
        final vehicleMap = assignedVehicle is Map
            ? Map<String, dynamic>.from(assignedVehicle)
            : <String, dynamic>{};
        final vehicle = [
          vehicleMap['model'] ?? data['vehicleType'] ?? 'Assigned vehicle',
          vehicleMap['color'],
        ].where((value) => value != null && value.toString().trim().isNotEmpty).join(' • ');
        final vehicleNumber =
            (vehicleMap['number'] ?? data['registrationNumber'] ?? 'Registration not available')
                .toString();

        final currentSpeedMps = _number(data, 'chauffeurSpeed', 0);
        final speedKmh = currentSpeedMps > 1 ? currentSpeedMps * 3.6 : 25;
        final distanceToPickup = _distanceKm(
          driverPosition.latitude,
          driverPosition.longitude,
          pickupPosition.latitude,
          pickupPosition.longitude,
        );
        final etaMinutes = distanceToPickup / math.max(speedKmh, 18) * 60;

        final statusText = (data['status'] ?? data['bookingStatus'] ?? 'ACCEPTED')
            .toString()
            .toUpperCase();

        switch (statusText) {
          case 'ARRIVED':
            tripStatus = DriverTripStatus.arrived;
            break;
          case 'ARRIVING':
            tripStatus = DriverTripStatus.arriving;
            break;
          default:
            tripStatus = DriverTripStatus.arriving;
        }

        final markers = <Marker>{
          Marker(
            markerId: const MarkerId('driver'),
            position: driverPosition,
            rotation: heading,
            infoWindow: InfoWindow(title: driverName),
          ),
          Marker(
            markerId: const MarkerId('pickup'),
            position: pickupPosition,
          ),
        };

        final polylines = <Polyline>{
          Polyline(
            polylineId: const PolylineId('driver_to_pickup'),
            points: [driverPosition, pickupPosition],
            width: 5,
            color: const Color(0xFF173B6D),
          ),
        };

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _animateToDriver(driverPosition);
        });

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
                initialPosition: CameraPosition(
                  target: driverPosition,
                  zoom: 14,
                ),
                markers: markers,
                polylines: polylines,
                onMapCreated: (controller) {
                  mapController = controller;
                  controller.animateCamera(
                    CameraUpdate.newLatLng(driverPosition),
                  );
                },
              ),
              const SizedBox(height: 18),
              LiveEtaCard(
                eta: _formatEta(etaMinutes),
                distance: _formatDistance(distanceToPickup),
              ),
              const SizedBox(height: 18),
              DriverInfoCard(
                name: driverName,
                rating: rating,
                trips: trips,
                otp: otp,
                verified: verified,
              ),
              const SizedBox(height: 18),
              ActionButtons(
                onCall: () => callDriver(driverPhone),
                onChat: chatDriver,
                onTrack: () {
                  if (mapController != null) {
                    mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(driverPosition, 16),
                    );
                  }
                },
                onShare: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Live trip sharing is ready from the booking.')),
                  );
                },
              ),
              const SizedBox(height: 18),
              VehicleCard(
                vehicle: vehicle.isEmpty ? 'Assigned vehicle' : vehicle,
                number: vehicleNumber,
                onCall: () => callDriver(driverPhone),
                onMessage: chatDriver,
              ),
              const SizedBox(height: 18),
              TripDetailsCard(
                pickup: pickup,
                drop: drop,
              ),
              const SizedBox(height: 18),
              DriverStatusCard(status: tripStatus),
              const SizedBox(height: 18),
              SosButton(onSosPressed: showSos),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      final verifiedAt = data['otpVerifiedAt'];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            verifiedAt != null
                                ? 'Trip OTP has already been verified by the chauffeur.'
                                : 'OTP ' + otp + ' will be validated by the backend when the trip starts.',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF173B6D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      data['otpVerifiedAt'] != null
                          ? "Trip OTP Verified"
                          : "Verify Trip OTP",
                      style: const TextStyle(
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
      },
    );
  }
}
