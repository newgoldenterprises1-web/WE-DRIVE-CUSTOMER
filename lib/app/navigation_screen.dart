import 'package:flutter/material.dart';

import '../features/booking/rides_history_screen.dart';
import '../features/fleet/fleet_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int currentIndex = 0;

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  final List<Widget> _pages = const [
    HomeScreen(),
    FleetScreen(),
    RidesHistoryScreen(), // Yahan Trips me naya invoice aur history connect ho gaya
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _item(Icons.home_rounded, "Home", 0),
              _item(Icons.directions_car_rounded, "Garage", 1),
              _item(Icons.route_rounded, "Trips", 2),
              _item(Icons.person_rounded, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String title, int index) {
    final bool selected = currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            currentIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? gold : Colors.grey.shade500,
                size: 24,
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}