import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocationPickerScreen extends StatefulWidget {
  const MapLocationPickerScreen({super.key, this.initialPosition});

  final LatLng? initialPosition;

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  static const Color primary = Color(0xFF174C52);
  static const LatLng defaultPosition = LatLng(17.3850, 78.4867);

  GoogleMapController? _controller;
  late LatLng _selected;
  String _address = 'Move the pin or tap the map to select a location';
  bool _loadingAddress = false;
  bool _locating = false;
  bool _searching = false;
  final TextEditingController _searchController = TextEditingController();

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
      final placemarks = await geocoding.placemarkFromCoordinates(
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
        if ((place.name ?? '').trim().isNotEmpty) place.name!.trim(),
        if ((place.street ?? '').trim().isNotEmpty) place.street!.trim(),
        if ((place.subLocality ?? '').trim().isNotEmpty)
          place.subLocality!.trim(),
        if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
        if ((place.administrativeArea ?? '').trim().isNotEmpty)
          place.administrativeArea!.trim(),
        if ((place.postalCode ?? '').trim().isNotEmpty) place.postalCode!.trim(),
      ];

      final unique = <String>[];
      for (final part in parts) {
        if (!unique.contains(part)) unique.add(part);
      }

      setState(() {
        _address = unique.isEmpty
            ? _coordinatesText(position)
            : unique.join(', ');
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

  String _coordinatesText(LatLng position) =>
      '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _searching) return;

    setState(() => _searching = true);
    try {
      final locations = await geocoding.locationFromAddress(query);
      if (locations.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location not found. Try a fuller address.')),
          );
        }
        return;
      }

      final location = locations.first;
      final target = LatLng(location.latitude, location.longitude);
      await _controller?.animateCamera(CameraUpdate.newLatLngZoom(target, 16));
      await _resolveAddress(target);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to search this location right now.')),
        );
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable device location services.')),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required to use your current location.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final target = LatLng(position.latitude, position.longitude);
      await _controller?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
      await _resolveAddress(target);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get current location right now.')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onMapTap(LatLng position) {
    _controller?.animateCamera(CameraUpdate.newLatLng(position));
    _resolveAddress(position);
  }

  void _onMarkerDragEnd(LatLng position) {
    _resolveAddress(position);
  }

  void _confirm() {
    final value = _address.trim();
    if (value.isEmpty || _loadingAddress) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selected, zoom: 15),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) => _controller = controller,
            onTap: _onMapTap,
            markers: {
              Marker(
                markerId: const MarkerId('selected-location'),
                position: _selected,
                draggable: true,
                onDragEnd: _onMarkerDragEnd,
                infoWindow: const InfoWindow(title: 'Selected location'),
              ),
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(18),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchLocation(),
                  decoration: InputDecoration(
                    hintText: 'Search area, landmark or address',
                    prefixIcon: const Icon(Icons.search, color: primary),
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            tooltip: 'Search',
                            onPressed: _searchLocation,
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 255,
            child: SafeArea(
              child: FloatingActionButton.small(
                heroTag: 'map-current-location',
                backgroundColor: Colors.white,
                foregroundColor: primary,
                onPressed: _goToCurrentLocation,
                child: _locating
                    ? const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 22,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: primary),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Selected Location',
                            style: TextStyle(
                              color: primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          'Drag pin to adjust',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _loadingAddress ? 'Finding address...' : _address,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _loadingAddress ? null : _confirm,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Use This Location', style: TextStyle(fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: primary.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
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
    _searchController.dispose();
    super.dispose();
  }
}
