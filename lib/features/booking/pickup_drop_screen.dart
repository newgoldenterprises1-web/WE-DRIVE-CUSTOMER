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

  static const String mapplsKey = 'lzwhgoxvvuaxibujalzxyodoyeuijoeopkhf';

  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  final MapController mapController = MapController();

  late String transmission;
  int selectedHours = 2; // Default 2 hours
  int outstationDays = 1;

  bool isToAirport = true;
  bool isLoading = false;
  bool isSearching = false;
  bool isTargetPickup = false;

  static const ll.LatLng defaultLocation = ll.LatLng(17.3850, 78.4867);
  static const ll.LatLng airportLocation = ll.LatLng(17.2403, 78.4294);

  ll.LatLng pickupPos = defaultLocation;
  ll.LatLng? dropPos;
  List<ll.LatLng> routePoints = [];
  double? tripKm;
  int? tripMins;

  List<Map<String, dynamic>> searchList = [];
  Timer? _debounce;

  bool get isAirport => widget.serviceType.toLowerCase().contains("airport");
  bool get isOutstation => widget.serviceType.toLowerCase().contains("outstation");

  // Night Window: 10 PM to 6 AM
  bool get isNightTime {
    final hour = DateTime.now().hour;
    return hour >= 22 || hour < 6;
  }

  // Master Pricing Matrix
  static const Map<int, double> standardDayRates = {
    1: 299.0,
    2: 349.0,
    4: 549.0,
    6: 749.0,
    8: 949.0,
    12: 1299.0,
  };

  static const Map<int, double> standardNightRates = {
    1: 499.0,
    2: 549.0,
    4: 749.0,
    6: 949.0,
    8: 1149.0,
    12: 1499.0,
  };

  double get fare {
    if (isAirport) {
      return widget.isPremium ? 1299.0 : 999.0;
    }
    if (isOutstation) {
      return outstationDays * 1799.0;
    }
    final rateCard = isNightTime ? standardNightRates : standardDayRates;
    double base = rateCard[selectedHours] ?? (isNightTime ? 549.0 : 349.0);
    if (widget.isPremium) {
      base += 150.0; // Premium Chauffeur Tier
    }
    return base;
  }

  List<ll.LatLng> get _drivers => [
        ll.LatLng(pickupPos.latitude + 0.0035, pickupPos.longitude + 0.0028),
        ll.LatLng(pickupPos.latitude - 0.0029, pickupPos.longitude - 0.0032),
        ll.LatLng(pickupPos.latitude + 0.0018, pickupPos.longitude - 0.0041),
      ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedHours != null && standardDayRates.containsKey(widget.selectedHours)) {
      selectedHours = widget.selectedHours!;
    }

    final passedTransmission = widget.vehicleData?['transmission']?.toString();
    if (passedTransmission != null && passedTransmission.toLowerCase().contains('auto')) {
      transmission = "Automatic";
    } else {
      transmission = "Manual";
    }

    _handleAirportDefault();
    _fetchLiveGps();
  }

  void _handleAirportDefault() {
    if (isAirport) {
      if (isToAirport) {
        dropController.text = "RGIA Airport, Shamshabad";
        dropPos = airportLocation;
      } else {
        pickupController.text = "RGIA Airport, Shamshabad";
        pickupPos = airportLocation;
      }
      _getRoadRoute();
    }
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json';
      final res = await http.get(Uri.parse(url), headers: {'User-Agent': 'WeDriveApp'}).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final addr = data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final name = addr['suburb'] ?? addr['neighbourhood'] ?? addr['road'] ?? addr['city_district'] ?? data['name'];
          if (name != null && name.toString().isNotEmpty) {
            return "${name.toString()}, Hyderabad";
          }
        }
      }
    } catch (_) {}
    return "Current Location, Hyderabad";
  }

  Future<void> _fetchLiveGps() async {
    if (isAirport && !isToAirport) return;
    setState(() => isLoading = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) return;

      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      pickupPos = ll.LatLng(pos.latitude, pos.longitude);

      final addressName = await _reverseGeocode(pos.latitude, pos.longitude);
      pickupController.text = addressName;

      mapController.move(pickupPos, 15.2);
      if (dropPos != null) _getRoadRoute();
    } catch (_) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _getRoadRoute() async {
    if (dropPos == null) return;
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${pickupPos.longitude},${pickupPos.latitude};${dropPos!.longitude},${dropPos!.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = json.decode(res.body)['routes'][0];
        final coords = data['geometry']['coordinates'] as List;

        setState(() {
          routePoints = coords.map((c) => ll.LatLng(c[1].toDouble(), c[0].toDouble())).toList();
          tripKm = double.parse((data['distance'] / 1000).toStringAsFixed(1));
          tripMins = (data['duration'] / 60).round();
        });

        mapController.move(
          ll.LatLng((pickupPos.latitude + dropPos!.latitude) / 2, (pickupPos.longitude + dropPos!.longitude) / 2),
          13.0,
        );
      }
    } catch (_) {}
  }

  void _onSearch(String val, bool isPickup) {
    _debounce?.cancel();
    isTargetPickup = isPickup;

    if (val.trim().length < 2) {
      setState(() => searchList = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => isSearching = true);
      try {
        final url = 'https://atlas.mappls.com/api/places/geocode?'
            'address=${Uri.encodeComponent(val.trim())}&'
            'itemCount=7&'
            'bias=17.3850,78.4867';

        final res = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $mapplsKey'},
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          final List copResults = data['copResults'] ?? [];

          setState(() {
            searchList = copResults.map((item) {
              return {
                'title': item['placeName'] ?? item['placeAddress']?.split(',')[0] ?? val,
                'sub': item['placeAddress'] ?? 'Hyderabad',
                'lat': double.tryParse(item['latitude'].toString()) ?? 17.3850,
                'lon': double.tryParse(item['longitude'].toString()) ?? 78.4867,
              };
            }).toList();
          });
        } else {
          _fallbackSearch(val);
        }
      } catch (_) {
        _fallbackSearch(val);
      } finally {
        if (mounted) setState(() => isSearching = false);
      }
    });
  }

  Future<void> _fallbackSearch(String val) async {
    try {
      final cleanQuery = Uri.encodeComponent(val.trim());
      final url = 'https://nominatim.openstreetmap.org/search?'
          'q=$cleanQuery&format=json&addressdetails=1&limit=6&countrycodes=in&viewbox=78.18,17.60,78.68,17.18&bounded=0';

      final res = await http.get(Uri.parse(url), headers: {'User-Agent': 'WeDriveHyderabad/1.0'}).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        setState(() {
          searchList = list.map((item) {
            final addr = item['address'] as Map<String, dynamic>? ?? {};
            final title = item['name'] != null && item['name'].toString().isNotEmpty
                ? item['name'].toString()
                : item['display_name'].toString().split(',')[0];
            final area = addr['suburb'] ?? addr['neighbourhood'] ?? addr['road'] ?? 'Hyderabad';

            return {
              'title': title,
              'sub': "$area, Hyderabad",
              'lat': double.parse(item['lat']),
              'lon': double.parse(item['lon']),
            };
          }).toList();
        });
      }
    } catch (_) {}
  }

  void _applySelection(ll.LatLng target, String name) {
    setState(() {
      if (isTargetPickup) {
        pickupPos = target;
        pickupController.text = name;
      } else {
        dropPos = target;
        dropController.text = name;
      }
      searchList = [];
    });
    FocusScope.of(context).unfocus();
    mapController.move(target, 15.2);
    _getRoadRoute();
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropController.dispose();
    _debounce?.cancel();
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
        title: Text(widget.serviceType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: Stack(
        children: [
          // 1. MAP
          SizedBox(
            height: 350,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(initialCenter: pickupPos, initialZoom: 15.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=m,traffic&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.wedrive.app',
                ),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: routePoints, strokeWidth: 5.5, color: const Color(0xFF1A73E8)),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: pickupPos,
                      width: 52,
                      height: 52,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1A73E8).withValues(alpha: 0.20),
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                            ),
                            child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 19),
                          ),
                        ],
                      ),
                    ),
                    ..._drivers.map((pos) => Marker(
                          point: pos,
                          width: 38,
                          height: 38,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: primary, width: 1.8),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                            ),
                            child: const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.person_pin, color: primary, size: 22),
                                Positioned(top: 2, right: 2, child: CircleAvatar(radius: 4, backgroundColor: Colors.green)),
                              ],
                            ),
                          ),
                        )),
                    if (dropPos != null)
                      Marker(
                        point: dropPos!,
                        width: 44,
                        height: 44,
                        child: const Icon(Icons.location_on, color: Color(0xFFEA4335), size: 44),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ESTIMATE METRICS
          if (tripKm != null && tripMins != null)
            Positioned(
              top: 14,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("$tripKm km", style: const TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 13)),
                    Container(height: 14, width: 1, color: border),
                    Text("$tripMins mins", style: const TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 13)),
                    Container(height: 14, width: 1, color: border),
                    const Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text("Pilots Active", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // GPS Button
          Positioned(
            top: 270,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A73E8),
              elevation: 4,
              onPressed: isLoading ? null : _fetchLiveGps,
              child: isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location, size: 20),
            ),
          ),

          // 2. BOTTOM CONTROLS
          DraggableScrollableSheet(
            initialChildSize: 0.58,
            minChildSize: 0.45,
            maxChildSize: 0.94,
            builder: (_, sc) => Container(
              decoration: const BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, -3))],
              ),
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // GARAGE VEHICLE STRIP
                  if (widget.vehicleData != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: gold.withValues(alpha: 0.4), width: 1.2),
                      ),
                      child: Row(
                        children: [
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
                              children: [
                                Text(
                                  widget.vehicleData!['model'] ?? "Your Car",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary),
                                ),
                                Text(
                                  "${widget.vehicleData!['number'] ?? ''} • $transmission",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: gold.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(6)),
                            child: const Text("GARAGE", style: TextStyle(color: primary, fontSize: 9.5, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // 🛫 AIRPORT TRANSFER SELECTOR
                  if (isAirport) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _airportToggle("Drop to RGIA", isToAirport, () {
                            setState(() {
                              isToAirport = true;
                              _handleAirportDefault();
                            });
                          }),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _airportToggle("Pickup from RGIA", !isToAirport, () {
                            setState(() {
                              isToAirport = false;
                              _handleAirportDefault();
                            });
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ]
                  // 🛣️ OUTSTATION DAYS SELECTOR
                  else if (isOutstation) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Outstation Trip Duration", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                          child: const Text("₹1,799 / day", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [1, 2, 3, 5].map((days) {
                        final isSel = outstationDays == days;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: InkWell(
                              onTap: () => setState(() => outstationDays = days),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSel ? primary : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isSel ? primary : border),
                                ),
                                child: Center(
                                  child: Text(
                                    "$days Day${days > 1 ? 's' : ''}",
                                    style: TextStyle(color: isSel ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ]
                  // ⏱️ STANDARD & PREMIUM HOURLY PACKAGES
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select Duration Package",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isNightTime ? const Color(0xFF1E1B4B) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isNightTime ? "Night Fare (10 PM - 6 AM)" : "Standard Day Fare",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isNightTime ? Colors.amber : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [1, 2, 4, 6, 8, 12].map((hours) {
                        final bool isSel = selectedHours == hours;
                        final double rate = (isNightTime ? standardNightRates[hours] : standardDayRates[hours]) ?? 0;
                        final double finalRate = widget.isPremium ? rate + 150 : rate;

                        return InkWell(
                          onTap: () => setState(() => selectedHours = hours),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? primary : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSel ? primary : border),
                              boxShadow: [
                                if (isSel) BoxShadow(color: primary.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "${hours}h Package",
                                  style: TextStyle(color: isSel ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "₹${finalRate.toStringAsFixed(0)}",
                                  style: TextStyle(color: isSel ? gold : Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // TRANSMISSION
                  const Text("Car Transmission", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _gearChip("Manual", Icons.tune, transmission == "Manual", () => setState(() => transmission = "Manual"))),
                      const SizedBox(width: 10),
                      Expanded(child: _gearChip("Automatic", Icons.bolt, transmission == "Automatic", () => setState(() => transmission = "Automatic"))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ADDRESS
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: pickupController,
                          onChanged: (val) => _onSearch(val, true),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.radio_button_checked, color: Color(0xFF1A73E8), size: 18),
                            hintText: 'Pickup address',
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(height: 8, color: Color(0xFFF1F5F9)),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: dropController,
                                onChanged: (val) => _onSearch(val, false),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.location_on, color: Color(0xFFEA4335), size: 20),
                                  hintText: 'Drop destination',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            if (isSearching)
                              const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)))
                            else
                              IconButton(
                                icon: const Icon(Icons.map_outlined, color: primary, size: 20),
                                onPressed: () async {
                                  final selected = await Navigator.push<ll.LatLng>(
                                    context,
                                    MaterialPageRoute(builder: (_) => DropPicker(initial: dropPos ?? pickupPos)),
                                  );
                                  if (selected != null) {
                                    final addr = await _reverseGeocode(selected.latitude, selected.longitude);
                                    _applySelection(selected, addr);
                                  }
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // SEARCH LIST
                  if (searchList.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        children: searchList.map((item) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.place_rounded, color: primary, size: 20),
                            title: Text(item['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary)),
                            subtitle: Text(item['sub'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                            onTap: () => _applySelection(ll.LatLng(item['lat'], item['lon']), item['title']),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _pill('Jubilee Hills', () {
                        isTargetPickup = false;
                        _applySelection(const ll.LatLng(17.4319, 78.4073), 'Jubilee Hills');
                      }),
                      const SizedBox(width: 6),
                      _pill('Hitec City', () {
                        isTargetPickup = false;
                        _applySelection(const ll.LatLng(17.4474, 78.3762), 'Hitec City');
                      }),
                      const SizedBox(width: 6),
                      _pill('Gachibowli', () {
                        isTargetPickup = false;
                        _applySelection(const ll.LatLng(17.4401, 78.3489), 'Gachibowli');
                      }),
                    ],
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. BOTTOM ACTION BAR
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          child: ElevatedButton(
            onPressed: () {
              if (pickupController.text.isEmpty || dropController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select pickup & drop locations')));
                return;
              }

              final String carLabel = widget.vehicleData != null
                  ? "${widget.vehicleData!['model']} (${widget.vehicleData!['number']})"
                  : "Car ($transmission)";

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    serviceType: widget.serviceType,
                    pickupLocation: pickupController.text,
                    dropLocation: dropController.text,
                    vehicleType: carLabel,
                    fare: fare,
                    selectedHours: isAirport ? null : selectedHours,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${fare.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const Text(
                      "All-Inclusive • Zero Hidden Fees",
                      style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text("Confirm Chauffeur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
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

  Widget _airportToggle(String label, bool isSel, VoidCallback tap) => InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSel ? primary : border),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: isSel ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
          ),
        ),
      );

  Widget _gearChip(String label, IconData icon, bool sel, VoidCallback tap) => InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? primary : border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: sel ? Colors.white : primary),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: sel ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      );

  Widget _pill(String title, VoidCallback tap) => InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Text(title, style: const TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w600)),
        ),
      );
}

class DropPicker extends StatefulWidget {
  final ll.LatLng initial;
  const DropPicker({super.key, required this.initial});

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
        title: const Text("Select Destination", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              onPositionChanged: (pos, _) => pos.center != null ? center = pos.center! : null,
            ),
            children: [
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
              child: const Text("Confirm Location", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}