import 'package:flutter/material.dart';

class SavedPlaces extends StatelessWidget {
  const SavedPlaces({
    super.key,
    required this.onHomeTap,
    required this.onWorkTap,
    required this.onFavoriteTap,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onWorkTap;
  final VoidCallback onFavoriteTap;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Saved Places",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),

        const SizedBox(height: 14),

        _placeTile(
          icon: Icons.home_rounded,
          title: "Home",
          subtitle: "Add your home address",
          onTap: onHomeTap,
        ),

        _placeTile(
          icon: Icons.work_rounded,
          title: "Work",
          subtitle: "Add your office address",
          onTap: onWorkTap,
        ),

        _placeTile(
          icon: Icons.star_rounded,
          title: "Favorites",
          subtitle: "Quick access to saved places",
          onTap: onFavoriteTap,
        ),
      ],
    );
  }

  Widget _placeTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 1,
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: primaryColor,
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
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}