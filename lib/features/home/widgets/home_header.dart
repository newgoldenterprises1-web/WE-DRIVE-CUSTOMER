import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    required this.onMenuTap,
    required this.onNotificationTap,
  });

  final String userName;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                // --------------------------------------------------
                // MENU BUTTON
                // --------------------------------------------------
                GestureDetector(
                  onTap: onMenuTap,
                  child: Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),

                const Spacer(),

                const Text(
                  "WE DRIVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const Spacer(),

                // --------------------------------------------------
                // NOTIFICATION BUTTON
                // --------------------------------------------------
                GestureDetector(
                  onTap: onNotificationTap,
                  child: Stack(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
                      ),

                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: const BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Good Evening,",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .8),
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Where would you like to go today?",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .9),
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}