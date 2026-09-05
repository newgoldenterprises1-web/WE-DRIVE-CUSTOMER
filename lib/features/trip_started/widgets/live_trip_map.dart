import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LiveTripMap extends StatelessWidget {
  const LiveTripMap({
    super.key,
    required this.initialPosition,
    this.onMapCreated,
    this.markers = const {},
    this.polylines = const {},
  });

  final CameraPosition initialPosition;
  final void Function(GoogleMapController)? onMapCreated;
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  static const Color primaryColor = Color(0xFF173B6D);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialPosition,
            onMapCreated: onMapCreated,
            markers: markers,
            polylines: polylines,
            zoomControlsEnabled: false,
            compassEnabled: false,
            myLocationButtonEnabled: false,
            trafficEnabled: true,
            buildingsEnabled: true,
          ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 6,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Trip in Progress",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    "LIVE",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 18,
            right: 18,
            child: FloatingActionButton.small(
              heroTag: "live_trip_location",
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Map centered on the current trip location.')),
                );
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}