import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'pickup_location_screen.dart';
import 'destination_location_screen.dart';
import '../fleet/widgets/fleet_selection_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  String pickupLocation = "Select pickup point";
  String destinationLocation = "Where are you going?";
  String selectedVehicle = "Sedan";

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  final List<String> vehicles = [
    "Sedan",
    "SUV",
    "Luxury",
    "Premium",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
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
          "Book Chauffeur",
          style: GoogleFonts.poppins(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildBookingTile(
                icon: Iconsax.location,
                title: "Pickup Location",
                value: pickupLocation,
                onTap: () async {
                  final result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PickupLocationScreen(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      pickupLocation = result;
                    });
                  }
                },
              ),

              const SizedBox(height: 18),

              _buildBookingTile(
                icon: Iconsax.location_add,
                title: "Destination",
                value: destinationLocation,
                onTap: () async {
                  final result = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const DestinationLocationScreen(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      destinationLocation = result;
                    });
                  }
                },
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: _buildSmallTile(
                      icon: Iconsax.calendar,
                      title: "Date",
                      value: DateFormat(
                        "dd MMM yyyy",
                      ).format(selectedDate),
                      onTap: _selectDate,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _buildSmallTile(
                      icon: Iconsax.clock,
                      title: "Time",
                      value: selectedTime.format(context),
                      onTap: _selectTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _buildBookingTile(
                icon: Iconsax.car,
                title: "Vehicle",
                value: selectedVehicle,
                onTap: _showVehicleSelector,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (pickupLocation ==
                        "Select pickup point") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select pickup location",
                          ),
                        ),
                      );
                      return;
                    }

                    if (destinationLocation ==
                        "Where are you going?") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select destination",
                          ),
                        ),
                      );
                      return;
                    }

                    // IMPORTANT:
                    // Pickup + Destination + Vehicle
                    // next screen ko pass ho rahe hain.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FleetSelectionScreen(
                          pickupLocation: pickupLocation,
                          dropLocation: destinationLocation,
                          selectedVehicle: selectedVehicle,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Iconsax.car,
                    color: Colors.white,
                  ),
                  label: Text(
                    "BOOK CHAUFFEUR",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: .5,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
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

  Widget _buildBookingTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: primary,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Iconsax.arrow_right_3),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: primary,
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _showVehicleSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];

              return ListTile(
                leading: const Icon(
                  Iconsax.car,
                  color: primary,
                ),
                title: Text(
                  vehicle,
                  style: GoogleFonts.poppins(),
                ),
                trailing: vehicle == selectedVehicle
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    selectedVehicle = vehicle;
                  });

                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}