import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocationPickerScreen extends StatefulWidget {
  const MapLocationPickerScreen({
    super.key,
    this.initialPosition,
  });

  final LatLng? initialPosition;

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState
    extends State<MapLocationPickerScreen> {
  static const Color primary = Color(0xFF174C52);
  static const LatLng defaultPosition = LatLng(17.3850, 78.4867);

  final Geocoding _geocoding = Geocoding();

  GoogleMapController? _controller;

  late LatLng _selected;
  String _address = 'Move the map or tap a place to select it';
  bool _loadingAddress = false;

  @override
  void initState() {
    super.initState();

    _selected = widget.initialPosition ?? defaultPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveAddress(_selected);
    });
  }

  Future<void> _resolveAddress(LatLng position) async {
    if (!mounted) return;

    setState(() {
      _selected = position;
      _loadingAddress = true;
    });

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isEmpty) {
        setState(() {
          _address = _coordinatesText(position);
          _loadingAddress = false;
        });
        return;
      }

      final place = placemarks.first;

      final parts = <String>[
        if ((place.name ?? '').trim().isNotEmpty)
          place.name!.trim(),
        if ((place.street ?? '').trim().isNotEmpty)
          place.street!.trim(),
        if ((place.subLocality ?? '').trim().isNotEmpty)
          place.subLocality!.trim(),
        if ((place.locality ?? '').trim().isNotEmpty)
          place.locality!.trim(),
        if ((place.administrativeArea ?? '').trim().isNotEmpty)
          place.administrativeArea!.trim(),
      ];

      final uniqueParts = <String>[];

      for (final part in parts) {
        if (!uniqueParts.contains(part)) {
          uniqueParts.add(part);
        }
      }

      setState(() {
        _address = uniqueParts.isEmpty
            ? _coordinatesText(position)
            : uniqueParts.join(', ');
        _loadingAddress = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _address = _coordinatesText(position);
        _loadingAddress = false;
      });
    }
  }

  String _coordinatesText(LatLng position) {
    return '${position.latitude.toStringAsFixed(6)}, '
        '${position.longitude.toStringAsFixed(6)}';
  }

  Future<void> _selectOnMap(LatLng position) async {
    if (!mounted) return;

    setState(() {
      _selected = position;
    });

    await _resolveAddress(position);
  }

  Future<void> _goToCurrentLocation() async {
    try {
      if (_controller == null) return;

      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(
          _selected,
          16,
        ),
      );
    } catch (_) {
      // Keep the map usable even if camera animation fails.
    }
  }

  void _confirm() {
    final value = _address.trim();

    if (value.isEmpty) {
      return;
    }

    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Select on Map',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selected,
              zoom: 14.5,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _controller = controller;
            },
            onTap: _selectOnMap,
            markers: {
              Marker(
                markerId: const MarkerId('selected-drop'),
                position: _selected,
                infoWindow: const InfoWindow(
                  title: 'Selected Drop Location',
                ),
              ),
            },
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Drop Location',
                      style: TextStyle(
                        color: primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _loadingAddress
                          ? 'Finding address...'
                          : _address,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            _loadingAddress ? null : _confirm,
                        icon: const Icon(
                          Icons.check_rounded,
                        ),
                        label: const Text(
                          'Use This Location',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          disabledBackgroundColor:
                              primary.withValues(alpha: 0.35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 210,
            child: SafeArea(
              child: FloatingActionButton.small(
                heroTag: 'map-current-location',
                backgroundColor: Colors.white,
                foregroundColor: primary,
                elevation: 5,
                onPressed: _goToCurrentLocation,
                child: const Icon(
                  Icons.my_location_rounded,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }
}