import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;

import 'payment_screen.dart';

class PickupDropScreen extends StatefulWidget {
  const PickupDropScreen({
    super.key,
    this.serviceType = 'Hourly Driver',
    this.isPremium = false,
    this.premiumFare,
    this.selectedHours,
    this.vehicleData,
  });

  final String serviceType;
  final bool isPremium;
  final String? premiumFare;
  final int? selectedHours;
  final Map<String, dynamic>? vehicleData;

  @override
  State<PickupDropScreen> createState() => _PickupDropScreenState();
}

class _PickupDropScreenState extends State<PickupDropScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();
  final MapController mapController = MapController();
  final List<TextEditingController> stopControllers = <TextEditingController>[];
  final List<ll.LatLng?> stopPositions = <ll.LatLng?>[];

  static const ll.LatLng defaultLocation = ll.LatLng(17.3850, 78.4867);
  static const ll.LatLng airportLocation = ll.LatLng(17.2403, 78.4294);

  static const Map<int, double> standardDayRates = <int, double>{
    1: 299,
    2: 349,
    4: 549,
    6: 749,
    8: 949,
    12: 1299,
  };

  static const Map<int, double> standardNightRates = <int, double>{
    1: 499,
    2: 549,
    4: 749,
    6: 949,
    8: 1149,
    12: 1499,
  };

  late String transmission;
  int selectedHours = 2;
  int outstationDays = 1;
  String tripType = 'One Way';
  bool isToAirport = true;
  bool isLoading = false;
  bool isSearching = false;
  bool searchPickup = false;
  int? searchStopIndex;

  ll.LatLng pickupPos = defaultLocation;
  ll.LatLng? dropPos;
  List<ll.LatLng> routePoints = <ll.LatLng>[];
  double? tripKm;
  int? tripMins;
  List<Map<String, dynamic>> searchList = <Map<String, dynamic>>[];
  Timer? debounce;

  bool get isAirport => widget.serviceType.toLowerCase().contains('airport');
  bool get isOutstation => widget.serviceType.toLowerCase().contains('outstation');

  bool get isNightTime {
    final int hour = DateTime.now().hour;
    return hour >= 22 || hour < 6;
  }

  double get fare {
    if (isAirport) {
      return widget.isPremium ? 1299 : 999;
    }
    if (isOutstation) {
      return outstationDays * 1799;
    }
    final Map<int, double> rates = isNightTime ? standardNightRates : standardDayRates;
    return (rates[selectedHours] ?? 349) + (widget.isPremium ? 150 : 0);
  }

  List<ll.LatLng> get routeLocations {
    final List<ll.LatLng> points = <ll.LatLng>[pickupPos];
    for (final ll.LatLng? position in stopPositions) {
      if (position != null) {
        points.add(position);
      }
    }
    if (dropPos != null) {
      points.add(dropPos!);
    }
    if (tripType == 'Round Trip') {
      points.add(pickupPos);
    }
    return points;
  }

  List<ll.LatLng> get driverPositions {
    return <ll.LatLng>[
      ll.LatLng(pickupPos.latitude + 0.0035, pickupPos.longitude + 0.0028),
      ll.LatLng(pickupPos.latitude - 0.0029, pickupPos.longitude - 0.0032),
      ll.LatLng(pickupPos.latitude + 0.0018, pickupPos.longitude - 0.0041),
    ];
  }

  String get routeSummary {
    final List<String> parts = <String>[
      'Pickup: ${pickupController.text.trim()}',
    ];
    for (int i = 0; i < stopControllers.length; i++) {
      parts.add('Stop ${i + 1}: ${stopControllers[i].text.trim()}');
    }
    parts.add('Final Drop: ${dropController.text.trim()}');
    if (tripType == 'Round Trip') {
      parts.add('Return: Pickup');
    }
    return parts.join(' • ');
  }

  @override
  void initState() {
    super.initState();
    selectedHours = widget.selectedHours != null && standardDayRates.containsKey(widget.selectedHours)
        ? widget.selectedHours!
        : 2;
    final String vehicleTransmission = widget.vehicleData?['transmission']?.toString() ?? '';
    transmission = vehicleTransmission.toLowerCase().contains('auto')
        ? 'Automatic'
        : 'Manual';
    handleAirportDefault();
    fetchLiveGps();
  }

  void handleAirportDefault() {
    if (!isAirport) {
      return;
    }
    if (isToAirport) {
      dropController.text = 'RGIA Airport, Shamshabad';
      dropPos = airportLocation;
    } else {
      pickupController.text = 'RGIA Airport, Shamshabad';
      pickupPos = airportLocation;
    }
    getRoadRoute();
  }

  Future<String> reverseGeocode(double latitude, double longitude) async {
    try {
      final String url = 'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: <String, String>{'User-Agent': 'WeDriveApp'},
      ).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final Map<String, dynamic>? address = data['address'] as Map<String, dynamic>?;
        final dynamic name = address?['suburb'] ??
            address?['neighbourhood'] ??
            address?['road'] ??
            address?['city_district'] ??
            data['name'];
        if (name != null && name.toString().isNotEmpty) {
          return '${name.toString()}, Hyderabad';
        }
      }
    } catch (_) {}
    return 'Current Location, Hyderabad';
  }

  Future<void> fetchLiveGps() async {
    if (isAirport && !isToAirport) {
      return;
    }
    if (mounted) {
      setState(() => isLoading = true);
    }
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      pickupPos = ll.LatLng(position.latitude, position.longitude);
      pickupController.text = await reverseGeocode(position.latitude, position.longitude);
      mapController.move(pickupPos, 15.2);
      if (dropPos != null) {
        getRoadRoute();
      }
    } catch (_) {
      // Keep the default location when GPS is unavailable.
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> getRoadRoute() async {
    final List<ll.LatLng> points = routeLocations;
    if (points.length < 2) {
      return;
    }
    final String coordinates = points
        .map((ll.LatLng point) => '${point.longitude},${point.latitude}')
        .join(';');
    try {
      final http.Response response = await http.get(
        Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson',
        ),
      ).timeout(const Duration(seconds: 7));
      if (response.statusCode != 200) {
        return;
      }
      final dynamic body = json.decode(response.body);
      final List<dynamic> routes = body['routes'] as List<dynamic>? ?? <dynamic>[];
      if (routes.isEmpty) {
        return;
      }
      final Map<String, dynamic> route = routes.first as Map<String, dynamic>;
      final List<dynamic> geometry = route['geometry']['coordinates'] as List<dynamic>;
      if (!mounted) {
        return;
      }
      setState(() {
        routePoints = geometry.map<ll.LatLng>((dynamic coordinate) {
          final List<dynamic> pair = coordinate as List<dynamic>;
          return ll.LatLng(
            (pair[1] as num).toDouble(),
            (pair[0] as num).toDouble(),
          );
        }).toList();
        tripKm = double.parse(((route['distance'] as num) / 1000).toStringAsFixed(1));
        tripMins = ((route['duration'] as num) / 60).round();
      });
    } catch (_) {}
  }

  void onSearchChanged(String value, {required bool pickup, int? stopIndex}) {
    debounce?.cancel();
    searchPickup = pickup;
    searchStopIndex = stopIndex;
    if (value.trim().length < 2) {
      setState(() => searchList = <Map<String, dynamic>>[]);
      return;
    }
    debounce = Timer(const Duration(milliseconds: 300), () async {
      if (mounted) {
        setState(() => isSearching = true);
      }
      await searchLocations(value);
      if (mounted) {
        setState(() => isSearching = false);
      }
    });
  }

  Future<void> searchLocations(String value) async {
    try {
      final String url = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(value.trim())}&format=json&addressdetails=1&limit=6&countrycodes=in&viewbox=78.18,17.60,78.68,17.18&bounded=0';
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: <String, String>{'User-Agent': 'WeDriveHyderabad/1.0'},
      ).timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) {
        return;
      }
      final List<dynamic> list = json.decode(response.body) as List<dynamic>;
      if (!mounted) {
        return;
      }
      final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];
      for (final dynamic item in list) {
        final Map<String, dynamic> data = item as Map<String, dynamic>;
        final Map<String, dynamic> address = data['address'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final String display = data['display_name']?.toString() ?? 'Hyderabad';
        final String title = data['name']?.toString().isNotEmpty == true
            ? data['name'].toString()
            : display.split(',').first;
        final dynamic area = address['suburb'] ?? address['neighbourhood'] ?? address['road'] ?? 'Hyderabad';
        results.add(<String, dynamic>{
          'title': title,
          'sub': '$area, Hyderabad',
          'lat': double.tryParse(data['lat']?.toString() ?? '') ?? defaultLocation.latitude,
          'lon': double.tryParse(data['lon']?.toString() ?? '') ?? defaultLocation.longitude,
        });
      }
      setState(() => searchList = results);
    } catch (_) {}
  }

  void applySelection(ll.LatLng target, String name) {
    setState(() {
      if (searchStopIndex != null) {
        final int index = searchStopIndex!;
        if (index < stopControllers.length) {
          stopControllers[index].text = name;
          stopPositions[index] = target;
        }
      } else if (searchPickup) {
        pickupPos = target;
        pickupController.text = name;
      } else {
        dropPos = target;
        dropController.text = name;
      }
      searchList = <Map<String, dynamic>>[];
    });
    FocusScope.of(context).unfocus();
    mapController.move(target, 15.2);
    getRoadRoute();
  }

  Future<void> pickMapLocation({bool pickup = false, int? stopIndex}) async {
    final ll.LatLng initial = pickup
        ? pickupPos
        : stopIndex != null
            ? (stopPositions[stopIndex] ?? pickupPos)
            : (dropPos ?? pickupPos);
    final ll.LatLng? selected = await Navigator.push<ll.LatLng>(
      context,
      MaterialPageRoute<ll.LatLng>(
        builder: (_) => DropPicker(
          initial: initial,
          title: stopIndex != null
              ? 'Select Stop ${stopIndex + 1}'
              : pickup
                  ? 'Select Pickup'
                  : 'Select Destination',
        ),
      ),
    );
    if (selected == null) {
      return;
    }
    final String address = await reverseGeocode(selected.latitude, selected.longitude);
    if (stopIndex != null) {
      setState(() {
        stopPositions[stopIndex] = selected;
        stopControllers[stopIndex].text = address;
      });
      getRoadRoute();
      return;
    }
    searchPickup = pickup;
    searchStopIndex = null;
    applySelection(selected, address);
  }

  void addStop() {
    if (stopControllers.length >= 3) {
      return;
    }
    setState(() {
      stopControllers.add(TextEditingController());
      stopPositions.add(null);
    });
  }

  void removeStop(int index) {
    if (index < 0 || index >= stopControllers.length) {
      return;
    }
    final TextEditingController controller = stopControllers.removeAt(index);
    controller.dispose();
    stopPositions.removeAt(index);
    setState(() {});
    getRoadRoute();
  }

  void confirmBooking() {
    if (pickupController.text.trim().isEmpty || dropController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select pickup & drop locations')),
      );
      return;
    }
    for (int i = 0; i < stopControllers.length; i++) {
      if (stopControllers[i].text.trim().isEmpty || stopPositions[i] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Select Stop ${i + 1} location')),
        );
        return;
      }
    }

    final String carLabel = widget.vehicleData != null
        ? '${widget.vehicleData!['model']} (${widget.vehicleData!['number']})'
        : 'Car ($transmission)';

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PaymentScreen(
          serviceType: widget.serviceType,
          pickupLocation: pickupController.text,
          dropLocation: routeSummary,
          vehicleType: carLabel,
          fare: fare,
          selectedHours: isAirport ? null : selectedHours,
        ),
      ),
    );
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropController.dispose();
    for (final TextEditingController controller in stopControllers) {
      controller.dispose();
    }
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          widget.serviceType,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: Stack(
        children: <Widget>[
          SizedBox(height: 350, child: buildMap()),
          if (tripKm != null && tripMins != null) buildRouteStats(),
          Positioned(
            top: 270,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A73E8),
              onPressed: isLoading ? null : fetchLiveGps,
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 20),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.60,
            minChildSize: 0.45,
            maxChildSize: 0.94,
            builder: (_, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, -3)),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  children: buildContent(),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: ElevatedButton(
            onPressed: confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '₹${fare.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const Text(
                      'All-Inclusive • Zero Hidden Fees',
                      style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Row(
                  children: <Widget>[
                    Text(
                      'Confirm Chauffeur',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCenter: pickupPos, initialZoom: 15),
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://mt1.google.com/vt/lyrs=m,traffic&x={x}&y={y}&z={z}',
          userAgentPackageName: 'com.wedrive.app',
        ),
        if (routePoints.isNotEmpty)
          PolylineLayer(
            polylines: <Polyline>[
              Polyline(
                points: routePoints,
                strokeWidth: 5.5,
                color: const Color(0xFF1A73E8),
              ),
            ],
          ),
        MarkerLayer(markers: buildMarkers()),
      ],
    );
  }

  List<Marker> buildMarkers() {
    final List<Marker> markers = <Marker>[
      Marker(
        point: pickupPos,
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 20),
        ),
      ),
    ];

    for (int i = 0; i < stopPositions.length; i++) {
      final ll.LatLng? position = stopPositions[i];
      if (position != null) {
        markers.add(
          Marker(
            point: position,
            width: 40,
            height: 40,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: gold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '${i + 1}',
                style: const TextStyle(color: primary, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        );
      }
    }

    if (dropPos != null) {
      markers.add(
        Marker(
          point: dropPos!,
          width: 44,
          height: 44,
          child: const Icon(Icons.location_on, color: Color(0xFFEA4335), size: 44),
        ),
      );
    }

    for (final ll.LatLng position in driverPositions) {
      markers.add(
        Marker(
          point: position,
          width: 36,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: primary, width: 1.5),
            ),
            child: const Icon(Icons.person_pin, color: primary, size: 21),
          ),
        ),
      );
    }
    return markers;
  }

  Widget buildRouteStats() {
    return Positioned(
      top: 14,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text('$tripKm km', style: const TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 13)),
            Container(height: 14, width: 1, color: border),
            Text('$tripMins mins', style: const TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 13)),
            Container(height: 14, width: 1, color: border),
            const Row(
              children: <Widget>[
                Icon(Icons.verified, color: Colors.green, size: 14),
                SizedBox(width: 4),
                Text('Pilots Active', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildContent() {
    final List<Widget> content = <Widget>[
      Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      const SizedBox(height: 14),
    ];

    if (widget.vehicleData != null) {
      content.add(buildVehicleCard());
      content.add(const SizedBox(height: 14));
    }

    if (isAirport) {
      content.add(buildAirportOptions());
      content.add(const SizedBox(height: 14));
    } else if (isOutstation) {
      content.add(buildOutstationOptions());
      content.add(const SizedBox(height: 14));
    } else {
      content.add(buildHourlyOptions());
      content.add(const SizedBox(height: 14));
    }

    content.add(const Text('Trip Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)));
    content.add(const SizedBox(height: 8));
    content.add(buildTripType());

    if (tripType == 'Round Trip') {
      content.add(const SizedBox(height: 8));
      content.add(buildRoundTripInfo());
    }

    content.add(const SizedBox(height: 14));
    content.add(const Text('Car Transmission', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)));
    content.add(const SizedBox(height: 8));
    content.add(buildTransmission());
    content.add(const SizedBox(height: 14));
    content.add(buildRouteCard());

    if (searchList.isNotEmpty) {
      content.add(const SizedBox(height: 8));
      content.add(buildSearchResults());
    }

    content.add(const SizedBox(height: 12));
    content.add(buildQuickLocations());
    content.add(const SizedBox(height: 90));
    return content;
  }

  Widget buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.directions_car_filled_rounded, color: primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.vehicleData?['model']?.toString() ?? 'Your Car',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary),
                ),
                Text(
                  '${widget.vehicleData?['number']?.toString() ?? ''} • $transmission',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('GARAGE', style: TextStyle(color: primary, fontSize: 9.5, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget buildAirportOptions() {
    return Row(
      children: <Widget>[
        Expanded(child: airportToggle('Drop to RGIA', isToAirport, () {
          setState(() => isToAirport = true);
          handleAirportDefault();
        })),
        const SizedBox(width: 10),
        Expanded(child: airportToggle('Pickup from RGIA', !isToAirport, () {
          setState(() => isToAirport = false);
          handleAirportDefault();
        })),
      ],
    );
  }

  Widget buildOutstationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Outstation Trip Duration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
              child: const Text('₹1,799 / day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            for (final int days in <int>[1, 2, 3, 5])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () => setState(() => outstationDays = days),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: outstationDays == days ? primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: outstationDays == days ? primary : border),
                      ),
                      child: Center(
                        child: Text(
                          '$days Day${days > 1 ? 's' : ''}',
                          style: TextStyle(color: outstationDays == days ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget buildHourlyOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Select Duration Package', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isNightTime ? const Color(0xFF1E1B4B) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isNightTime ? 'Night Fare (10 PM - 6 AM)' : 'Standard Day Fare',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isNightTime ? Colors.amber : const Color(0xFF92400E)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final int hours in <int>[1, 2, 4, 6, 8, 12]) buildHourPackage(hours),
          ],
        ),
      ],
    );
  }

  Widget buildHourPackage(int hours) {
    final Map<int, double> rates = isNightTime ? standardNightRates : standardDayRates;
    final double rate = (rates[hours] ?? 0) + (widget.isPremium ? 150 : 0);
    final bool selected = selectedHours == hours;
    return InkWell(
      onTap: () => setState(() => selectedHours = hours),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? primary : border),
        ),
        child: Column(
          children: <Widget>[
            Text('${hours}h Package', style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12.5)),
            const SizedBox(height: 2),
            Text('₹${rate.toStringAsFixed(0)}', style: TextStyle(color: selected ? gold : Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }

  Widget buildTripType() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
      child: Row(
        children: <Widget>[
          Expanded(child: tripTypeButton('One Way', Icons.arrow_forward_rounded, tripType == 'One Way', () {
            setState(() => tripType = 'One Way');
            getRoadRoute();
          })),
          Expanded(child: tripTypeButton('Round Trip', Icons.sync_rounded, tripType == 'Round Trip', () {
            setState(() => tripType = 'Round Trip');
            getRoadRoute();
          })),
        ],
      ),
    );
  }

  Widget tripTypeButton(String label, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(color: selected ? primary : Colors.transparent, borderRadius: BorderRadius.circular(11)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 17, color: selected ? Colors.white : primary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }

  Widget buildRoundTripInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: gold.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: <Widget>[
          Icon(Icons.info_outline, color: primary, size: 17),
          SizedBox(width: 7),
          Expanded(child: Text('Route returns to the pickup point after final drop.', style: TextStyle(fontSize: 11.5, color: primary, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget buildTransmission() {
    return Row(
      children: <Widget>[
        Expanded(child: gearChip('Manual', Icons.tune, transmission == 'Manual', () => setState(() => transmission = 'Manual'))),
        const SizedBox(width: 10),
        Expanded(child: gearChip('Automatic', Icons.bolt, transmission == 'Automatic', () => setState(() => transmission = 'Automatic'))),
      ],
    );
  }

  Widget buildRouteCard() {
    final List<Widget> children = <Widget>[
      locationRow(pickupController, Icons.radio_button_checked, const Color(0xFF1A73E8), 'Pickup address', true),
      Padding(padding: const EdgeInsets.only(left: 14), child: Container(height: 12, width: 1.5, color: border)),
    ];

    for (int i = 0; i < stopControllers.length; i++) {
      children.add(stopRow(i));
      children.add(Padding(padding: const EdgeInsets.only(left: 14), child: Container(height: 12, width: 1.5, color: border)));
    }

    children.add(locationRow(dropController, Icons.location_on, const Color(0xFFEA4335), 'Final drop destination', false));
    children.add(const SizedBox(height: 8));
    children.add(
      Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton.icon(
          onPressed: stopControllers.length < 3 ? addStop : null,
          icon: const Icon(Icons.add_road, size: 17),
          label: Text(stopControllers.length < 3 ? 'Add Stop' : 'Maximum 3 Stops'),
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
      child: Column(children: children),
    );
  }

  Widget locationRow(TextEditingController controller, IconData icon, Color iconColor, String hint, bool pickup) {
    return Row(
      children: <Widget>[
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: (String value) => onSearchChanged(value, pickup: pickup),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
            decoration: InputDecoration(hintText: hint, border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10)),
          ),
        ),
        IconButton(onPressed: () => pickMapLocation(pickup: pickup), icon: const Icon(Icons.map_outlined, color: primary, size: 20)),
      ],
    );
  }

  Widget stopRow(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: gold, shape: BoxShape.circle),
          child: Text('${index + 1}', style: const TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: 11)),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            controller: stopControllers[index],
            onChanged: (String value) => onSearchChanged(value, pickup: false, stopIndex: index),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
            decoration: InputDecoration(hintText: 'Stop ${index + 1}', border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10)),
          ),
        ),
        IconButton(onPressed: () => pickMapLocation(stopIndex: index), icon: const Icon(Icons.map_outlined, color: primary, size: 20)),
        IconButton(onPressed: () => removeStop(index), icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 19)),
      ],
    );
  }

  Widget buildSearchResults() {
    final List<Widget> items = <Widget>[];
    for (final Map<String, dynamic> item in searchList) {
      items.add(
        ListTile(
          dense: true,
          leading: const Icon(Icons.place_rounded, color: primary, size: 20),
          title: Text(item['title']?.toString() ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary)),
          subtitle: Text(item['sub']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
          onTap: () => applySelection(ll.LatLng(item['lat'] as double, item['lon'] as double), item['title'].toString()),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
      child: Column(children: items),
    );
  }

  Widget buildQuickLocations() {
    return Wrap(
      spacing: 6,
      children: <Widget>[
        quickPill('Jubilee Hills', const ll.LatLng(17.4319, 78.4073)),
        quickPill('Hitec City', const ll.LatLng(17.4474, 78.3762)),
        quickPill('Gachibowli', const ll.LatLng(17.4401, 78.3489)),
      ],
    );
  }

  Widget airportToggle(String label, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: selected ? primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? primary : border)),
        child: Center(child: Text(label, style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12.5))),
      ),
    );
  }

  Widget gearChip(String label, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: selected ? primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? primary : border)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 16, color: selected ? Colors.white : primary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget quickPill(String title, ll.LatLng position) {
    return InkWell(
      onTap: () {
        searchPickup = false;
        searchStopIndex = null;
        applySelection(position, title);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: Text(title, style: const TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class DropPicker extends StatefulWidget {
  const DropPicker({super.key, required this.initial, this.title = 'Select Destination'});

  final ll.LatLng initial;
  final String title;

  @override
  State<DropPicker> createState() => _DropPickerState();
}

class _DropPickerState extends State<DropPicker> {
  late ll.LatLng center;

  @override
  void initState() {
    super.initState();
    center = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF173B6D),
        foregroundColor: Colors.white,
        title: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              onPositionChanged: (MapCamera camera, bool hasGesture) {
                center = camera.center;
              },
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=m,traffic&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.wedrive.app',
              ),
            ],
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 32),
              child: Icon(Icons.location_on, color: Color(0xFFEA4335), size: 46),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, center),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF173B6D),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Confirm Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}
