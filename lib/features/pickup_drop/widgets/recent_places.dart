import 'package:flutter/material.dart';

class RecentPlaces extends StatelessWidget {
  const RecentPlaces({
    super.key,
    required this.onPlaceTap,
  });

  final Function(String address) onPlaceTap;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final recentPlaces = [
      {
        "title": "Rajiv Gandhi International Airport",
        "subtitle": "Shamshabad, Hyderabad",
        "time": "2 hours ago",
        "icon": Icons.flight_takeoff,
      },
      {
        "title": "Inorbit Mall",
        "subtitle": "Hitech City, Hyderabad",
        "time": "Yesterday",
        "icon": Icons.shopping_bag,
      },
      {
        "title": "Banjara Hills Road No.12",
        "subtitle": "Hyderabad",
        "time": "2 days ago",
        "icon": Icons.location_city,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Recent Places",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),

        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentPlaces.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final place = recentPlaces[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                elevation: 1,
                child: ListTile(
                  onTap: () => onPlaceTap(place["title"] as String),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      place["icon"] as IconData,
                      color: primaryColor,
                    ),
                  ),
                  title: Text(
                    place["title"] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    "${place["subtitle"]}\n${place["time"]}",
                  ),
                  isThreeLine: true,
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}