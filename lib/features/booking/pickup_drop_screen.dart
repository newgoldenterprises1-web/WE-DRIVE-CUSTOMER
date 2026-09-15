import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;

import 'payment_screen.dart';

class PickupDropScreen extends StatefulWidget {
  const PickupDropScreen({super.key, this.serviceType = 'Hourly Driver', this.isPremium = false, this.premiumFare, this.selectedHours, this.vehicleData});
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

  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  final MapController mapController = MapController();
  late String transmission;
  int selectedHours = 2;
  int outstationDays = 1;
  String tripType = 'One Way';
  bool isToAirport = true;
  bool isLoading = false;
  bool isSearching = false;
  bool searchPickup = false;
  int? searchStopIndex;

  static const ll.LatLng defaultLocation = ll.LatLng(17.3850, 78.4867);
  static const ll.LatLng airportLocation = ll.LatLng(17.2403, 78.4294);
  ll.LatLng pickupPos = defaultLocation;
  ll.LatLng? dropPos;
  final List<TextEditingController> stopControllers = [];
  final List<ll.LatLng?> stopPositions = [];
  List<ll.LatLng> routePoints = [];
  double? tripKm;
  int? tripMins;
  List<Map<String, dynamic>> searchList = [];
  Timer? _debounce;

  bool get isAirport => widget.serviceType.toLowerCase().contains('airport');
  bool get isOutstation => widget.serviceType.toLowerCase().contains('outstation');
  bool get isNightTime { final h = DateTime.now().hour; return h >= 22 || h < 6; }

  static const Map<int, double> standardDayRates = {1: 299, 2: 349, 4: 549, 6: 749, 8: 949, 12: 1299};
  static const Map<int, double> standardNightRates = {1: 499, 2: 549, 4: 749, 6: 949, 8: 1149, 12: 1499};

  double get fare {
    if (isAirport) return widget.isPremium ? 1299 : 999;
    if (isOutstation) return outstationDays * 1799;
    final rates = isNightTime ? standardNightRates : standardDayRates;
    return (rates[selectedHours] ?? 349) + (widget.isPremium ? 150 : 0);
  }

  List<ll.LatLng> get _routeLocations {
    final points = <ll.LatLng>[pickupPos];
    for (final p in stopPositions) {
      if (p != null) points.add(p);
    }
    if (dropPos != null) points.add(dropPos!);
    if (tripType == 'Round Trip') points.add(pickupPos);
    return points;
  }

  List<ll.LatLng> get _drivers => [
    ll.LatLng(pickupPos.latitude + .0035, pickupPos.longitude + .0028),
    ll.LatLng(pickupPos.latitude - .0029, pickupPos.longitude - .0032),
    ll.LatLng(pickupPos.latitude + .0018, pickupPos.longitude - .0041),
  ];

  String get _routeSummary {
    final p = <String>['Pickup: ${pickupController.text.trim()}'];
    for (var i = 0; i < stopControllers.length; i++) {
      p.add('Stop ${i + 1}: ${stopControllers[i].text.trim()}');
    }
    p.add('Final Drop: ${dropController.text.trim()}');
    if (tripType == 'Round Trip') p.add('Return: Pickup');
    return p.join(' • ');
  }

  @override
  void initState() {
    super.initState();
    if (widget.selectedHours != null && standardDayRates.containsKey(widget.selectedHours)) selectedHours = widget.selectedHours!;
    final t = widget.vehicleData?['transmission']?.toString() ?? '';
    transmission = t.toLowerCase().contains('auto') ? 'Automatic' : 'Manual';
    _handleAirportDefault();
    _fetchLiveGps();
  }

