import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({
    super.key,
    required this.onSosPressed,
  });

  final VoidCallback onSosPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: onSosPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(
            Icons.sos_rounded,
            size: 28,
          ),
          label: const Text(
            "Emergency SOS",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showEmergencyDialog(
    BuildContext context, {
    required VoidCallback onCallPolice,
    required VoidCallback onCallAmbulance,
    required VoidCallback onEmergencyContact,
    required VoidCallback onShareLocation,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 55,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Color(0x22FF0000),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Emergency Assistance",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Choose an emergency action below.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 24),

                _item(
                  icon: Icons.local_police,
                  color: Colors.blue,
                  title: "Call Police",
                  subtitle: "Contact emergency police service",
                  onTap: () {
                    Navigator.pop(context);
                    onCallPolice();
                  },
                ),

                _item(
                  icon: Icons.medical_services,
                  color: Colors.red,
                  title: "Call Ambulance",
                  subtitle: "Request medical assistance",
                  onTap: () {
                    Navigator.pop(context);
                    onCallAmbulance();
                  },
                ),

                _item(
                  icon: Icons.contact_phone,
                  color: Colors.orange,
                  title: "Emergency Contact",
                  subtitle: "Call your saved emergency contact",
                  onTap: () {
                    Navigator.pop(context);
                    onEmergencyContact();
                  },
                ),

                _item(
                  icon: Icons.share_location,
                  color: Colors.green,
                  title: "Share Live Location",
                  subtitle: "Send your current trip location",
                  onTap: () {
                    Navigator.pop(context);
                    onShareLocation();
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _item({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        onTap: onTap,
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}