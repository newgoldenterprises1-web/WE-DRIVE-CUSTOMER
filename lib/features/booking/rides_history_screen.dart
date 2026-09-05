import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'trip_invoice_service.dart';

class RidesHistoryScreen extends StatelessWidget {
  const RidesHistoryScreen({super.key});

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Trip History",
          style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: user == null
          ? const Center(child: Text("Please log in to view trip history."))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              // Index error hatane ke liye orderBy query se hata diya hai
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: gold));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Error loading trips: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  );
                }

                // List ko latest trip first ke hisab se sort kiya hai
                final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
                  snapshot.data?.docs ?? [],
                );

                docs.sort((a, b) {
                  final aData = a.data();
                  final bData = b.data();
                  final aTime = aData['createdAt'] is Timestamp
                      ? (aData['createdAt'] as Timestamp).toDate()
                      : DateTime(2000);
                  final bTime = bData['createdAt'] is Timestamp
                      ? (bData['createdAt'] as Timestamp).toDate()
                      : DateTime(2000);
                  return bTime.compareTo(aTime);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.history_toggle_off_rounded, color: primary, size: 44),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "No Trips Yet",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Your piloted rides and tax invoices will appear here.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return _tripCard(context, data);
                  },
                );
              },
            ),
    );
  }

  Widget _tripCard(BuildContext context, Map<String, dynamic> data) {
    final String bookingId = data['bookingId'] ?? 'N/A';
    final String status = data['status'] ?? 'Completed';
    final double fare = (data['fare'] is num) ? (data['fare'] as num).toDouble() : 0.0;
    final String vehicle = data['vehicleType'] ?? 'Private Car';
    final String pickup = data['pickupLocation'] ?? 'Pickup location';
    final String drop = data['dropLocation'] ?? 'Drop location';
    final String chauffeur = data['chauffeurName'] ?? 'Mohammed Arif';

    DateTime? date;
    if (data['createdAt'] is Timestamp) {
      date = (data['createdAt'] as Timestamp).toDate();
    }
    final formattedDate = date != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(date)
        : 'Recent Trip';

    final bool isCompleted = status.toLowerCase() == 'completed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.shade50 : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: isCompleted ? Colors.green.shade700 : primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.directions_car_filled_rounded, color: primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    vehicle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary),
                  ),
                ],
              ),
              Text(
                "₹${fare.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primary),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.radio_button_checked, color: primary, size: 14),
                  Container(width: 1, height: 18, color: Colors.grey.shade300),
                  const Icon(Icons.location_on, color: gold, size: 16),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      drop,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                TripInvoiceService.downloadInvoice(
                  bookingId: bookingId,
                  vehicleType: vehicle,
                  pickupLocation: pickup,
                  dropLocation: drop,
                  fare: fare,
                  driverName: chauffeur,
                );
              },
              icon: const Icon(Icons.receipt_long_rounded, color: primary, size: 16),
              label: const Text(
                "Download Tax Invoice (PDF)",
                style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primary.withValues(alpha: 0.25)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}