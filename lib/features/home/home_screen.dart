import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../booking/pickup_drop_screen.dart';
import '../booking/chauffeur_status_screen.dart';
import '../fleet/fleet_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  // 1. RATE CARD MODAL (WE DRIVE MASTER MATRIX)
  void _showRateCard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.price_check_rounded, color: primary, size: 24),
                SizedBox(width: 10),
                Text(
                  "We Drive Master Rates",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("All-inclusive transparent pricing • Zero hidden fees", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 16),
            _rateRow("1 Hour City Package", "₹299 (Day)", "₹499 (Night)"),
            _rateRow("2 Hours Package", "₹349 (Day)", "₹549 (Night)"),
            _rateRow("4 Hours Package", "₹549 (Day)", "₹749 (Night)"),
            _rateRow("8 Hours Full Day", "₹949 (Day)", "₹1,149 (Night)"),
            _rateRow("12 Hours Package", "₹1,299 (Day)", "₹1,499 (Night)"),
            _rateRow("RGIA Airport Transfer", "₹999 (Normal)", "₹1,299 (Premium)"),
            const Divider(height: 20, color: border),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Night hours: 10:00 PM – 6:00 AM • Overstay: ₹2.50/min",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static Widget _rateRow(String title, String day, String night) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary)),
          Row(
            children: [
              Text(day, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: primary)),
              const Text(" • ", style: TextStyle(color: Colors.grey)),
              Text(night, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: gold)),
            ],
          ),
        ],
      ),
    );
  }

  // 2. TRIP HISTORY MODAL
  void _showTripHistory(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Your Trip History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('userId', isEqualTo: user?.uid ?? 'guest_user')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: gold));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off_rounded, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          Text("No Past Trips Found", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final item = docs[index].data();
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item['serviceType'] ?? 'Hourly Driver', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primary)),
                                Text("₹${item['fare'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.w900, color: primary, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("Pickup: ${item['pickupLocation'] ?? 'Hyderabad'}", style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text("Drop: ${item['dropLocation'] ?? 'Hyderabad'}", style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. SUPPORT & SAFETY DIALER
  void _showSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "We Drive Dedicated Support",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary),
            ),
            const SizedBox(height: 6),
            Text("24x7 Executive assistance for Hyderabad pilots and passengers.", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 18),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.phone_in_talk_rounded, color: Colors.green),
              ),
              title: const Text("Call Support Desk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
              subtitle: const Text("+91 98765 43210 (Direct Toll-Free)"),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse('tel:+919876543210');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.security_rounded, color: primary),
              ),
              title: const Text("Safety & Verification Policy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
              subtitle: const Text("100% Background and driving license verified pilots"),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  // 4. NOTIFICATIONS MODAL
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: primary, size: 22),
                SizedBox(width: 10),
                Text("Notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
              ],
            ),
            const SizedBox(height: 16),
            _notifTile(
              title: "Welcome to We Drive!",
              body: "Your premium private chauffeur service is active in Hyderabad.",
              time: "Just now",
              icon: Icons.verified_rounded,
            ),
            const SizedBox(height: 10),
            _notifTile(
              title: "Transparent Rates",
              body: "Starting ₹299 (1 Hour) & ₹349 (2 Hours). No surge pricing.",
              time: "Today",
              icon: Icons.military_tech_rounded,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _notifTile({required String title, required String body, required String time, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: primary.withValues(alpha: 0.1),
            child: Icon(icon, color: primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primary)),
                    Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(body, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. SCHEDULE DATE/TIME MODAL
  void _showScheduleModal(BuildContext context) {
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 2));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final formattedDate = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
          final formattedTime = selectedTime.format(context);

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: primary, size: 24),
                    SizedBox(width: 10),
                    Text("Schedule Chauffeur", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text("Book a verified chauffeur in advance for your planned ride.", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 20),

                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) setModalState(() => selectedDate = picked);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_available_rounded, color: primary, size: 20),
                            const SizedBox(width: 12),
                            Text("Pickup Date: $formattedDate", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: primary)),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: selectedTime);
                    if (picked != null) setModalState(() => selectedTime = picked);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled_rounded, color: primary, size: 20),
                            const SizedBox(width: 12),
                            Text("Pickup Time: $formattedTime", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: primary)),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PickupDropScreen(
                          serviceType: "Advance ($formattedDate at $formattedTime)",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Proceed to Pickup Location", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bg,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
              color: primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    child: const Icon(Icons.person_rounded, size: 36, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.displayName ?? "Shahed Hussain",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.phoneNumber ?? "+91 Hyderabad",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.directions_car_rounded, color: primary),
              title: const Text("My Garage", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FleetScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded, color: primary),
              title: const Text("Trip History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showTripHistory(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.price_check_rounded, color: primary),
              title: const Text("Rate Card", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showRateCard(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.headset_mic_rounded, color: primary),
              title: const Text("Support & Safety", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              onTap: () {
                Navigator.pop(context);
                _showSupport(context);
              },
            ),
            const Spacer(),
            const Divider(color: border),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (btnCtx) => InkWell(
                            onTap: () => Scaffold.of(btnCtx).openDrawer(),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                        const Text(
                          "WE DRIVE",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                        ),
                        InkWell(
                          onTap: () => _showNotifications(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Stack(
                              children: [
                                Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                                Positioned(top: 0, right: 0, child: CircleAvatar(radius: 4, backgroundColor: gold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text("Good Evening,", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(user?.displayName ?? "Shahed Hussain", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text("Where would you like to go today?", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PickupDropScreen(serviceType: 'Premium Chauffeur', isPremium: true, premiumFare: '₹799'),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2647),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: gold.withValues(alpha: 0.4), width: 1.2),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.military_tech_rounded, color: gold, size: 20),
                            SizedBox(width: 8),
                            Text("Book Premium Chauffeur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Quick Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.15,
                  children: [
                    _originalServiceCard(
                      title: "Hourly Driver",
                      subtitle: "Book by hour",
                      icon: Icons.access_time_rounded,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PickupDropScreen(serviceType: 'Hourly Driver')));
                      },
                    ),
                    _originalServiceCard(
                      title: "Airport",
                      subtitle: "Airport pickup",
                      icon: Icons.flight_takeoff_rounded,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PickupDropScreen(serviceType: 'Airport Transfer')));
                      },
                    ),
                    _originalServiceCard(
                      title: "Outstation",
                      subtitle: "Long distance",
                      icon: Icons.alt_route_rounded,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const PickupDropScreen(serviceType: 'Outstation')));
                      },
                    ),
                    _originalServiceCard(
                      title: "Advance",
                      subtitle: "Schedule ride",
                      icon: Icons.calendar_month_rounded,
                      onTap: () => _showScheduleModal(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Recent Trips", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).limit(1).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final data = snapshot.data!.docs.first.data();
                    return _buildTripCard(
                      context,
                      pickup: data['pickupLocation'] ?? "Attapur, Hyderabad",
                      drop: data['dropLocation'] ?? "Navirman Nagar, Hyderabad",
                      fare: (data['fare'] is num) ? (data['fare'] as num).toDouble() : 799.0,
                      vehicleType: data['vehicleType'] ?? "Car (Manual)",
                      bookingId: data['bookingId'] ?? "GXDKE2P0",
                      status: data['status'] ?? "Completed",
                    );
                  }
                  return _buildTripCard(
                    context,
                    pickup: "Attapur, Hyderabad",
                    drop: "Navirman Nagar, Hyderabad",
                    fare: 799.0,
                    vehicleType: "Car (Manual)",
                    bookingId: "GXDKE2P0",
                    status: "Completed",
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context, {
    required String pickup,
    required String drop,
    required double fare,
    required String vehicleType,
    required String bookingId,
    required String status,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChauffeurStatusScreen(
              pickupLocation: pickup,
              dropLocation: drop,
              fare: fare,
              vehicleType: vehicleType,
              bookingId: bookingId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: const Color(0xFF173B6D).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.history_rounded, color: primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text("Recent Trip", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                  child: Text(status, style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.radio_button_checked, color: Colors.green, size: 16),
                    Container(width: 1.5, height: 26, color: Colors.grey.shade300),
                    const Icon(Icons.location_on, color: Colors.red, size: 18),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pickup, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primary)),
                      const SizedBox(height: 20),
                      Text(drop, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text("Chauffeur", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.directions_car_outlined, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text(vehicleType, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFF1F5F9))),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("₹${fare.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primary)),
                const Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    SizedBox(width: 4),
                    Text("5.0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(bookingId, style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _originalServiceCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(color: const Color(0xFF173B6D).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primary)),
            const SizedBox(height: 3),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}