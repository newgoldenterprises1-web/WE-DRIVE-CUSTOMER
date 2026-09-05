import 'package:flutter/material.dart';

class SosButton extends StatelessWidget {
  final VoidCallback onSosPressed;

  const SosButton({super.key, required this.onSosPressed});

  static void showSosDialog(
    BuildContext context, {
    required VoidCallback onCallPolice,
    required VoidCallback onCallAmbulance,
    required VoidCallback onShareLocation,
    required VoidCallback onEmergencyContact,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Emergency SOS Assistance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.local_police, color: Colors.red),
              title: const Text("Call Police (100)"),
              onTap: onCallPolice,
            ),
            ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.red),
              title: const Text("Call Ambulance (108)"),
              onTap: onCallAmbulance,
            ),
            ListTile(
              leading: const Icon(Icons.share_location, color: Color(0xFF173B6D)),
              title: const Text("Share Live Location with Emergency Contacts"),
              onTap: onShareLocation,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onSosPressed,
        icon: const Icon(Icons.warning_rounded, color: Colors.red),
        label: const Text("EMERGENCY SOS", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}