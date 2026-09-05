import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ExecutiveSupportScreen extends StatelessWidget {
  const ExecutiveSupportScreen({super.key});

  static const Color primary = Color(0xFF173B6D);

  Widget supportTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .12),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: () async {
          Uri? uri;

          if (title == "Call Support") {
            uri = Uri.parse('tel:+918000000000');
          } else if (title == "Email Support") {
            uri = Uri.parse('mailto:support@wedrive.com');
          } else if (title == "Emergency SOS") {
            uri = Uri.parse('tel:112');
          } else {
            showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(title),
                content: Text(
                  '$title is ready. Live backend support will be connected later.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );

            return;
          }

          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Unable to open $title.',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Executive Support"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          supportTile(
            context,
            Icons.call,
            "Call Support",
            "Available 24×7",
            Colors.green,
          ),

          supportTile(
            context,
            Icons.chat,
            "Live Chat",
            "Average reply in 2 mins",
            Colors.blue,
          ),

          supportTile(
            context,
            Icons.email,
            "Email Support",
            "support@wedrive.com",
            Colors.orange,
          ),

          supportTile(
            context,
            Icons.warning_amber_rounded,
            "Emergency SOS",
            "Immediate chauffeur assistance",
            Colors.red,
          ),

          const SizedBox(height: 25),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Support feature will be connected in backend.",
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.support_agent,
              ),
              label: const Text(
                "CONTACT SUPPORT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}