  void _handleAirportDefault() {
    if (!isAirport) return;
    if (isToAirport) { dropController.text = 'RGIA Airport, Shamshabad'; dropPos = airportLocation; }
    else { pickupController.text = 'RGIA Airport, Shamshabad'; pickupPos = airportLocation; }
    _getRoadRoute();
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json';
      final res = await http.get(Uri.parse(url), headers: {'User-Agent': 'WeDriveApp'}).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final a = data['address'] as Map<String, dynamic>?;
        final n = a?['suburb'] ?? a?['neighbourhood'] ?? a?['road'] ?? a?['city_district'] ?? data['name'];
        if (n != null && n.toString().isNotEmpty) return '${n.toString()}, Hyderabad';
      }
    } catch (_) {}
    return 'Current Location, Hyderabad';
  }

  Future<void> _fetchLiveGps() async {
    if (isAirport && !isToAirport) return;
    if (mounted) setState(() => isLoading = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      pickupPos = ll.LatLng(pos.latitude, pos.longitude);
      pickupController.text = await _reverseGeocode(pos.latitude, pos.longitude);
      mapController.move(pickupPos, 15.2);
      if (dropPos != null) _getRoadRoute();
    } catch (_) {} finally { if (mounted) setState(() => isLoading = false); }
  }

  Future<void> _getRoadRoute() async {
    final points = _routeLocations;
    if (points.length < 2) return;
    final coords = points.map((p) => '${p.longitude},${p.latitude}').join(';');
    try {
      final res = await http.get(Uri.parse('https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson')).timeout(const Duration(seconds: 7));
      if (res.statusCode != 200) return;
      final body = json.decode(res.body);
      if (body['routes'] == null || (body['routes'] as List).isEmpty) return;
      final data = body['routes'][0];
      final geometry = data['geometry']['coordinates'] as List;
      if (!mounted) return;
      setState(() {
        routePoints = geometry.map((c) => ll.LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
        tripKm = double.parse(((data['distance'] as num) / 1000).toStringAsFixed(1));
        tripMins = ((data['duration'] as num) / 60).round();
      });
    } catch (_) {}
  }

  void _onSearch(String value, {required bool pickup, int? stopIndex}) {
    _debounce?.cancel();
    searchPickup = pickup;
    searchStopIndex = stopIndex;
    if (value.trim().length < 2) { setState(() => searchList = []); return; }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (mounted) setState(() => isSearching = true);
      await _fallbackSearch(value);
      if (mounted) setState(() => isSearching = false);
    });
  }

  Future<void> _fallbackSearch(String value) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(value.trim())}&format=json&addressdetails=1&limit=6&countrycodes=in&viewbox=78.18,17.60,78.68,17.18&bounded=0';
      final res = await http.get(Uri.parse(url), headers: {'User-Agent': 'WeDriveHyderabad/1.0'}).timeout(const Duration(seconds: 4));
      if (res.statusCode != 200) return;
      final List list = json.decode(res.body);
      if (!mounted) return;
      setState(() {
        searchList = list.map((item) {
          final a = item['address'] as Map<String, dynamic>? ?? {};
          final title = item['name'] != null && item['name'].toString().isNotEmpty ? item['name'].toString() : item['display_name'].toString().split(',').first;
          final area = a['suburb'] ?? a['neighbourhood'] ?? a['road'] ?? 'Hyderabad';
          return {'title': title, 'sub': '$area, Hyderabad', 'lat': double.parse(item['lat']), 'lon': double.parse(item['lon'])};
        }).toList();
      });
    } catch (_) {}
  }

  void _applySelection(ll.LatLng target, String name) {
    setState(() {
      if (searchStopIndex != null) {
        final i = searchStopIndex!;
        if (i < stopControllers.length) { stopControllers[i].text = name; stopPositions[i] = target; }
      } else if (searchPickup) { pickupPos = target; pickupController.text = name; }
      else { dropPos = target; dropController.text = name; }
      searchList = [];
    });
    FocusScope.of(context).unfocus();
    mapController.move(target, 15.2);
    _getRoadRoute();
  }

  Future<void> _pickMapLocation({bool pickup = false, int? stopIndex}) async {
    final initial = pickup ? pickupPos : stopIndex != null ? (stopPositions[stopIndex] ?? pickupPos) : (dropPos ?? pickupPos);
    final selected = await Navigator.push<ll.LatLng>(context, MaterialPageRoute(builder: (_) => DropPicker(initial: initial, title: stopIndex != null ? 'Select Stop ${stopIndex + 1}' : pickup ? 'Select Pickup' : 'Select Destination')));
    if (selected == null) return;
    final addr = await _reverseGeocode(selected.latitude, selected.longitude);
    if (stopIndex != null) {
      setState(() { stopPositions[stopIndex] = selected; stopControllers[stopIndex].text = addr; });
      _getRoadRoute();
    } else { searchPickup = pickup; searchStopIndex = null; _applySelection(selected, addr); }
  }

  void _addStop() {
    if (stopControllers.length >= 3) return;
    setState(() { stopControllers.add(TextEditingController()); stopPositions.add(null); });
  }

  void _removeStop(int index) {
    if (index < 0 || index >= stopControllers.length) return;
    stopControllers.removeAt(index).dispose();
    stopPositions.removeAt(index);
    setState(() {});
    _getRoadRoute();
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropController.dispose();
    for (final c in stopControllers) c.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(backgroundColor: primary, foregroundColor: Colors.white, centerTitle: true, elevation: 0, title: Text(widget.serviceType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),
      body: Stack(children: [
        SizedBox(height: 350, child: FlutterMap(
          mapController: mapController,
          options: MapOptions(initialCenter: pickupPos, initialZoom: 15),
          children: [
            TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m,traffic&x={x}&y={y}&z={z}', userAgentPackageName: 'com.wedrive.app'),
            if (routePoints.isNotEmpty) PolylineLayer(polylines: [Polyline(points: routePoints, strokeWidth: 5.5, color: const Color(0xFF1A73E8))]),
            MarkerLayer(markers: [
              Marker(point: pickupPos, width: 50, height: 50, child: Container(decoration: BoxDecoration(color: primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)]), child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 20))),
              ...stopPositions.asMap().entries.where((e) => e.value != null).map((e) => Marker(point: e.value!, width: 40, height: 40, child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: gold, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: Text('${e.key + 1}', style: const TextStyle(color: primary, fontWeight: FontWeight.w900))))),
              if (dropPos != null) Marker(point: dropPos!, width: 44, height: 44, child: const Icon(Icons.location_on, color: Color(0xFFEA4335), size: 44)),
              ..._drivers.map((p) => Marker(point: p, width: 36, height: 36, child: Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: primary, width: 1.5)), child: const Icon(Icons.person_pin, color: primary, size: 21)))),
            ]),
          ],
        )),
        if (tripKm != null && tripMins != null) Positioned(top: 14, left: 20, right: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text('$tripKm km', style: const TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 13)), Container(height: 14, width: 1, color: border), Text('$tripMins mins', style: const TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 13)), Container(height: 14, width: 1, color: border), const Row(children: [Icon(Icons.verified, color: Colors.green, size: 14), SizedBox(width: 4), Text('Pilots Active', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12))])]))),
        Positioned(top: 270, right: 16, child: FloatingActionButton.small(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1A73E8), elevation: 4, onPressed: isLoading ? null : _fetchLiveGps, child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location, size: 20))),
        DraggableScrollableSheet(initialChildSize: .60, minChildSize: .45, maxChildSize: .94, builder: (_, sc) => Container(
          decoration: const BoxDecoration(color: bg, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, -3))]),
          child: ListView(controller: sc, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 14),
            if (widget.vehicleData != null) ...[
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: gold.withValues(alpha: .4))), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primary.withValues(alpha: .08), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.directions_car_filled_rounded, color: primary, size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.vehicleData!['model'] ?? 'Your Car', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primary)), Text('${widget.vehicleData!['number'] ?? ''} • $transmission', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: gold.withValues(alpha: .18), borderRadius: BorderRadius.circular(6)), child: const Text('GARAGE', style: TextStyle(color: primary, fontSize: 9.5, fontWeight: FontWeight.w900)))])),
              const SizedBox(height: 14),
            ],
            if (isAirport) ...[
              Row(children: [Expanded(child: _airportToggle('Drop to RGIA', isToAirport, () { setState(() { isToAirport = true; _handleAirportDefault(); }); })), const SizedBox(width: 10), Expanded(child: _airportToggle('Pickup from RGIA', !isToAirport, () { setState(() { isToAirport = false; _handleAirportDefault(); }); }))]),
              const SizedBox(height: 14),
            ] else if (isOutstation) ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Outstation Trip Duration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)), child: const Text('₹1,799 / day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E))))]),
              const SizedBox(height: 10),
              Row(children: [1, 2, 3, 5].map((d) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: InkWell(onTap: () => setState(() => outstationDays = d), borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: outstationDays == d ? primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: outstationDays == d ? primary : border)), child: Center(child: Text('$d Day${d > 1 ? 's' : ''}', style: TextStyle(color: outstationDays == d ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12))))))).toList()),
              const SizedBox(height: 14),
            ] else ...[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Select Duration Package', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isNightTime ? const Color(0xFF1E1B4B) : const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)), child: Text(isNightTime ? 'Night Fare (10 PM - 6 AM)' : 'Standard Day Fare', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isNightTime ? Colors.amber : const Color(0xFF92400E))))]),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [1, 2, 4, 6, 8, 12].map((h) { final selected = selectedHours == h; final rate = ((isNightTime ? standardNightRates[h] : standardDayRates[h]) ?? 0) + (widget.isPremium ? 150 : 0); return InkWell(onTap: () => setState(() => selectedHours = h), borderRadius: BorderRadius.circular(12), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: selected ? primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? primary : border)), child: Column(children: [Text('${h}h Package', style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12.5)), const SizedBox(height: 2), Text('₹${rate.toStringAsFixed(0)}', style: TextStyle(color: selected ? gold : Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: 11.5))]))); }).toList()),
              const SizedBox(height: 14),
            ],
            const Text('Trip Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)), child: Row(children: ['One Way', 'Round Trip'].map((type) => Expanded(child: InkWell(onTap: () { setState(() => tripType = type); _getRoadRoute(); }, borderRadius: BorderRadius.circular(11), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: tripType == type ? primary : Colors.transparent, borderRadius: BorderRadius.circular(11)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(type == 'One Way' ? Icons.arrow_forward_rounded : Icons.sync_rounded, size: 17, color: tripType == type ? Colors.white : primary), const SizedBox(width: 6), Text(type, style: TextStyle(color: tripType == type ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12.5))])))).toList())),
            if (tripType == 'Round Trip') ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: gold.withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.info_outline, color: primary, size: 17), SizedBox(width: 7), Expanded(child: Text('Route returns to the pickup point after final drop.', style: TextStyle(fontSize: 11.5, color: primary, fontWeight: FontWeight.w600)))]))],
            const SizedBox(height: 14),
            const Text('Car Transmission', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: _gearChip('Manual', Icons.tune, transmission == 'Manual', () => setState(() => transmission = 'Manual'))), const SizedBox(width: 10), Expanded(child: _gearChip('Automatic', Icons.bolt, transmission == 'Automatic', () => setState(() => transmission = 'Automatic')))]),
            const SizedBox(height: 14),
            _routeCard(),
            if (searchList.isNotEmpty) Container(margin: const EdgeInsets.only(top: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)), child: Column(children: searchList.map((item) => ListTile(dense: true, leading: const Icon(Icons.place_rounded, color: primary, size: 20), title: Text(item['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primary)), subtitle: Text(item['sub'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)), onTap: () => _applySelection(ll.LatLng(item['lat'], item['lon']), item['title'])).toList())),
            const SizedBox(height: 12),
            Row(children: [_pill('Jubilee Hills', () { searchPickup = false; searchStopIndex = null; _applySelection(const ll.LatLng(17.4319, 78.4073), 'Jubilee Hills'); }), const SizedBox(width: 6), _pill('Hitec City', () { searchPickup = false; searchStopIndex = null; _applySelection(const ll.LatLng(17.4474, 78.3762), 'Hitec City'); }), const SizedBox(width: 6), _pill('Gachibowli', () { searchPickup = false; searchStopIndex = null; _applySelection(const ll.LatLng(17.4401, 78.3489), 'Gachibowli'); })]),
            const SizedBox(height: 90),
          ]),
        )),
      ]),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 14), child: ElevatedButton(
        onPressed: () {
          if (pickupController.text.trim().isEmpty || dropController.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select pickup & drop locations'))); return; }
          for (var i = 0; i < stopControllers.length; i++) {
            if (stopControllers[i].text.trim().isEmpty || stopPositions[i] == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Select Stop ${i + 1} location')));
              return;
            }
          }
          final carLabel = widget.vehicleData != null ? '${widget.vehicleData!['model']} (${widget.vehicleData!['number']})' : 'Car ($transmission)';
          Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(serviceType: widget.serviceType, pickupLocation: pickupController.text, dropLocation: _routeSummary, vehicleType: carLabel, fare: fare, selectedHours: isAirport ? null : selectedHours)));
        },
        style: ElevatedButton.styleFrom(backgroundColor: primary, minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('₹${fare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white)), const Text('All-Inclusive • Zero Hidden Fees', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600))]), const Row(children: [Text('Confirm Chauffeur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)), SizedBox(width: 4), Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18)])]),
      ))),
    );
  }

  Widget _routeCard() => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
    child: Column(children: [
      _locationRow(pickupController, Icons.radio_button_checked, const Color(0xFF1A73E8), 'Pickup address', true),
      Padding(padding: const EdgeInsets.only(left: 14), child: Container(height: 12, width: 1.5, color: border)),
      for (var i = 0; i < stopControllers.length; i++) ...[
        _stopRow(i),
        Padding(padding: const EdgeInsets.only(left: 14), child: Container(height: 12, width: 1.5, color: border)),
      ],
      _locationRow(dropController, Icons.location_on, const Color(0xFFEA4335), 'Final drop destination', false),
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerLeft, child: OutlinedButton.icon(onPressed: stopControllers.length < 3 ? _addStop : null, icon: const Icon(Icons.add_road, size: 17), label: Text(stopControllers.length < 3 ? 'Add Stop' : 'Maximum 3 Stops'), style: OutlinedButton.styleFrom(foregroundColor: primary, side: const BorderSide(color: border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)))),
    ]),
  );

  Widget _locationRow(TextEditingController controller, IconData icon, Color iconColor, String hint, bool pickup) => Row(children: [Icon(icon, color: iconColor, size: 20), const SizedBox(width: 5), Expanded(child: TextField(controller: controller, onChanged: (v) => _onSearch(v, pickup: pickup), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary), decoration: InputDecoration(hintText: hint, border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10)))), IconButton(onPressed: () => _pickMapLocation(pickup: pickup), icon: const Icon(Icons.map_outlined, color: primary, size: 20))]);

  Widget _stopRow(int index) => Row(children: [Container(width: 24, height: 24, alignment: Alignment.center, decoration: const BoxDecoration(color: gold, shape: BoxShape.circle), child: Text('${index + 1}', style: const TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: 11))), const SizedBox(width: 5), Expanded(child: TextField(controller: stopControllers[index], onChanged: (v) => _onSearch(v, pickup: false, stopIndex: index), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primary), decoration: InputDecoration(hintText: 'Stop ${index + 1}', border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10)))), IconButton(onPressed: () => _pickMapLocation(stopIndex: index), icon: const Icon(Icons.map_outlined, color: primary, size: 20)), IconButton(onPressed: () => _removeStop(index), icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 19))]);

  Widget _airportToggle(String label, bool selected, VoidCallback tap) => InkWell(onTap: tap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: selected ? primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? primary : border)), child: Center(child: Text(label, style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 12.5)))));
  Widget _gearChip(String label, IconData icon, bool selected, VoidCallback tap) => InkWell(onTap: tap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: selected ? primary : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? primary : border)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: selected ? Colors.white : primary), const SizedBox(width: 6), Text(label, style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.bold, fontSize: 13))])));
  Widget _pill(String title, VoidCallback tap) => InkWell(onTap: tap, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: Text(title, style: const TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w600))));
}

class DropPicker extends StatefulWidget {
  final ll.LatLng initial;
  final String title;
  const DropPicker({super.key, required this.initial, this.title = 'Select Destination'});
  @override
  State<DropPicker> createState() => _DropPickerState();
}

class _DropPickerState extends State<DropPicker> {
  late ll.LatLng center;
  @override
  void initState() { super.initState(); center = widget.initial; }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: const Color(0xFF173B6D), foregroundColor: Colors.white, title: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
    body: Stack(children: [
      FlutterMap(options: MapOptions(initialCenter: center, initialZoom: 15, onPositionChanged: (pos, _) { if (pos.center != null) center = pos.center!; }), children: [TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m,traffic&x={x}&y={y}&z={z}', userAgentPackageName: 'com.wedrive.app')]),
      const Center(child: Padding(padding: EdgeInsets.only(bottom: 32), child: Icon(Icons.location_on, color: Color(0xFFEA4335), size: 46))),
      Positioned(left: 20, right: 20, bottom: 24, child: ElevatedButton(onPressed: () => Navigator.pop(context, center), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF173B6D), minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Confirm Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)))),
    ]),
  );
}
