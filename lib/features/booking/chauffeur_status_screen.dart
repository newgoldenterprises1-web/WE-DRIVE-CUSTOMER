import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _cancelBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Cancel Chauffeur Request?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text("Are you sure you want to cancel your booked chauffeur?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).update({
        'status': 'cancelled',
      });
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            backgroundColor: bg,
            body: Center(child: CircularProgressIndicator(color: gold)),
          );
        }

        final data = snapshot.data!.data() ?? {};
        final String status = (data['status'] ?? 'searching').toString().toLowerCase();

        final bool isAssigned = status == 'assigned' || status == 'en route' || status == 'ongoing' || status == 'completed';
        final String driverName = data['chauffeurName'] ?? 'Assigned Chauffeur';
        final String driverPhone = data['chauffeurPhone'] ?? '';
        final double driverRating = (data['chauffeurRating'] is num) ? (data['chauffeurRating'] as num).toDouble() : 4.90;
        final String otpCode = data['otp'] ?? '----';
        final String etaText = data['eta'] ?? 'Nearby';

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _appBarTitle(status),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isAssigned) _searchingBanner() else _statusBanner(status, etaText),
                const SizedBox(height: 16),
                if (!isAssigned)
                  _standbyPlaceholder()
                else
                  _driverDetailsCard(driverName, driverPhone, driverRating, otpCode, status),
                const SizedBox(height: 16),
                _routeCard(),
                const SizedBox(height: 16),
                _summaryCard(),
                const SizedBox(height: 24),
                if (status != 'completed')
                  OutlinedButton(
                    onPressed: _cancelBooking,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade200),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      isAssigned ? "Cancel Booking" : "Cancel Request",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _appBarTitle(String status) {
    switch (status) {
      case 'searching':
        return "Finding Chauffeur";
      case 'en route':
      case 'assigned':
        return "Chauffeur En Route";
      case 'ongoing':
        return "Trip In Progress";
      case 'completed':
        return "Trip Finished";
      default:
        return "Chauffeur Status";
    }
  }

  Widget _searchingBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: gold, strokeWidth: 2.5),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assigning Executive Pilot",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  "Connecting with closest professional driver...",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner(String status, String eta) {
    Color bannerColor = const Color(0xFF0D5C3A);
    String title = "Chauffeur Assigned!";
    String sub = "Arriving in $eta at your car location";

    if (status == 'ongoing') {
      bannerColor = primary;
      title = "Executive Trip In Progress";
      sub = "Safe and comfortable drive to your destination";
    } else if (status == 'completed') {
      bannerColor = Colors.teal.shade800;
      title = "Trip Completed Successfully";
      sub = "Thank you for riding with We Drive";
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _standbyPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: primary.withValues(alpha: 0.08),
            child: const Icon(Icons.person_rounded, color: primary, size: 26),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pilot Dispatching...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
              SizedBox(height: 3),
              Text("Matching background-verified chauffeur", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _driverDetailsCard(String name, String phone, double rating, String otp, String status) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person_rounded, color: primary, size: 34),
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primary)),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, color: gold, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: gold, size: 16),
                        const SizedBox(width: 3),
                        Text("$rating", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primary)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                          child: const Text("Uniformed", style: TextStyle(color: primary, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (phone.isNotEmpty)
                IconButton(
                  onPressed: () => _makeCall(phone),
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), shape: BoxShape.circle),
                    child: const Icon(Icons.phone_rounded, color: primary, size: 20),
                  ),
                ),
            ],
          ),
          if (status != 'ongoing' && status != 'completed') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: gold.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("START TRIP OTP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 2),
                      Text("Share with pilot upon car arrival", style: TextStyle(fontSize: 11, color: primary)),
                    ],
                  ),
                  Text(
                    otp,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primary, letterSpacing: 3),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _routeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Drive Route", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.radio_button_checked, color: primary, size: 16),
                  Container(width: 1.5, height: 28, color: Colors.grey.shade300),
                  const Icon(Icons.location_on, color: gold, size: 18),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.pickupLocation, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primary)),
                    const SizedBox(height: 22),
                    Text(widget.dropLocation, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          _metaRow("Vehicle Assigned", widget.vehicleType),
          const Divider(height: 22, color: Color(0xFFF1F5F9)),
          _metaRow("All-Inclusive Bill", "₹${widget.fare.toStringAsFixed(0)}", isHighlight: true),
          const Divider(height: 22, color: Color(0xFFF1F5F9)),
          _metaRow("Booking ID", widget.bookingId),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? primary : Colors.black87,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.bold,
            fontSize: isHighlight ? 16 : 13,
          ),
        ),
      ],
    );
  }
}