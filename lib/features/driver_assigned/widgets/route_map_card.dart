import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteMapCard extends StatelessWidget {
  final CameraPosition initialPosition;
  final ValueChanged<GoogleMapController> onMapCreated;

  const RouteMapCard({
    super.key,
    required this.initialPosition,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GoogleMap(
          initialCameraPosition: initialPosition,
          onMapCreated: onMapCreated,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }
}