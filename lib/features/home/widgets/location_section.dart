import 'package:flutter/material.dart';

class LocationSection extends StatefulWidget {
  const LocationSection({super.key});

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();

  static const Color primary = Color(0xFF173B6D);

  @override
  void dispose() {
    pickupController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  Widget locationChip(
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget textField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: primary),
          suffixIcon: const Icon(Icons.search),
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Your Location",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),

        const SizedBox(height: 15),

        Container(
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xffEAF2FF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Stack(
            children: [

              const Center(
                child: Icon(
                  Icons.map,
                  size: 80,
                  color: Colors.blueGrey,
                ),
              ),

              Positioned(
                top: 15,
                right: 15,
                child: FloatingActionButton.small(
                  heroTag: "gps",
                  backgroundColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Current location detected.')),
                    );
                  },
                  child: const Icon(
                    Icons.my_location,
                    color: primary,
                  ),
                ),
              ),

              Positioned(
                bottom: 15,
                left: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Current Location Detected",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "LIVE",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [

            locationChip(
              Icons.home,
              "Home",
              Colors.green,
            ),

            const SizedBox(width: 10),

            locationChip(
              Icons.business,
              "Office",
              Colors.orange,
            ),

            const Spacer(),

            IconButton(
              onPressed: () {
                final temp = pickupController.text;
                pickupController.text = destinationController.text;
                destinationController.text = temp;
              },
              icon: const Icon(
                Icons.swap_vert_circle,
                color: primary,
                size: 34,
              ),
            )
          ],
        ),

        const SizedBox(height: 18),

        const Text(
          "Journey Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primary,
          ),
        ),

        const SizedBox(height: 16),

        textField(
          icon: Icons.radio_button_checked,
          hint: "Pickup Location",
          controller: pickupController,
        ),

        textField(
          icon: Icons.location_on,
          hint: "Destination",
          controller: destinationController,
        ),
      ],
    );
  }
}