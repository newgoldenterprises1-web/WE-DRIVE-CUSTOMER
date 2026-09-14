import 'package:flutter/material.dart';

import '../booking/payment_screen.dart';

class VehicleSelectionScreen extends StatefulWidget {
  const VehicleSelectionScreen({
    super.key,
    this.serviceType = 'Hourly',
    this.pickupLocation = '',
    this.dropLocation = '',
    this.isPremium = false,
    this.premiumFare,
    this.selectedHours,
  });

  final String serviceType;
  final String pickupLocation;
  final String dropLocation;
  final bool isPremium;
  final double? premiumFare;
  final int? selectedHours;

  @override
  State<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  static const Color primary = Color(0xFF174C52);

  final TextEditingController notesController = TextEditingController();

  String transmission = "Manual";
  String carCategory = "Sedan";
  bool needUniformChauffeur = true;

  final Map<String, double> carBaseRates = {
    "Hatchback": 499.0,
    "Sedan": 599.0,
    "SUV": 799.0,
    "Luxury": 1299.0,
  };

  @override
  void initState() {
    super.initState();
    if (widget.isPremium) {
      carCategory = "Luxury";
      needUniformChauffeur = true;
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  double get calculatedFare {
    if (widget.isPremium && widget.premiumFare != null && widget.premiumFare! > 0) {
      return widget.premiumFare!;
    }
    double base = carBaseRates[carCategory] ?? 599.0;
    if (transmission == "Automatic") {
      base += 50.0;
    }
    if (widget.selectedHours != null && widget.selectedHours! > 1) {
      base = base * (widget.selectedHours! / 2);
    }
    return base;
  }

  void proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          serviceType: widget.serviceType,
          pickupLocation: widget.pickupLocation,
          dropLocation: widget.dropLocation,
          vehicleType: "$carCategory ($transmission)",
          fare: calculatedFare,
          selectedHours: widget.selectedHours,
          specialInstruction: notesController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fare = calculatedFare;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text("Your Car Details"),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.person_pin_rounded, color: primary, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hire a Chauffeur for Your Car",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Verified professional driver will arrive at your pickup point to drive your vehicle.",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Car Transmission",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _selectionTile(
                  title: "Manual",
                  icon: Icons.settings,
                  selected: transmission == "Manual",
                  onTap: () => setState(() => transmission = "Manual"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _selectionTile(
                  title: "Automatic",
                  icon: Icons.smart_toy_outlined,
                  selected: transmission == "Automatic",
                  onTap: () => setState(() => transmission = "Automatic"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Select Your Car Segment",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary),
          ),
          const SizedBox(height: 10),
          ...carBaseRates.keys.map((type) {
            final isSelected = carCategory == type;
            return InkWell(
              onTap: () => setState(() => carCategory = type),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_car_rounded, color: isSelected ? primary : Colors.grey, size: 26),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary),
                          ),
                          Text(
                            type == "Luxury" ? "BMW, Audi, Mercedes, Jaguar etc." : "Standard family vehicle",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${carBaseRates[type]!.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primary),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          TextField(
            controller: notesController,
            decoration: InputDecoration(
              hintText: "Car model (e.g. Honda City, Creta) or instructions",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: proceedToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ESTIMATED FARE", style: TextStyle(fontSize: 11, color: Colors.white70)),
                      Text(
                        "₹${fare.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text("Proceed to Hire", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectionTile({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? primary : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
