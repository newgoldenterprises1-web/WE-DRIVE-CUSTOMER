import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../booking/pickup_drop_screen.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  String? selectedVehicleId;
  Map<String, dynamic>? selectedVehicleData;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  CollectionReference<Map<String, dynamic>>? get _vehiclesRef {
    if (currentUser == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('vehicles');
  }

  void _navigateToBooking(Map<String, dynamic> car) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupDropScreen(
          serviceType: "Hourly Driver",
          vehicleData: car,
        ),
      ),
    );
  }

  void _showAddVehicleModal() {
    final modelCtrl = TextEditingController();
    final numberCtrl = TextEditingController();
    String transmission = "Automatic";
    String fuelType = "Petrol";
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
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
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Add Private Vehicle",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Register your personal vehicle for dedicated chauffeur piloting.",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: modelCtrl,
                    decoration: InputDecoration(
                      labelText: "Vehicle Model (e.g. Fortuner, City, Swift)",
                      prefixIcon: const Icon(Icons.directions_car_rounded, color: primary),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: border)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: numberCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: "Plate Number (e.g. TS 09 EA 1234)",
                      prefixIcon: const Icon(Icons.badge_rounded, color: primary),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: border)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text("Transmission", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _transmissionChoice("Automatic", transmission, () => setModalState(() => transmission = "Automatic")),
                      const SizedBox(width: 10),
                      _transmissionChoice("Manual", transmission, () => setModalState(() => transmission = "Manual")),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text("Fuel Type", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _transmissionChoice("Petrol", fuelType, () => setModalState(() => fuelType = "Petrol")),
                      const SizedBox(width: 8),
                      _transmissionChoice("Diesel", fuelType, () => setModalState(() => fuelType = "Diesel")),
                      const SizedBox(width: 8),
                      _transmissionChoice("EV / Hybrid", fuelType, () => setModalState(() => fuelType = "EV / Hybrid")),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final model = modelCtrl.text.trim();
                            final number = numberCtrl.text.trim();

                            if (model.isEmpty || number.isEmpty) return;
                            if (_vehiclesRef == null) return;

                            setModalState(() => isSubmitting = true);

                            try {
                              await _vehiclesRef!.add({
                                "model": model,
                                "number": number,
                                "transmission": transmission,
                                "fuel": fuelType,
                                "createdAt": FieldValue.serverTimestamp(),
                              });

                              if (ctx.mounted) Navigator.pop(ctx);
                            } catch (e) {
                              setModalState(() => isSubmitting = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Register to Garage",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _transmissionChoice(String type, String current, VoidCallback onTap) {
    final bool active = type == current;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? primary : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? primary : Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: active ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Garage",
          style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _vehiclesRef?.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: gold));
          }

          final docs = snapshot.data?.docs ?? [];

          // Auto-select first car if nothing is selected
          if (selectedVehicleId == null && docs.isNotEmpty) {
            selectedVehicleId = docs.first.id;
            selectedVehicleData = docs.first.data();
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              // 1. Luxury Assurance Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2647), Color(0xFF173B6D)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security_rounded, color: gold, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Piloted With Utmost Care",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "Verified pilots certified for manual & premium automatic gearboxes.",
                            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 2. Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Registered Vehicles",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primary),
                  ),
                  Text(
                    "${docs.length} Vehicles",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 3. Vehicles List from Firestore
              if (docs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.directions_car_outlined, size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      const Text(
                        "No Vehicles Registered",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Add your personal car to book verified chauffeurs instantly.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else
                ...docs.map((doc) => _premiumVehicleCard(doc.id, doc.data())),

              const SizedBox(height: 14),

              // 4. Add Vehicle Button
              InkWell(
                onTap: _showAddVehicleModal,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withValues(alpha: 0.35), width: 1.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Add Another Vehicle",
                        style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 90),
            ],
          );
        },
      ),
      bottomNavigationBar: selectedVehicleData != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: ElevatedButton(
                  onPressed: () => _navigateToBooking(selectedVehicleData!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Book For ${selectedVehicleData!['model']}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Row(
                        children: [
                          Text("Continue", style: TextStyle(color: gold, fontWeight: FontWeight.w700, fontSize: 13.5)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: gold, size: 17),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _premiumVehicleCard(String docId, Map<String, dynamic> car) {
    final bool isSelected = selectedVehicleId == docId;

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Remove Vehicle"),
            content: const Text("Are you sure you want to remove this vehicle from your garage?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Remove", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        _vehiclesRef?.doc(docId).delete();
        if (selectedVehicleId == docId) {
          setState(() {
            selectedVehicleId = null;
            selectedVehicleData = null;
          });
        }
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedVehicleId = docId;
            selectedVehicleData = car;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? gold : border,
              width: isSelected ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? primary.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.02),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Private Vehicle",
                      style: TextStyle(
                        color: isSelected ? Colors.white : primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "ACTIVE",
                            style: TextStyle(color: primary, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: isSelected ? primary : Colors.grey.shade400,
                        size: 22,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.directions_car_filled_rounded, color: primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car["model"] ?? "Unknown Car",
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: primary),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            car["number"] ?? "NO PLATE",
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _specBadge(car["transmission"] ?? "Auto"),
                      const SizedBox(width: 8),
                      _specBadge(car["fuel"] ?? "Petrol"),
                    ],
                  ),
                  InkWell(
                    onTap: () => _navigateToBooking(car),
                    child: const Row(
                      children: [
                        Text(
                          "Book Chauffeur",
                          style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: primary, size: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _specBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
      ),
    );
  }
}