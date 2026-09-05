import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'premium_rating_review_screen.dart';


class PremiumTripActiveScreen extends StatefulWidget {
  const PremiumTripActiveScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
    required this.serviceType,
    required this.fare,
  });

  final String pickupLocation;
  final String dropLocation;
  final String serviceType;
  final String fare;

  @override
  State<PremiumTripActiveScreen> createState() =>
      _PremiumTripActiveScreenState();
}

class _PremiumTripActiveScreenState
    extends State<PremiumTripActiveScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FA);

  double progress = 0.42;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (!mounted) return;

        setState(() {
          progress =
              progress >= 0.94 ? 0.42 : progress + 0.06;
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _completeTrip() {
    timer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PremiumRatingReviewScreen(
          chauffeurName: "Rahul Sharma",
        ),
      ),
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
    final remaining =
        (18 * (1 - progress)).clamp(1, 18).toStringAsFixed(1);

    final eta =
        (35 * (1 - progress)).clamp(3, 35).round();

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Premium Trip Active",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _tripHeader(),

            const SizedBox(height: 20),

            _liveRoute(),

            const SizedBox(height: 20),

            _routeCard(),

            const SizedBox(height: 20),

            _chauffeurCard(),

            const SizedBox(height: 20),

            _tripInfo(
              remaining: remaining,
              eta: eta,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showMessage(
                        "Premium trip sharing link is ready.",
                      );
                    },
                    icon: const Icon(
                      Icons.share_location_rounded,
                    ),
                    label: const Text("Share Trip"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(
                        color: primary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri(
                        scheme: 'tel',
                        path: '9876543210',
                      );
                      try {
                        final launched = await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                        if (!launched && mounted) {
                          _showMessage('Unable to open phone dialer.');
                        }
                      } catch (_) {
                        if (mounted) {
                          _showMessage('Unable to open phone dialer.');
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.phone_rounded,
                    ),
                    label: const Text("Call"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(
                        color: primary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _completeTrip,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text("Complete Trip"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tripHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary,
            Color(0xFF1D4A84),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: .20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: gold,
            size: 34,
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Premium Trip In Progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Your premium chauffeur is driving you to your destination.",
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
    );
  }

  Widget _liveRoute() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: CustomPaint(
          painter: _PremiumRoutePainter(progress),
          child: Stack(
            children: [
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.gps_fixed_rounded,
                        color: primary,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Live premium route",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${(progress * 100).round()}% complete",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Premium Trip Route",
            style: TextStyle(
              color: primary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _locationRow(
            Icons.radio_button_checked,
            Colors.green,
            "Pickup",
            widget.pickupLocation,
          ),

          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              height: 32,
              width: 2,
              color: Colors.grey.shade300,
            ),
          ),

          _locationRow(
            Icons.location_on_rounded,
            Colors.red,
            "Destination",
            widget.dropLocation,
          ),
        ],
      ),
    );
  }

  Widget _locationRow(
    IconData icon,
    Color color,
    String title,
    String location,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 23,
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                location,
                style: const TextStyle(
                  color: primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chauffeurCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: gold.withValues(alpha: .25),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: primary,
              size: 32,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "Rahul Sharma",
                  style: TextStyle(
                    color: primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Premium Chauffeur",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.star_rounded,
            color: gold,
            size: 21,
          ),

          const SizedBox(width: 4),

          const Text(
            "4.9",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripInfo({
    required String remaining,
    required int eta,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.route_rounded,
            "Distance Remaining",
            "$remaining km",
          ),

          const Divider(height: 28),

          _infoRow(
            Icons.timer_rounded,
            "Estimated Arrival",
            "$eta mins",
          ),

          const Divider(height: 28),

          _infoRow(
            Icons.workspace_premium_rounded,
            "Premium Fare",
            widget.fare,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: primary,
          size: 23,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            color: primary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PremiumRoutePainter extends CustomPainter {
  _PremiumRoutePainter(this.progress);

  final double progress;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEAF3FF),
    );

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final route = Path()
      ..moveTo(
        size.width * .08,
        size.height * .78,
      )
      ..cubicTo(
        size.width * .24,
        size.height * .22,
        size.width * .48,
        size.height * .86,
        size.width * .88,
        size.height * .25,
      );

    canvas.drawPath(route, road);

    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFF173B6D)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );

    final metrics = route.computeMetrics().first;

    final point = metrics
            .getTangentForOffset(
              metrics.length *
                  progress.clamp(0.0, 1.0),
            )
            ?.position ??
        Offset(
          size.width * .5,
          size.height * .5,
        );

    canvas.drawCircle(
      point,
      18,
      Paint()..color = const Color(0xFFD4AF37),
    );

    canvas.drawCircle(
      point,
      11,
      Paint()..color = const Color(0xFF173B6D),
    );

    canvas.drawCircle(
      Offset(
        size.width * .08,
        size.height * .78,
      ),
      9,
      Paint()..color = Colors.green,
    );

    canvas.drawCircle(
      Offset(
        size.width * .88,
        size.height * .25,
      ),
      9,
      Paint()..color = Colors.red,
    );
  }

  @override
  bool shouldRepaint(
    covariant _PremiumRoutePainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}