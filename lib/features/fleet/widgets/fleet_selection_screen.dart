import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../booking/vehicle_card.dart';
import '../../booking/fare_summary_screen.dart';

class FleetSelectionScreen extends StatefulWidget {
  final String pickupLocation;
  final String dropLocation;
  final String selectedVehicle;

  const FleetSelectionScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.selectedVehicle,
  });

  @override
  State<FleetSelectionScreen> createState() =>
      _FleetSelectionScreenState();
}

class _FleetSelectionScreenState extends State<FleetSelectionScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  late int selectedIndex;

  final List<Map<String, dynamic>> vehicles = [
    {
      "name": "Sedan",
      "capacity": "4 Seats",
      "arrivalTime": "Arrives in 3 min",
      "price": "₹799",
      "icon": Icons.directions_car_rounded,
      "recommended": true,
    },
    {
      "name": "SUV",
      "capacity": "6 Seats",
      "arrivalTime": "Arrives in 5 min",
      "price": "₹1199",
      "icon": Icons.airport_shuttle_rounded,
      "recommended": false,
    },
    {
      "name": "Premium",
      "capacity": "4 Seats",
      "arrivalTime": "Arrives in 4 min",
      "price": "₹1799",
      "icon": Icons.directions_car_filled_rounded,
      "recommended": false,
    },
    {
      "name": "Luxury",
      "capacity": "4 Seats",
      "arrivalTime": "Arrives in 3 min",
      "price": "₹2499",
      "icon": Icons.local_taxi_rounded,
      "recommended": false,
    },
  ];

  @override
  void initState() {
    super.initState();

    final index = vehicles.indexWhere(
      (vehicle) => vehicle["name"] == widget.selectedVehicle,
    );

    selectedIndex = index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = vehicles[selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primary,
          ),
        ),
        title: Text(
          "Choose Vehicle",
          style: GoogleFonts.poppins(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose the perfect chauffeur vehicle for your trip.",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];

                    return VehicleCard(
                      icon: vehicle["icon"] as IconData,
                      title: vehicle["name"] as String,
                      capacity: vehicle["capacity"] as String,
                      arrivalTime: vehicle["arrivalTime"] as String,
                      price: vehicle["price"] as String,
                      selected: selectedIndex == index,
                      recommended: vehicle["recommended"] as bool,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FareSummaryScreen(
                          pickupLocation: widget.pickupLocation,
                          dropLocation: widget.dropLocation,
                          selectedVehicle:
                              selectedVehicle["name"] as String,
                          vehiclePrice:
                              selectedVehicle["price"] as String,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    "CONTINUE",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: .5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}