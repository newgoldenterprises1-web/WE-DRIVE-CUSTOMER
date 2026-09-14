import 'package:flutter/material.dart';

import '../booking/pickup_drop_screen.dart';
import 'chauffeur_preferences_screen.dart';

class ConciergeScreen extends StatelessWidget {
  const ConciergeScreen({super.key});

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('WE DRIVE Concierge', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primary, Color(0xFF2D5B8E)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.workspace_premium_rounded, color: gold, size: 34),
              SizedBox(height: 14),
              Text('Signature Chauffeur', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              SizedBox(height: 7),
              Text('A smarter chauffeur experience built around your preferences, safety and time.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45)),
            ]),
          ),
          const SizedBox(height: 16),
          _feature(Icons.auto_awesome_rounded, 'Signature Match', 'MatchScore, reliability, rating, experience and verification are considered together.'),
          _feature(Icons.badge_rounded, 'Chauffeur Passport', 'Assigned chauffeur can carry a WE DRIVE verified digital identity and service badges.'),
          _feature(Icons.volume_off_rounded, 'Quiet / Private Journey', 'Choose quiet, normal or conversational service and enable privacy mode.'),
          _feature(Icons.support_agent_rounded, 'Executive Concierge', 'Special assistance, guest rides, event support and white-glove service.'),
          _feature(Icons.event_repeat_rounded, 'Recurring Chauffeur', 'Designed for office commutes, regular airport runs and repeat schedules.'),
          _feature(Icons.groups_rounded, 'Guest & Event Chauffeur', 'Book for family, clients, weddings, conferences and multiple guests.'),
          _feature(Icons.location_on_rounded, 'Smart Pickup', 'Lobby, gate, parking, terminal or a custom meeting point.'),
          _feature(Icons.shield_rounded, 'Safety First', 'Trip OTP, trusted contacts, live trip sharing and SOS workflow support.'),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChauffeurPreferencesScreen())),
            icon: const Icon(Icons.tune_rounded),
            label: const Text('MANAGE MY CHAUFFEUR PREFERENCES', style: TextStyle(fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: BorderSide(color: primary.withValues(alpha: 0.25)),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PickupDropScreen(
                      serviceType: 'Concierge Chauffeur',
                      isPremium: true,
                      premiumFare: 'On Request',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('START CONCIERGE REQUEST', style: TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _feature(IconData icon, String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 13.5)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(color: Colors.black54, fontSize: 11.5, height: 1.35)),
        ])),
      ]),
    );
  }
}
