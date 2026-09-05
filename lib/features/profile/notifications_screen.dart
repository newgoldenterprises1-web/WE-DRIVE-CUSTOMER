import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FB);

  bool rideUpdates = true;
  bool promotionalAlerts = true;
  bool paymentNotifications = true;
  bool safetyAlerts = true;

  bool get allEnabled =>
      rideUpdates &&
      promotionalAlerts &&
      paymentNotifications &&
      safetyAlerts;

  void _setAllNotifications(bool value) {
    setState(() {
      rideUpdates = value;
      promotionalAlerts = value;
      paymentNotifications = value;
      safetyAlerts = value;
    });

    _showMessage(
      value
          ? "All notifications enabled."
          : "All notifications disabled.",
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // --------------------------------------------------
      // APP BAR
      // --------------------------------------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: primary,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
          children: [

            // --------------------------------------------------
            // HEADER CARD
            // --------------------------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF173B6D),
                    Color(0xFF295FA7),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: .20),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: gold,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Stay Updated",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Choose which notifications you want to receive from WE DRIVE.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // --------------------------------------------------
            // GENERAL
            // --------------------------------------------------
            const Text(
              "Notification Preferences",
              style: TextStyle(
                color: primary,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // --------------------------------------------------
            // ENABLE ALL
            // --------------------------------------------------
            _notificationTile(
              icon: Icons.notifications_active_rounded,
              title: "All Notifications",
              subtitle: "Enable or disable all notifications",
              value: allEnabled,
              onChanged: _setAllNotifications,
              showGoldIcon: true,
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // RIDE UPDATES
            // --------------------------------------------------
            _notificationTile(
              icon: Icons.directions_car_rounded,
              title: "Ride Updates",
              subtitle:
                  "Booking, chauffeur assignment & trip updates",
              value: rideUpdates,
              onChanged: (value) {
                setState(() {
                  rideUpdates = value;
                });

                _showMessage(
                  value
                      ? "Ride updates enabled."
                      : "Ride updates disabled.",
                );
              },
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // PAYMENT
            // --------------------------------------------------
            _notificationTile(
              icon: Icons.payment_rounded,
              title: "Payment Notifications",
              subtitle:
                  "Payment confirmations, refunds & receipts",
              value: paymentNotifications,
              onChanged: (value) {
                setState(() {
                  paymentNotifications = value;
                });

                _showMessage(
                  value
                      ? "Payment notifications enabled."
                      : "Payment notifications disabled.",
                );
              },
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // SAFETY
            // --------------------------------------------------
            _notificationTile(
              icon: Icons.security_rounded,
              title: "Safety & Security",
              subtitle:
                  "Important safety and security alerts",
              value: safetyAlerts,
              onChanged: (value) {
                setState(() {
                  safetyAlerts = value;
                });

                _showMessage(
                  value
                      ? "Safety alerts enabled."
                      : "Safety alerts disabled.",
                );
              },
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // PROMOTIONS
            // --------------------------------------------------
            _notificationTile(
              icon: Icons.local_offer_rounded,
              title: "Promotional Alerts",
              subtitle:
                  "Offers, discounts & special promotions",
              value: promotionalAlerts,
              onChanged: (value) {
                setState(() {
                  promotionalAlerts = value;
                });

                _showMessage(
                  value
                      ? "Promotional alerts enabled."
                      : "Promotional alerts disabled.",
                );
              },
            ),

            const SizedBox(height: 26),

            // --------------------------------------------------
            // IMPORTANT INFO
            // --------------------------------------------------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: primary,
                    ),
                  ),

                  const SizedBox(width: 13),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Important",
                          style: TextStyle(
                            color: primary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Some critical service and safety notifications may still be sent even when optional notifications are disabled.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --------------------------------------------------
            // STATUS
            // --------------------------------------------------
            Center(
              child: Text(
                allEnabled
                    ? "All notifications are enabled"
                    : "Notification preferences are customized",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // NOTIFICATION TILE
  // --------------------------------------------------
  Widget _notificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showGoldIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [

          // ICON
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: showGoldIcon
                  ? gold.withValues(alpha: .12)
                  : primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: showGoldIcon ? gold : primary,
              size: 25,
            ),
          ),

          const SizedBox(width: 15),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // SWITCH
          Switch.adaptive(
            value: value,
            activeThumbColor: primary,
            activeTrackColor:
                primary.withValues(alpha: .30),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}