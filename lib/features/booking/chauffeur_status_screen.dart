import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/booking_service.dart';
import 'trip_invoice_service.dart';

class ChauffeurStatusScreen extends StatefulWidget {
  const ChauffeurStatusScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.fare,
    required this.vehicleType,
    required this.bookingId,
  });

  final String pickupLocation;
  final String dropLocation;
  final double fare;
  final String vehicleType;
  final String bookingId;

  @override
  State<ChauffeurStatusScreen> createState() => _ChauffeurStatusScreenState();
}

class _ChauffeurStatusScreenState extends State<ChauffeurStatusScreen> {
  static const Color primary = Color(0xFF174C52);
  static const Color accent = Color(0xFFB99A47);
  static const Color bg = Color(0xFFF6F8F9);
  static const Color border = Color(0xFFE1E8EA);

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Cancel Chauffeur Request?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('This will cancel your current chauffeur request.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await BookingService.cancelBooking(bookingId: widget.bookingId);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to cancel: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: BookingService.watchBooking(widget.bookingId),
      builder: (context, bookingSnapshot) {
        if (bookingSnapshot.connectionState == ConnectionState.waiting && !bookingSnapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: primary)));
        }
        final booking = bookingSnapshot.data?.data() ?? {};
        final rawStatus = (booking['status'] ?? 'REQUESTED').toString().toUpperCase();
        final status = _normalizeStatus(rawStatus);
        final partnerId = (booking['partnerId'] ?? '').toString();

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: null,
          builder: (context, partnerSnapshot) {
            final partner = <String, dynamic>{};
            final driverName = (booking['driverName'] ?? 'Assigned Chauffeur').toString();
            final phone = (booking['driverPhone'] ?? '').toString();
            final rating = _number(booking['driverRating'], fallback: 5.0);
            final experience = (booking['driverExperience'] ?? '').toString();
            final verified = booking['driverVerified'] == true;
            final vehicle = _vehicleData(booking, partner);
            final lat = _number(booking['chauffeurLatitude'], fallback: double.nan);
            final lng = _number(booking['chauffeurLongitude'], fallback: double.nan);
            final hasLocation = lat.isFinite && lng.isFinite;

            return Scaffold(
              backgroundColor: bg,
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                elevation: 0,
                title: Text(_title(status), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _statusHeader(status),
                  const SizedBox(height: 14),
                  _mapCard(hasLocation, lat, lng, driverName),
                  const SizedBox(height: 14),
                  if (partnerId.isNotEmpty) _driverCard(driverName, phone, rating, experience, verified, vehicle, status),
                  if (partnerId.isNotEmpty) const SizedBox(height: 14),
                  _timeline(status),
                  const SizedBox(height: 14),
                  _routeCard(),
                  const SizedBox(height: 14),
                  _tripMeta(booking),
                  const SizedBox(height: 18),
                  if (status == 'COMPLETED')
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await TripInvoiceService.downloadInvoice(
                            bookingId: widget.bookingId,
                            vehicleType: widget.vehicleType,
                            pickupLocation: widget.pickupLocation,
                            dropLocation: widget.dropLocation,
                            fare: _number(booking['fare'], fallback: widget.fare),
                            driverName: driverName,
                            paymentStatus: (booking['paymentStatus'] ?? 'pending').toString(),
                          );
                        } catch (error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not generate invoice: ' + error.toString()), backgroundColor: Colors.red),
                          );
                        }
                      },
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('Download Invoice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),

                  if (!{'COMPLETED', 'CANCELLED', 'TRIP_STARTED'}.contains(status))
                    OutlinedButton.icon(
                      onPressed: _cancel,
                      icon: const Icon(Icons.close_rounded),
                      label: Text(status == 'REQUESTED' || status == 'SEARCHING' ? 'Cancel Request' : 'Cancel Chauffeur'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade200),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _normalizeStatus(String status) {
    switch (status) {
      case 'ASSIGNED':
        return 'ACCEPTED';
      case 'IN_PROGRESS':
      case 'ONGOING':
        return 'TRIP_STARTED';
      case 'REQUESTED':
      case 'SEARCHING':
      case 'ACCEPTED':
      case 'ARRIVING':
      case 'ARRIVED':
      case 'TRIP_STARTED':
      case 'COMPLETED':
      case 'CANCELLED':
        return status;
      default:
        return status;
    }
  }

  String _title(String status) {
    switch (status) {
      case 'REQUESTED':
      case 'SEARCHING':
        return 'Finding Your Chauffeur';
      case 'ACCEPTED':
      case 'ARRIVING':
        return 'Chauffeur Assigned';
      case 'ARRIVED':
        return 'Chauffeur Has Arrived';
      case 'TRIP_STARTED':
        return 'Trip In Progress';
      case 'COMPLETED':
        return 'Trip Completed';
      case 'CANCELLED':
        return 'Request Cancelled';
      default:
        return 'Chauffeur Status';
    }
  }

  Widget _statusHeader(String status) {
    final searching = status == 'REQUESTED' || status == 'SEARCHING';
    final completed = status == 'COMPLETED';
    final cancelled = status == 'CANCELLED';
    final icon = cancelled
        ? Icons.cancel_rounded
        : completed
            ? Icons.check_circle_rounded
            : searching
                ? Icons.radar_rounded
                : status == 'TRIP_STARTED'
                    ? Icons.route_rounded
                    : Icons.person_pin_circle_rounded;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, primary.withValues(alpha: 0.84)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 27),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_headline(status), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text(_subtitle(status), style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _headline(String status) {
    switch (status) {
      case 'REQUESTED':
      case 'SEARCHING':
        return 'Matching you with a verified chauffeur';
      case 'ACCEPTED':
      case 'ARRIVING':
        return 'Your chauffeur is on the way';
      case 'ARRIVED':
        return 'Your chauffeur is at the pickup point';
      case 'TRIP_STARTED':
        return 'Your chauffeur service is active';
      case 'COMPLETED':
        return 'Service completed successfully';
      default:
        return 'Your request has been cancelled';
    }
  }

  String _subtitle(String status) {
    if (status == 'TRIP_STARTED') return 'Live trip tracking is active.';
    if (status == 'ARRIVING' || status == 'ACCEPTED') return 'You can view the chauffeur location below.';
    if (status == 'ARRIVED') return 'Verify the chauffeur before starting the service.';
    return 'WE DRIVE professional chauffeur service.';
  }

  Widget _mapCard(bool hasLocation, double lat, double lng, String driverName) {
    return Container(
      height: 240,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: hasLocation
          ? GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 15.5),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('chauffeur'),
                  position: LatLng(lat, lng),
                  infoWindow: InfoWindow(title: driverName),
                ),
              },
            )
          : Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFFEFF5F5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_searching_rounded, color: primary, size: 34),
                    SizedBox(height: 8),
                    Text('Live chauffeur location will appear here', textAlign: TextAlign.center, style: TextStyle(color: primary, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Waiting for the partner app location update.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 11)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _driverCard(String name, String phone, double rating, String experience, bool verified, Map<String, String> vehicle, String status) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 28, backgroundColor: primary.withValues(alpha: 0.08), child: const Icon(Icons.person_rounded, color: primary, size: 34)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: primary))),
                      if (verified) ...[const SizedBox(width: 5), const Icon(Icons.verified_rounded, color: accent, size: 17)],
                    ]),
                    const SizedBox(height: 5),
                    Row(children: [
                      const Icon(Icons.star_rounded, size: 16, color: accent),
                      const SizedBox(width: 4),
                      Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800, color: primary, fontSize: 12)),
                      if (experience.isNotEmpty) ...[const SizedBox(width: 10), Text('$experience yrs experience', style: const TextStyle(color: Colors.black54, fontSize: 11))],
                    ]),
                  ],
                ),
              ),
              if (phone.isNotEmpty) IconButton(onPressed: () => _call(phone), icon: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), shape: BoxShape.circle), child: const Icon(Icons.phone_rounded, color: primary))),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: const Color(0xFFF7F9F9), borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              const Icon(Icons.directions_car_filled_rounded, color: primary, size: 21),
              const SizedBox(width: 10),
              Expanded(child: Text(vehicle['model']!.isEmpty ? 'Assigned vehicle details' : '${vehicle['model']} • ${vehicle['color']}', style: const TextStyle(fontWeight: FontWeight.w700, color: primary, fontSize: 12))),
              Text(vehicle['number']!.isEmpty ? '' : vehicle['number']!, style: const TextStyle(fontWeight: FontWeight.w900, color: primary, fontSize: 12)),
            ]),
          ),
          if (status != 'TRIP_STARTED' && status != 'COMPLETED' && status != 'CANCELLED') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFFFFF8E8), borderRadius: BorderRadius.circular(14), border: Border.all(color: accent.withValues(alpha: 0.25))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('START TRIP OTP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black54)), SizedBox(height: 2), Text('Share only when your chauffeur arrives', style: TextStyle(fontSize: 10.5, color: primary, fontWeight: FontWeight.w600))]),
                Text('----', style: TextStyle(fontSize: 22, letterSpacing: 3, fontWeight: FontWeight.w900, color: primary)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeline(String status) {
    const steps = <Map<String, String>>[
      {'title': 'Request sent', 'sub': 'WE DRIVE is matching you'},
      {'title': 'Chauffeur assigned', 'sub': 'A verified professional accepted'},
      {'title': 'Chauffeur arriving', 'sub': 'Live location is available'},
      {'title': 'Chauffeur arrived', 'sub': 'Verify the chauffeur before starting'},
      {'title': 'Service active', 'sub': 'Trip tracking is live'},
      {'title': 'Completed', 'sub': 'Thank you for choosing WE DRIVE'},
    ];
    final currentIndex = _statusIndex(status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Service Timeline', style: TextStyle(fontWeight: FontWeight.w800, color: primary, fontSize: 14)),
        const SizedBox(height: 14),
        for (int i = 0; i < steps.length; i++) _timelineRow(steps[i]['title']!, steps[i]['sub']!, i <= currentIndex, i == steps.length - 1),
      ]),
    );
  }

  Widget _timelineRow(String title, String sub, bool active, bool last) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [CircleAvatar(radius: 7, backgroundColor: active ? primary : const Color(0xFFD8E2E4), child: active ? const Icon(Icons.check, size: 9, color: Colors.white) : null), if (!last) Container(width: 2, height: 36, color: active ? primary.withValues(alpha: 0.25) : const Color(0xFFE6ECEE))]),
      const SizedBox(width: 12),
      Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: active ? primary : Colors.black45, fontSize: 12)), const SizedBox(height: 2), Text(sub, style: TextStyle(color: active ? Colors.black54 : Colors.black38, fontSize: 10.5))]))),
    ]);
  }

  int _statusIndex(String status) {
    switch (status) {
      case 'ACCEPTED': return 1;
      case 'ARRIVING': return 2;
      case 'ARRIVED': return 3;
      case 'TRIP_STARTED': return 4;
      case 'COMPLETED': return 5;
      default: return 0;
    }
  }

  Widget _routeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [const Icon(Icons.radio_button_checked_rounded, color: primary, size: 16), Container(height: 36, width: 2, color: const Color(0xFFDDE6E8)), const Icon(Icons.location_on_rounded, color: accent, size: 19)]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Pickup', style: TextStyle(color: Colors.black45, fontSize: 10.5, fontWeight: FontWeight.w700)), Text(widget.pickupLocation, style: const TextStyle(color: primary, fontSize: 12.5, fontWeight: FontWeight.w700)), const SizedBox(height: 20), const Text('Destination', style: TextStyle(color: Colors.black45, fontSize: 10.5, fontWeight: FontWeight.w700)), Text(widget.dropLocation, style: const TextStyle(color: primary, fontSize: 12.5, fontWeight: FontWeight.w700))])),
      ]),
    );
  }

  Widget _tripMeta(Map<String, dynamic> booking) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
      child: Column(children: [
        _meta('Booking ID', widget.bookingId),
        const Divider(height: 20, color: border),
        _meta('Service', (booking['serviceType'] ?? 'Chauffeur Service').toString()),
        const Divider(height: 20, color: border),
        _meta('Fare', '₹${widget.fare.toStringAsFixed(0)}', highlight: true),
        if ((booking['otp'] ?? '').toString().isNotEmpty) ...[
          const Divider(height: 20, color: border),
          _meta('Trip OTP', (booking['otp'] ?? '').toString(), highlight: true),
        ],
      ]),
    );
  }

  Widget _meta(String label, String value, {bool highlight = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.black45, fontSize: 12)), Flexible(child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: highlight ? primary : Colors.black87, fontSize: 12.5, fontWeight: FontWeight.w800))) ]);

  Map<String, String> _vehicleData(Map<String, dynamic> booking, Map<String, dynamic> partner) {
    final raw = booking['assignedVehicle'];
    final vehicle = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    return {
      'model': (vehicle['model'] ?? partner['vehicleModel'] ?? partner['vehicleType'] ?? booking['vehicleType'] ?? '').toString(),
      'color': (vehicle['color'] ?? partner['vehicleColor'] ?? '').toString(),
      'number': (vehicle['number'] ?? partner['vehicleNumber'] ?? partner['registrationNumber'] ?? '').toString(),
    };
  }

  double _number(dynamic value, {double fallback = 0}) {
    final n = value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
    return n ?? fallback;
  }
}
