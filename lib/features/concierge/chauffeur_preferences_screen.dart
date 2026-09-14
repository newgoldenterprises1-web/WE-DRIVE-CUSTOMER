import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChauffeurPreferencesScreen extends StatefulWidget {
  const ChauffeurPreferencesScreen({super.key});

  @override
  State<ChauffeurPreferencesScreen> createState() => _ChauffeurPreferencesScreenState();
}

class _ChauffeurPreferencesScreenState extends State<ChauffeurPreferencesScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bg = Color(0xFFF8FAFC);

  String communication = 'NORMAL';
  String luggage = 'LIGHT';
  bool privacy = false;
  bool whiteGlove = false;
  bool concierge = false;
  bool preferredChauffeur = false;
  bool trustedSharing = false;
  bool recurring = false;
  String language = 'English';
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snap.data() ?? {};
    final p = Map<String, dynamic>.from(data['chauffeurPreferences'] as Map? ?? {});
    if (!mounted) return;
    setState(() {
      communication = (p['communicationStyle'] ?? communication).toString();
      luggage = (p['luggageMode'] ?? luggage).toString();
      privacy = p['privacyMode'] == true;
      whiteGlove = p['whiteGlove'] == true;
      concierge = p['conciergeMode'] == true;
      preferredChauffeur = p['preferredChauffeurPriority'] == true;
      trustedSharing = p['trustedContactSharing'] == true;
      recurring = p['recurringBookingEnabled'] == true;
      language = (p['preferredLanguage'] ?? language).toString();
    });
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'chauffeurPreferences': {
          'communicationStyle': communication,
          'luggageMode': luggage,
          'privacyMode': privacy,
          'whiteGlove': whiteGlove,
          'conciergeMode': concierge,
          'preferredChauffeurPriority': preferredChauffeur,
          'trustedContactSharing': trustedSharing,
          'recurringBookingEnabled': recurring,
          'preferredLanguage': language,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chauffeur preferences saved.')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text('Chauffeur Preferences', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('How should your chauffeur communicate?', _chips(['QUIET', 'NORMAL', 'CONVERSATIONAL'], communication, (v) => setState(() => communication = v))),
          _section('Luggage preference', _chips(['NONE', 'LIGHT', 'MULTIPLE', 'LARGE'], luggage, (v) => setState(() => luggage = v))),
          _section('Preferred language', _chips(['English', 'Hindi', 'Urdu', 'Telugu'], language, (v) => setState(() => language = v))),
          _switch('Private Journey', 'Minimal conversation and discreet service.', privacy, (v) => setState(() => privacy = v)),
          _switch('White-Glove Service', 'Early arrival and meet-and-greet expectation.', whiteGlove, (v) => setState(() => whiteGlove = v)),
          _switch('Executive Concierge', 'Special assistance and premium support.', concierge, (v) => setState(() => concierge = v)),
          _switch('Preferred Chauffeur Priority', 'Try your trusted chauffeur first when available.', preferredChauffeur, (v) => setState(() => preferredChauffeur = v)),
          _switch('Trusted Contact Sharing', 'Enable trip sharing workflows for trusted contacts.', trustedSharing, (v) => setState(() => trustedSharing = v)),
          _switch('Recurring Chauffeur', 'Enable regular office, airport or scheduled requests.', recurring, (v) => setState(() => recurring = v)),
          const SizedBox(height: 10),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: saving ? null : _save,
              icon: saving ? const SizedBox(width: 19, height: 19, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded),
              label: const Text('SAVE PREFERENCES', style: TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 10), child]),
      );

  Widget _chips(List<String> values, String selected, ValueChanged<String> onSelected) => Wrap(
        spacing: 7,
        runSpacing: 7,
        children: values.map((value) {
          final active = value == selected;
          return ChoiceChip(
            label: Text(value),
            selected: active,
            onSelected: (_) => onSelected(value),
            selectedColor: primary,
            labelStyle: TextStyle(color: active ? Colors.white : primary, fontWeight: FontWeight.w700, fontSize: 11),
          );
        }).toList(),
      );

  Widget _switch(String title, String sub, bool value, ValueChanged<bool> onChanged) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: SwitchListTile.adaptive(
          activeColor: gold,
          title: Text(title, style: const TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 13)),
          subtitle: Text(sub, style: const TextStyle(fontSize: 10.5)),
          value: value,
          onChanged: onChanged,
        ),
      );
}
