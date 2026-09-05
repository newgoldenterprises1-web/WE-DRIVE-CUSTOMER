import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'widgets/location_search_card.dart';
import 'widgets/map_view.dart';
import 'widgets/recent_places.dart';
import 'widgets/saved_places.dart';
import '../vehicle/vehicle_selection_screen.dart';

class PickupDropScreen extends StatefulWidget {
  const PickupDropScreen({super.key});

  @override
  State<PickupDropScreen> createState() => _PickupDropScreenState();
}

class _PickupDropScreenState extends State<PickupDropScreen> {
  final pickupController = TextEditingController();
  final dropController = TextEditingController();

  GoogleMapController? mapController;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(17.3850, 78.4867), // Hyderabad
    zoom: 14,
  );

  @override
  void dispose() {
    pickupController.dispose();
    dropController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  void continueBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const VehicleSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF173B6D),
        foregroundColor: Colors.white,
        title: const Text("Pickup & Drop"),
      ),

      body: Stack(
        children: [
          SizedBox(
            height: 320,
            child: MapView(
              initialPosition: initialPosition,
              onMapCreated: (controller) {
                mapController = controller;
              },
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.58,
            minChildSize: 0.50,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xffF5F7FA),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 10),

                    Center(
                      child: Container(
                        width: 55,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    LocationSearchCard(
                      pickupController: pickupController,
                      dropController: dropController,
                      onPickupTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pickup location selected.')),
                        );
                      },
                      onDropTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Drop location selected.')),
                        );
                      },
                    ),

                    SavedPlaces(
                      onHomeTap: () {
                        dropController.text = 'Home';
                      },
                      onWorkTap: () {
                        dropController.text = 'Office';
                      },
                      onFavoriteTap: () {
                        dropController.text = 'Favourite Place';
                      },
                    ),

                    const SizedBox(height: 25),

                    RecentPlaces(
                      onPlaceTap: (address) {
                        dropController.text = address;
                      },
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: const Color(0xFF173B6D),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Current location selected.')),
          );
        },
        child: const Icon(Icons.my_location),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: continueBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173B6D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}