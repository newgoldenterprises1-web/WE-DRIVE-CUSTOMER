import 'package:flutter/material.dart';

import 'premium_pickup_drop_screen.dart';

class PremiumChauffeurScreen extends StatefulWidget {
  const PremiumChauffeurScreen({super.key});

  @override
  State<PremiumChauffeurScreen> createState() => _PremiumChauffeurScreenState();
}

class _PremiumChauffeurScreenState extends State<PremiumChauffeurScreen> {
  static const Color primary = Color(0xFF174C52);
  static const Color gold = Color(0xFFB99A47);
  static const Color background = Color(0xFFF6F8F9);
  static const Color border = Color(0xFFE1E8EA);

  String selectedService = 'Hourly';
  int selectedHours = 2;

  final Map<String, double> pricing = {
    'Hourly': 799,
    'Airport': 1299,
    'Outstation': 2799,
    'Advance': 899,
  };

  double get currentFare {
    final base = pricing[selectedService] ?? 799;
    if (selectedService == 'Hourly') return base * selectedHours / 2;
    return base;
  }

  void continuePremiumBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PremiumPickupDropScreen(
          serviceType: selectedService,
          fare: currentFare,
          selectedHours: selectedService == 'Hourly' ? selectedHours : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
        title: const Text('Premium Chauffeur', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        children: [
          _hero(),
          const SizedBox(height: 14),
          _availability(),
          const SizedBox(height: 18),
          const Text('Choose Premium Service', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primary)),
          const SizedBox(height: 10),
          _serviceSelector(),
          if (selectedService == 'Hourly') ...[
            const SizedBox(height: 18),
            const Text('Select Duration', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: primary)),
            const SizedBox(height: 10),
            _hoursSelector(),
          ],
          const SizedBox(height: 18),
          _fareCard(),
          const SizedBox(height: 14),
          _benefits(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        child: ElevatedButton(
          onPressed: continuePremiumBooking,
          style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(54), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Text('CONTINUE WITH PREMIUM', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ),
    );
  }

  Widget _hero() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [primary, Color(0xFF1D686F)]), borderRadius: BorderRadius.circular(22)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.workspace_premium_rounded, color: gold, size: 29), SizedBox(width: 10), Text('WE DRIVE PREMIUM', style: TextStyle(color: gold, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2))]),
          SizedBox(height: 15),
          Text('A better chauffeur experience.', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
          SizedBox(height: 6),
          Text('Priority matching, verified professionals and a smoother executive experience.', style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4)),
        ]),
      );

  Widget _availability() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
        child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.online_prediction_rounded, color: Colors.green)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Premium availability', style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 13)), SizedBox(height: 3), Text('Matching is based on live partner availability.', style: TextStyle(color: Colors.black54, fontSize: 11))])),
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 21),
        ]),
      );

  Widget _serviceSelector() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: pricing.keys.map((name) {
          final selected = selectedService == name;
          return ChoiceChip(
            selected: selected,
            label: Text(name),
            onSelected: (_) => setState(() => selectedService = name),
            selectedColor: primary,
            labelStyle: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.w700),
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? primary : border),
          );
        }).toList(),
      );

  Widget _hoursSelector() => Wrap(
        spacing: 8,
        children: [1, 2, 4, 8, 12].map((hours) {
          final selected = selectedHours == hours;
          return ChoiceChip(
            selected: selected,
            label: Text('$hours hr'),
            onSelected: (_) => setState(() => selectedHours = hours),
            selectedColor: gold,
            labelStyle: TextStyle(color: selected ? Colors.white : primary, fontWeight: FontWeight.w700),
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? gold : border),
          );
        }).toList(),
      );

  Widget _fareCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Estimated premium fare', style: TextStyle(color: Colors.black54, fontSize: 11)), SizedBox(height: 5), Text('Payment later', style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 12))]),
          Text('₹${currentFare.toStringAsFixed(0)}', style: const TextStyle(color: primary, fontSize: 25, fontWeight: FontWeight.w900)),
        ]),
      );

  Widget _benefits() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFFEAF4F3), borderRadius: BorderRadius.circular(20)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Premium includes', style: TextStyle(color: primary, fontWeight: FontWeight.w800)),
          SizedBox(height: 9),
          Text('• Priority chauffeur matching', style: TextStyle(color: primary, fontSize: 12)),
          Text('• Verified professional chauffeur', style: TextStyle(color: primary, fontSize: 12)),
          Text('• Live chauffeur status and location', style: TextStyle(color: primary, fontSize: 12)),
          Text('• Dedicated premium service experience', style: TextStyle(color: primary, fontSize: 12)),
        ]),
      );
}
