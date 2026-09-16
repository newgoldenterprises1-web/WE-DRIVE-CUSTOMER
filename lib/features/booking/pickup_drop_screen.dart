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
  static const Color deep = Color(0xFF0B2341);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF6F8FB);
  static const Color border = Color(0xFFE1E7EF);
  static const Color blue = Color(0xFF1A73E8);

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();
  final MapController mapController = MapController();
  final List<TextEditingController> stopControllers = <TextEditingController>[];
  final List<ll.LatLng?> stopPositions = <ll.LatLng?>[];

  static const ll.LatLng defaultLocation = ll.LatLng(17.3850, 78.4867);
  static const ll.LatLng airportLocation = ll.LatLng(17.2403, 78.4294);
  static const Map<int, double> dayRates = {1: 299, 2: 349, 4: 549, 6: 749, 8: 949, 12: 1299};
  static const Map<int, double> nightRates = {1: 499, 2: 549, 4: 749, 6: 949, 8: 1149, 12: 1499};

  late String transmission;
  int selectedHours = 2;
  int outstationDays = 1;
  String tripType = 'One Way';
  bool multipleStopsEnabled = false;
  bool isToAirport = true;
  bool isLoading = false;
  bool searchPickup = false;
  int? searchStopIndex;
  ll.LatLng pickupPos = defaultLocation;
  ll.LatLng? dropPos;
  List<ll.LatLng> routePoints = <ll.LatLng>[];
  double? tripKm;
  int? tripMins;
  List<Map<String, dynamic>> searchList = <Map<String, dynamic>>[];
  Timer? debounce;

  bool get isPremiumLanding => widget.isPremium && widget.serviceType == 'Premium Chauffeur';
  bool get isAirport => widget.serviceType.toLowerCase().contains('airport');
  bool get isOutstation => widget.serviceType.toLowerCase().contains('outstation');
  bool get isNightTime => DateTime.now().hour >= 22 || DateTime.now().hour < 6;

  double get fare {
    if (isAirport) return widget.isPremium ? 1299 : 999;
    if (isOutstation) return outstationDays * 1799;
    return ((isNightTime ? nightRates : dayRates)[selectedHours] ?? 349) + (widget.isPremium ? 150 : 0);
  }

  List<ll.LatLng> get routeLocations {
    final List<ll.LatLng> points = <ll.LatLng>[pickupPos];
    if (tripType == 'Round Trip' && multipleStopsEnabled) {
      for (final ll.LatLng? position in stopPositions) {
        if (position != null) points.add(position);
      }
    }
    if (dropPos != null) points.add(dropPos!);
    if (tripType == 'Round Trip') points.add(pickupPos);
    return points;
  }

  String get routeSummary {
    final List<String> parts = <String>['Pickup: ${pickupController.text.trim()}'];
    if (tripType == 'Round Trip' && multipleStopsEnabled) {
      for (int i = 0; i < stopControllers.length; i++) {
        parts.add('Stop ${i + 1}: ${stopControllers[i].text.trim()}');
      }
    }
    parts.add('Final Drop: ${dropController.text.trim()}');
    if (tripType == 'Round Trip') parts.add('Return: Pickup');
    return parts.join(' • ');
  }

  List<ll.LatLng> get driverPositions => <ll.LatLng>[
        ll.LatLng(pickupPos.latitude + 0.0035, pickupPos.longitude + 0.0028),
        ll.LatLng(pickupPos.latitude - 0.0029, pickupPos.longitude - 0.0032),
        ll.LatLng(pickupPos.latitude + 0.0018, pickupPos.longitude - 0.0041),
      ];

  @override
  void initState() {
    super.initState();
    selectedHours = widget.selectedHours != null && dayRates.containsKey(widget.selectedHours) ? widget.selectedHours! : 2;
    transmission = (widget.vehicleData?['transmission']?.toString().toLowerCase().contains('auto') ?? false) ? 'Automatic' : 'Manual';
    if (!isPremiumLanding) {
      handleAirportDefault();
      fetchLiveGps();
    }
  }

  void setTripType(String type) {
    setState(() {
      tripType = type;
      if (type == 'One Way') {
        multipleStopsEnabled = false;
        _clearStops();
      }
    });
    getRoadRoute();
  }

  void setMultipleStops(bool enabled) {
    setState(() {
      multipleStopsEnabled = enabled;
      if (!enabled) _clearStops();
    });
    getRoadRoute();
  }

  void _clearStops() {
    for (final TextEditingController controller in stopControllers) {
      controller.dispose();
    }
    stopControllers.clear();
    stopPositions.clear();
  }

  void selectPremiumService(String service) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PickupDropScreen(serviceType: service, isPremium: true),
      ),
    );
  }

  Future<void> showPremiumAdvanceSchedule() async {
    final DateTime initial = DateTime.now().add(const Duration(hours: 2));
    DateTime date = initial;
    TimeOfDay time = TimeOfDay.fromDateTime(initial);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(width: 42, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(5))),
                const SizedBox(height: 16),
                const Row(
                  children: <Widget>[
                    Icon(Icons.workspace_premium_rounded, color: gold, size: 24),
                    SizedBox(width: 8),
                    Text('Advance Chauffeur', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: primary)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Choose your travel date and preferred pickup time.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                const SizedBox(height: 14),
                _scheduleTile(Icons.event_rounded, 'Travel date', '${date.day}/${date.month}/${date.year}', () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) setModalState(() => date = picked);
                }),
                const SizedBox(height: 10),
                _scheduleTile(Icons.access_time_filled_rounded, 'Pickup time', time.format(context), () async {
                  final TimeOfDay? picked = await showTimePicker(context: context, initialTime: time);
                  if (picked != null) setModalState(() => time = picked);
                }),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final String schedule = 'Advance Chauffeur (${date.day}/${date.month}/${date.year} ${time.format(context)})';
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => PickupDropScreen(serviceType: schedule, isPremium: true)),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: deep, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _scheduleTile(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: Row(
          children: <Widget>[
            Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: primary, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)), const SizedBox(height: 2), Text(value, style: const TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.w800))])),
            const Icon(Icons.chevron_right_rounded, color: primary),
          ],
        ),
      ),
    );
  }

  Widget premiumServiceCard(String title, String subtitle, IconData icon, VoidCallback onTap, {bool featured = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: featured ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF102B4F), Color(0xFF173B6D)]) : null,
          color: featured ? null : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: featured ? gold.withValues(alpha: 0.65) : border),
          boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: featured ? Colors.white.withValues(alpha: 0.10) : primary.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: featured ? gold : primary, size: 25)),
              const Spacer(),
              if (featured) const Icon(Icons.star_rounded, color: gold, size: 20),
            ]),
            const Spacer(),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: featured ? Colors.white : primary)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11.5, height: 1.25, color: featured ? Colors.white70 : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget buildPremiumLanding() {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: deep,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('WE DRIVE', style: TextStyle(fontSize: 12, color: gold, fontWeight: FontWeight.w800)), Text('Premium Chauffeur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))]),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: <Color>[Color(0xFF0B2341), Color(0xFF173B6D)]),
              borderRadius: BorderRadius.circular(26),
              boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6))],
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Row(children: <Widget>[Icon(Icons.workspace_premium_rounded, color: gold, size: 30), SizedBox(width: 10), Text('Premium Experience', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900))]),
              SizedBox(height: 8),
              Text('Professional chauffeurs, elevated comfort and a booking flow designed for a premium ride.', style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4)),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('Choose a service', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: primary)),
          const SizedBox(height: 4),
          Text('Simple names. Clear choices. Pick what you need.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
          const SizedBox(height: 12),
          SizedBox(
            height: 350,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.98,
              children: <Widget>[
                premiumServiceCard('Hourly Chauffeur', 'Book a chauffeur by the hour.', Icons.access_time_rounded, () => selectPremiumService('Premium Hourly Driver'), featured: true),
                premiumServiceCard('Airport Transfer', 'Smooth pickup or drop at the airport.', Icons.flight_takeoff_rounded, () => selectPremiumService('Premium Airport Transfer')),
                premiumServiceCard('Outstation Chauffeur', 'Comfortable long-distance travel.', Icons.alt_route_rounded, () => selectPremiumService('Premium Outstation')),
                premiumServiceCard('Advance Booking', 'Schedule your chauffeur ahead of time.', Icons.event_available_rounded, showPremiumAdvanceSchedule),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
            child: const Row(children: <Widget>[
              Icon(Icons.verified_rounded, color: Colors.green, size: 20), SizedBox(width: 9),
              Expanded(child: Text('Professional service • Transparent pricing • Easy booking', style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w700))),
            ]),
          ),
        ],
      ),
    );
  }

  void handleAirportDefault() {
    if (!isAirport) return;
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
      final http.Response response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json'), headers: const <String, String>{'User-Agent': 'WeDriveApp'}).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final Map<String, dynamic>? address = data['address'] as Map<String, dynamic>?;
        final dynamic name = address?['suburb'] ?? address?['neighbourhood'] ?? address?['road'] ?? address?['city_district'] ?? data['name'];
        if (name != null && name.toString().isNotEmpty) return '${name.toString()}, Hyderabad';
      }
    } catch (_) {}
    return 'Current Location, Hyderabad';
  }

  Future<void> fetchLiveGps() async {
    if (isAirport && !isToAirport) return;
    if (mounted) setState(() => isLoading = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      pickupPos = ll.LatLng(position.latitude, position.longitude);
      pickupController.text = await reverseGeocode(position.latitude, position.longitude);
      mapController.move(pickupPos, 15.2);
      if (dropPos != null) getRoadRoute();
    } catch (_) {
      // Keep fallback location.
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> getRoadRoute() async {
    final List<ll.LatLng> points = routeLocations;
    if (points.length < 2) return;
    final String coordinates = points.map((ll.LatLng p) => '${p.longitude},${p.latitude}').join(';');
    try {
      final http.Response response = await http.get(Uri.parse('https://router.project-osrm.org/route/v1/driving/$coordinates?overview=full&geometries=geojson')).timeout(const Duration(seconds: 7));
      if (response.statusCode != 200) return;
      final dynamic body = json.decode(response.body);
      final List<dynamic> routes = body['routes'] as List<dynamic>? ?? <dynamic>[];
      if (routes.isEmpty) return;
      final Map<String, dynamic> route = routes.first as Map<String, dynamic>;
      final List<dynamic> geometry = route['geometry']['coordinates'] as List<dynamic>;
      if (!mounted) return;
      setState(() {
        routePoints = geometry.map<ll.LatLng>((dynamic c) {
          final List<dynamic> pair = c as List<dynamic>;
          return ll.LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
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
    debounce = Timer(const Duration(milliseconds: 300), () async => searchLocations(value));
  }

  Future<void> searchLocations(String value) async {
    try {
      final String url = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(value.trim())}&format=json&addressdetails=1&limit=6&countrycodes=in&viewbox=78.18,17.60,78.68,17.18&bounded=0';
      final http.Response response = await http.get(Uri.parse(url), headers: const <String, String>{'User-Agent': 'WeDriveHyderabad/1.0'}).timeout(const Duration(seconds: 4));
      if (response.statusCode != 200 || !mounted) return;
      final List<dynamic> list = json.decode(response.body) as List<dynamic>;
      final List<Map<String, dynamic>> results = <Map<String, dynamic>>[];
      for (final dynamic item in list) {
        final Map<String, dynamic> data = item as Map<String, dynamic>;
        final Map<String, dynamic> address = data['address'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final String display = data['display_name']?.toString() ?? 'Hyderabad';
        results.add(<String, dynamic>{
          'title': data['name']?.toString().isNotEmpty == true ? data['name'].toString() : display.split(',').first,
          'sub': '${address['suburb'] ?? address['neighbourhood'] ?? address['road'] ?? 'Hyderabad'}, Hyderabad',
          'lat': double.tryParse(data['lat']?.toString() ?? '') ?? defaultLocation.latitude,
          'lon': double.tryParse(data['lon']?.toString() ?? '') ?? defaultLocation.longitude,
        });
      }
      setState(() => searchList = results);
    } catch (_) {}
  }

  void applySelection(ll.LatLng target, String name) {
    setState(() {
      if (searchStopIndex != null && searchStopIndex! < stopControllers.length) {
        stopControllers[searchStopIndex!].text = name;
        stopPositions[searchStopIndex!] = target;
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
    final ll.LatLng initial = pickup ? pickupPos : stopIndex != null ? (stopPositions[stopIndex] ?? pickupPos) : (dropPos ?? pickupPos);
    final ll.LatLng? selected = await Navigator.push<ll.LatLng>(context, MaterialPageRoute<ll.LatLng>(builder: (_) => DropPicker(initial: initial, title: stopIndex != null ? 'Select Stop ${stopIndex + 1}' : pickup ? 'Select Pickup' : 'Select Destination')));
    if (selected == null) return;
    final String address = await reverseGeocode(selected.latitude, selected.longitude);
    if (stopIndex != null) {
      setState(() {
        stopPositions[stopIndex] = selected;
        stopControllers[stopIndex].text = address;
      });
      getRoadRoute();
    } else {
      searchPickup = pickup;
      searchStopIndex = null;
      applySelection(selected, address);
    }
  }

  void addStop() {
    if (tripType != 'Round Trip' || !multipleStopsEnabled || stopControllers.length >= 3) return;
    setState(() {
      stopControllers.add(TextEditingController());
      stopPositions.add(null);
    });
  }

  void removeStop(int index) {
    if (index < 0 || index >= stopControllers.length) return;
    final TextEditingController controller = stopControllers.removeAt(index);
    controller.dispose();
    stopPositions.removeAt(index);
    setState(() {});
    getRoadRoute();
  }

  void confirmBooking() {
    if (pickupController.text.trim().isEmpty || dropController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select pickup & drop locations')));
      return;
    }
    if (tripType == 'Round Trip' && multipleStopsEnabled) {
      for (int i = 0; i < stopControllers.length; i++) {
        if (stopControllers[i].text.trim().isEmpty || stopPositions[i] == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Select Stop ${i + 1} location')));
          return;
        }
      }
    }
    final String carLabel = widget.vehicleData != null ? '${widget.vehicleData!['model']} (${widget.vehicleData!['number']})' : 'Car ($transmission)';
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

  Widget sectionLabel(String title, String subtitle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primary)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600))]);
  }

  Widget buildTripType() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
      child: Row(children: <Widget>[
        Expanded(child: tripTypeButton('One Way', Icons.arrow_forward_rounded, tripType == 'One Way', () => setTripType('One Way'))),
        Expanded(child: tripTypeButton('Round Trip', Icons.sync_rounded, tripType == 'Round Trip', () => setTripType('Round Trip'))),
        if (tripType == 'Round Trip')
          Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.only(left: 8),
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: border))),
            child: Row(children: <Widget>[const Text('Stops', style: TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w800)), Switch.adaptive(value: multipleStopsEnabled, onChanged: setMultipleStops, activeColor: gold, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)]),
          ),
      ]),
    );
  }

  Widget tripTypeButton(String label, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: selected ? primary : Colors.transparent, borderRadius: BorderRadius.circular(13)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(icon, size: 17, color: selected ? Colors.white : primary), const SizedBox(width: 6), Text(label, style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.w800, fontSize: 11.5))]),
      ),
    );
  }

  List<Widget> buildContent() {
    final List<Widget> content = <Widget>[const SizedBox(height: 4)];
    if (widget.isPremium) content.addAll(<Widget>[buildPremiumHeader(), const SizedBox(height: 14)]);
    if (widget.vehicleData != null) content.addAll(<Widget>[buildVehicleCard(), const SizedBox(height: 14)]);
    if (isAirport) {
      content.addAll(<Widget>[buildAirportOptions(), const SizedBox(height: 14)]);
    } else if (isOutstation) {
      content.addAll(<Widget>[buildOutstationOptions(), const SizedBox(height: 14)]);
    } else {
      content.addAll(<Widget>[buildHourlyOptions(), const SizedBox(height: 14)]);
    }
    content.addAll(<Widget>[
      sectionLabel('Trip type', 'Choose how you want the chauffeur journey to work.'),
      const SizedBox(height: 9),
      buildTripType(),
    ]);
    if (tripType == 'Round Trip') {
      content.addAll(<Widget>[
        const SizedBox(height: 7),
        Row(
          children: <Widget>[
            const Icon(Icons.info_outline_rounded, size: 16, color: primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                multipleStopsEnabled ? 'Add up to 3 stops before the final drop. The chauffeur returns to pickup.' : 'The chauffeur returns to your pickup after the final drop.',
                style: const TextStyle(fontSize: 11.5, color: primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ]);
    }
    content.addAll(<Widget>[
      const SizedBox(height: 16),
      sectionLabel('Chauffeur preference', 'Choose manual or automatic before reviewing your ride.'),
      const SizedBox(height: 9),
      buildTransmission(),
      const SizedBox(height: 16),
      sectionLabel('Your route', 'Set pickup, optional stops and final destination.'),
      const SizedBox(height: 9),
      buildRouteCard(),
    ]);
    if (searchList.isNotEmpty) content.addAll(<Widget>[const SizedBox(height: 8), buildSearchResults()]);
    content.addAll(<Widget>[const SizedBox(height: 14), buildQuickLocations(), const SizedBox(height: 90)]);
    return content;
  }

  Widget buildPremiumHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: <Color>[Color(0xFF102B4F), Color(0xFF173B6D)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: gold.withValues(alpha: 0.45))),
      child: Row(
        children: <Widget>[
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), shape: BoxShape.circle), child: const Icon(Icons.workspace_premium_rounded, color: gold, size: 25)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[const Text('Premium chauffeur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 3), Text('Priority experience with a polished booking flow.', style: TextStyle(color: Colors.white70, fontSize: 11.5))])),
          const Icon(Icons.verified_rounded, color: gold, size: 22),
        ],
      ),
    );
  }

  Widget buildVehicleCard() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: gold.withValues(alpha: 0.4))), child: Row(children: <Widget>[Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: primary.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.directions_car_filled_rounded, color: primary)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(widget.vehicleData?['model']?.toString() ?? 'Your Car', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: primary)), const SizedBox(height: 2), Text('${widget.vehicleData?['number']?.toString() ?? ''} • $transmission', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600))])), const Text('GARAGE', style: TextStyle(color: primary, fontSize: 9.5, fontWeight: FontWeight.w900))]));
  }

  Widget buildAirportOptions() {
    return Row(children: <Widget>[Expanded(child: optionCard('Drop to RGIA', 'Airport drop', Icons.flight_land_rounded, isToAirport, () { setState(() => isToAirport = true); handleAirportDefault(); })), const SizedBox(width: 10), Expanded(child: optionCard('Pickup from RGIA', 'Airport pickup', Icons.flight_takeoff_rounded, !isToAirport, () { setState(() => isToAirport = false); handleAirportDefault(); }))]);
  }

  Widget optionCard(String title, String subtitle, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: selected ? primary : border),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: selected ? Colors.white : primary, size: 22),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: TextStyle(color: selected ? Colors.white : primary, fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: selected ? Colors.white70 : Colors.grey.shade600, fontSize: 10.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOutstationOptions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[sectionLabel('Outstation duration', 'Select how many days you need the chauffeur.'), const SizedBox(height: 9), Row(children: <Widget>[for (final int days in <int>[1, 2, 3, 5]) Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: InkWell(onTap: () => setState(() => outstationDays = days), borderRadius: BorderRadius.circular(14), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: outstationDays == days ? primary : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: outstationDays == days ? primary : border)), child: Center(child: Text('$days day${days > 1 ? 's' : ''}', style: TextStyle(color: outstationDays == days ? Colors.white : primary, fontWeight: FontWeight.w800, fontSize: 12)))))))] )]);
  }

  Widget buildHourlyOptions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[sectionLabel('Choose a duration', 'Pick a package that fits your ride.'), const SizedBox(height: 9), Wrap(spacing: 8, runSpacing: 8, children: <Widget>[for (final int hours in <int>[1, 2, 4, 6, 8, 12]) buildHourPackage(hours)])]);
  }

  Widget buildHourPackage(int hours) {
    final double rate = ((isNightTime ? nightRates : dayRates)[hours] ?? 0) + (widget.isPremium ? 150 : 0);
    final bool selected = selectedHours == hours;
    return InkWell(onTap: () => setState(() => selectedHours = hours), borderRadius: BorderRadius.circular(15), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(color: selected ? primary : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: selected ? primary : border), boxShadow: selected ? const <BoxShadow>[BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))] : null), child: Column(children: <Widget>[Text('${hours}h', style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.w900, fontSize: 13)), const SizedBox(height: 2), Text('₹${rate.toStringAsFixed(0)}', style: TextStyle(color: selected ? gold : Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w800))])));
  }

  Widget buildTransmission() {
    return Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: Row(children: <Widget>[Expanded(child: gearChip('Manual', Icons.tune_rounded, transmission == 'Manual', () => setState(() => transmission = 'Manual'))), const SizedBox(width: 5), Expanded(child: gearChip('Automatic', Icons.bolt_rounded, transmission == 'Automatic', () => setState(() => transmission = 'Automatic')))]));
  }

  Widget gearChip(String label, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(color: selected ? primary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 16, color: selected ? Colors.white : primary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.w800, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }

  Widget buildRouteCard() {
    final List<Widget> children = <Widget>[
      routeLocationRow(controller: pickupController, icon: Icons.radio_button_checked_rounded, color: blue, label: 'Pickup', hint: 'Where should we pick you up?', pickup: true),
      routeConnector(),
    ];
    if (tripType == 'Round Trip' && multipleStopsEnabled) {
      for (int i = 0; i < stopControllers.length; i++) {
        children.add(stopRow(i));
        children.add(routeConnector());
      }
      children.add(Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 34, bottom: 6), child: OutlinedButton.icon(onPressed: stopControllers.length < 3 ? addStop : null, style: OutlinedButton.styleFrom(foregroundColor: primary, side: const BorderSide(color: border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), icon: const Icon(Icons.add_road_rounded, size: 17), label: Text(stopControllers.length < 3 ? 'Add stop' : 'Maximum 3 stops')))));
      if (stopControllers.isNotEmpty) children.add(routeConnector());
    }
    children.add(routeLocationRow(controller: dropController, icon: Icons.location_on_rounded, color: const Color(0xFFEA4335), label: 'Final destination', hint: 'Where are you going?', pickup: false));
    if (tripType == 'Round Trip') children.add(Padding(padding: const EdgeInsets.only(left: 34, top: 10), child: Row(children: const <Widget>[Icon(Icons.u_turn_left_rounded, size: 16, color: primary), SizedBox(width: 6), Text('Return to pickup', style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 11.5))])));
    return Container(padding: const EdgeInsets.fromLTRB(12, 13, 8, 13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: widget.isPremium ? gold.withValues(alpha: 0.38) : border), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))]), child: Column(children: children));
  }

  Widget routeConnector() => Padding(padding: const EdgeInsets.only(left: 17), child: Align(alignment: Alignment.centerLeft, child: Container(height: 14, width: 2, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))));

  Widget routeLocationRow({required TextEditingController controller, required IconData icon, required Color color, required String label, required String hint, required bool pickup}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), child: Row(children: <Widget>[Icon(icon, color: color, size: 20), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w700)), TextField(controller: controller, onChanged: (String value) => onSearchChanged(value, pickup: pickup), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: primary), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12.5), border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.only(top: 3)))])), IconButton(onPressed: () => pickMapLocation(pickup: pickup), icon: const Icon(Icons.map_outlined, color: primary, size: 21))]));
  }

  Widget stopRow(int index) {
    return Row(children: <Widget>[Container(width: 24, height: 24, alignment: Alignment.center, decoration: const BoxDecoration(color: gold, shape: BoxShape.circle), child: Text('${index + 1}', style: const TextStyle(color: primary, fontWeight: FontWeight.w900, fontSize: 11))), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[const Text('Stop', style: TextStyle(fontSize: 10.5, color: Colors.grey, fontWeight: FontWeight.w700)), TextField(controller: stopControllers[index], onChanged: (String value) => onSearchChanged(value, pickup: false, stopIndex: index), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: primary), decoration: InputDecoration(hintText: 'Add a stop', hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12.5), border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.only(top: 3)))])), IconButton(onPressed: () => pickMapLocation(stopIndex: index), icon: const Icon(Icons.map_outlined, color: primary, size: 20)), IconButton(onPressed: () => removeStop(index), icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 19))]);
  }

  Widget buildSearchResults() {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: Column(children: <Widget>[for (final Map<String, dynamic> item in searchList) ListTile(dense: true, leading: const Icon(Icons.place_rounded, color: primary, size: 20), title: Text(item['title']?.toString() ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: primary)), subtitle: Text(item['sub']?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)), onTap: () => applySelection(ll.LatLng(item['lat'] as double, item['lon'] as double), item['title'].toString()))]));
  }

  Widget buildQuickLocations() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text('Quick locations', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w800)), const SizedBox(height: 7), Wrap(spacing: 7, runSpacing: 7, children: <Widget>[quickPill('Jubilee Hills', const ll.LatLng(17.4319, 78.4073)), quickPill('Hitec City', const ll.LatLng(17.4474, 78.3762)), quickPill('Gachibowli', const ll.LatLng(17.4401, 78.3489))])]);
  }

  Widget quickPill(String title, ll.LatLng position) {
    return InkWell(onTap: () { searchPickup = false; searchStopIndex = null; applySelection(position, title); }, borderRadius: BorderRadius.circular(16), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: Text(title, style: const TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w700))));
  }

  Widget buildMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCenter: pickupPos, initialZoom: 15),
      children: <Widget>[
        TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m,traffic&x={x}&y={y}&z={z}', userAgentPackageName: 'com.wedrive.app'),
        if (routePoints.isNotEmpty) PolylineLayer(polylines: <Polyline>[Polyline(points: routePoints, strokeWidth: 5.5, color: widget.isPremium ? gold : blue)]),
        MarkerLayer(markers: <Marker>[
          Marker(point: pickupPos, width: 50, height: 50, child: Container(decoration: BoxDecoration(color: primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)), child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 20))),
          for (int i = 0; i < stopPositions.length; i++) if (stopPositions[i] != null) Marker(point: stopPositions[i]!, width: 40, height: 40, child: Container(decoration: BoxDecoration(color: gold, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), alignment: Alignment.center, child: Text('${i + 1}', style: const TextStyle(color: primary, fontWeight: FontWeight.w900)))),
          if (dropPos != null) Marker(point: dropPos!, width: 44, height: 44, child: const Icon(Icons.location_on, color: Color(0xFFEA4335), size: 44)),
          for (final ll.LatLng p in driverPositions) Marker(point: p, width: 34, height: 34, child: Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: primary, width: 1.5)), child: const Icon(Icons.person_pin, color: primary, size: 20))),
        ]),
      ],
    );
  }

  Widget buildRouteStats() {
    return Positioned(top: 14, left: 18, right: 18, child: Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 3))]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[Text('${tripKm?.toStringAsFixed(1) ?? '--'} km', style: const TextStyle(fontWeight: FontWeight.w900, color: primary, fontSize: 12.5)), const Text('|', style: TextStyle(color: border)), Text('${tripMins ?? '--'} mins', style: const TextStyle(fontWeight: FontWeight.w900, color: primary, fontSize: 12.5)), const Text('|', style: TextStyle(color: border)), const Text('Drivers nearby', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.green, fontSize: 11.5))]));
  }

  @override
  Widget build(BuildContext context) {
    if (isPremiumLanding) return buildPremiumLanding();
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: widget.isPremium ? deep : primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(widget.isPremium ? 'Premium ride' : 'Book your ride', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 1), Text(widget.isPremium ? 'Elevated chauffeur experience' : widget.serviceType, style: const TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w600))]),
        actions: <Widget>[if (widget.isPremium) const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.workspace_premium_rounded, color: gold))],
      ),
      body: Stack(children: <Widget>[
        SizedBox(height: 350, child: buildMap()),
        if (tripKm != null && tripMins != null) buildRouteStats(),
        Positioned(top: 270, right: 16, child: FloatingActionButton.small(backgroundColor: Colors.white, foregroundColor: blue, onPressed: isLoading ? null : fetchLiveGps, child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location, size: 20))),
        DraggableScrollableSheet(initialChildSize: 0.64, minChildSize: 0.48, maxChildSize: 0.95, builder: (_, ScrollController controller) => Container(decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(26)), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -3))]), child: ListView(controller: controller, padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), children: <Widget>[Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(4)))), ...buildContent()]))),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Container(
            decoration: BoxDecoration(color: widget.isPremium ? deep : primary, borderRadius: BorderRadius.circular(20), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 5))]),
            child: ElevatedButton(
              onPressed: confirmBooking,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size.fromHeight(62), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 16)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Row(children: <Widget>[if (widget.isPremium) const Icon(Icons.workspace_premium_rounded, color: gold, size: 16), if (widget.isPremium) const SizedBox(width: 4), Text('₹${fare.toStringAsFixed(0)}', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.white))]), const SizedBox(height: 1), const Text('Transparent fare • No hidden fees', style: TextStyle(fontSize: 9.5, color: Colors.white70, fontWeight: FontWeight.w600))]),
                const Row(children: <Widget>[Text('Review & Book', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14.5)), SizedBox(width: 5), Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 19)]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropController.dispose();
    _clearStops();
    debounce?.cancel();
    super.dispose();
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
  static const Color primaryColor = Color(0xFF173B6D);

  @override
  void initState() {
    super.initState();
    center = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: primaryColor, foregroundColor: Colors.white, title: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
      body: Stack(children: <Widget>[
        FlutterMap(options: MapOptions(initialCenter: center, initialZoom: 15, onPositionChanged: (MapCamera camera, bool _) => center = camera.center), children: <Widget>[TileLayer(urlTemplate: 'https://mt1.google.com/vt/lyrs=m,traffic&x={x}&y={y}&z={z}', userAgentPackageName: 'com.wedrive.app')]),
        const Center(child: Padding(padding: EdgeInsets.only(bottom: 28), child: Icon(Icons.location_on, color: Color(0xFFEA4335), size: 48))),
        Positioned(left: 16, right: 16, bottom: 18, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const <BoxShadow>[BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 3))]), child: ElevatedButton(onPressed: () => Navigator.pop(context, center), style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text('Confirm Location', style: TextStyle(fontWeight: FontWeight.w900))))),
      ]),
    );
  }
}
