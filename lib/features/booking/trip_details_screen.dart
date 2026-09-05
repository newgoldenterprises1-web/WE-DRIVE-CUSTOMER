import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/booking_service.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({
    super.key,
    this.booking,
  });

  final Map<String, dynamic>? booking;

  static const Color primary = Color(0xFF174C52);
  static const Color gold = Color(0xFF19A8A3);

  String _stringValue(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  Future<void> _makeCall(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String bookingId = _stringValue(
      booking ?? {},
      ['bookingId', 'id'],
      '',
    );

    if (bookingId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          title: const Text("Trip Details"),
        ),
        body: const Center(child: Text("No booking information found.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Chauffeur Status"),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: BookingService.watchBooking(bookingId),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? booking ?? <String, dynamic>{};

          final status = _stringValue(
            data,
            ['status', 'bookingStatus'],
            'searching',
          ).toLowerCase();

          final pickup = _stringValue(
            data,
            ['pickupLocation', 'pickup'],
            'Pickup Location',
          );
          final drop = _stringValue(
            data,
            ['dropLocation', 'drop'],
            'Destination',
          );
          final driverName = _stringValue(
            data,
            ['driverName', 'chauffeurName'],
            'Assigning Chauffeur...',
          );
          final driverPhone = _stringValue(
            data,
            ['driverPhone', 'phone'],
            '',
          );
          final fare = _stringValue(
            data,
            ['fareDisplay', 'fare'],
            '₹0',
          );
          final vehicle = _stringValue(
            data,
            ['vehicleType', 'serviceType'],
            'Customer Vehicle',
          );
          final otp = _stringValue(
            data,
            ['otp', 'startOtp'],
            '4821',
          );

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildStatusBanner(status),
                const SizedBox(height: 18),

                if (status == 'assigned' || status == 'arrived') ...[
                  _buildOtpCard(otp),
                  const SizedBox(height: 18),
                ],

                _buildChauffeurCard(driverName, driverPhone, status),
                const SizedBox(height: 18),

                _buildRouteCard(pickup, drop),
                const SizedBox(height: 18),

                _buildSummaryCard(vehicle, fare, bookingId),
                const SizedBox(height: 25),

                if (status == 'pending' || status == 'searching')
                  _buildCancelButton(context, bookingId),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBanner(String status) {
    String title = "Looking for nearby Chauffeur";
    String subtitle = "Connecting to the closest professional driver...";
    IconData icon = Icons.radar_rounded;
    Color color = gold;

    switch (status) {
      case 'assigned':
        title = "Chauffeur Assigned";
        subtitle = "Your driver is heading to your car location.";
        icon = Icons.directions_car_rounded;
        color = Colors.blue;
        break;
      case 'arrived':
        title = "Chauffeur Arrived";
        subtitle = "Your driver has arrived at your pickup spot.";
        icon = Icons.location_on_rounded;
        color = Colors.green;
        break;
      case 'on_trip':
        title = "Drive in Progress";
        subtitle = "Your chauffeur is driving your vehicle safely.";
        icon = Icons.verified_user_rounded;
        color = primary;
        break;
      case 'completed':
        title = "Trip Completed";
        subtitle = "You have reached your destination.";
        icon = Icons.check_circle_rounded;
        color = Colors.green;
        break;
      case 'cancelled':
        title = "Trip Cancelled";
        subtitle = "This booking was cancelled.";
        icon = Icons.cancel_rounded;
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCard(String otp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "RIDE START PIN",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: primary,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Share with chauffeur upon arrival",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              otp,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChauffeurCard(String name, String phone, String status) {
    final bool hasDriver = status != 'searching' && status != 'pending';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: primary.withValues(alpha: 0.08),
            child: const Icon(Icons.person, color: primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasDriver ? "Verified Professional Chauffeur" : "Searching closest driver...",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          if (hasDriver && phone.isNotEmpty)
            IconButton(
              onPressed: () => _makeCall(phone),
              icon: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFE8F2F1),
                child: Icon(Icons.call, color: primary, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(String pickup, String drop) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Drive Route",
            style: TextStyle(
              color: primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.radio_button_checked, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pickup,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Container(
              height: 24,
              width: 2,
              color: Colors.grey.shade300,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  drop,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String vehicle, String fare, String bookingId) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _row("Customer Vehicle", vehicle),
          const Divider(height: 20),
          _row("Total Fare", fare, bold: true),
          const Divider(height: 20),
          _row("Booking ID", bookingId.length > 8 ? bookingId.substring(0, 8).toUpperCase() : bookingId),
        ],
      ),
    );
  }

  Widget _row(String title, String val, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          val,
          style: TextStyle(
            color: primary,
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(BuildContext context, String bookingId) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (dCtx) => AlertDialog(
              title: const Text("Cancel Chauffeur Request?"),
              content: const Text("Are you sure you want to cancel this booking?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx, false),
                  child: const Text("No"),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dCtx, true),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Yes, Cancel"),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await BookingService.cancelBooking(bookingId: bookingId);
            if (!context.mounted) return;
            Navigator.pop(context);
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          "Cancel Request",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}