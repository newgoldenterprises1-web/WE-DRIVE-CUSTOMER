import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'destination_screen.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  String selected = 'Banjara Hills, Hyderabad';
  String query = '';

  final List<List<String>> locations = const [
    ['Banjara Hills, Hyderabad', 'Road No. 12'],
    ['Hitech City, Hyderabad', 'Cyber Towers'],
    ['Gachibowli, Hyderabad', 'Financial District'],
    ['Jubilee Hills, Hyderabad', 'Road No. 36'],
    ['Rajiv Gandhi International Airport', 'Shamshabad'],
  ];

  @override
  Widget build(BuildContext context) {
    final List<List<String>> filtered = locations
        .where(
          (item) => item[0]
              .toLowerCase()
              .contains(query.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Pickup Location',
          style: GoogleFonts.poppins(
            color: primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ======================================================
      // CONTINUE BUTTON
      // ======================================================

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DestinationScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ====================================================
          // SEARCH
          // ====================================================

          TextField(
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search pickup location',
              prefixIcon: const Icon(
                Iconsax.search_normal,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ====================================================
          // MAP PREVIEW
          // ====================================================

          Container(
            height: 210,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomPaint(
                painter: _RoutePreviewPainter(),
                child: Stack(
                  children: [
                    const Positioned(
                      top: 16,
                      left: 16,
                      child: _MapChip(),
                    ),

                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton.small(
                        heroTag: 'pickup-location',
                        backgroundColor: Colors.white,
                        foregroundColor: primary,
                        onPressed: () {
                          setState(() {
                            selected =
                                'Current Location, Hyderabad';
                          });
                        },
                        child: const Icon(
                          Icons.my_location_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ====================================================
          // QUICK ACCESS
          // ====================================================

          Text(
            'Quick Access',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: primary,
            ),
          ),

          const SizedBox(height: 12),

          _tile(
            Icons.my_location_rounded,
            'Use Current Location',
            'Hyderabad GPS',
            () {
              setState(() {
                selected =
                    'Current Location, Hyderabad';
              });
            },
          ),

          _tile(
            Icons.home_rounded,
            'Home',
            'Banjara Hills',
            () {
              setState(() {
                selected =
                    'Banjara Hills, Hyderabad';
              });
            },
          ),

          _tile(
            Icons.business_center_rounded,
            'Office',
            'Financial District',
            () {
              setState(() {
                selected =
                    'Financial District, Hyderabad';
              });
            },
          ),

          const SizedBox(height: 14),

          // ====================================================
          // LOCATIONS
          // ====================================================

          Text(
            'Locations',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: primary,
            ),
          ),

          const SizedBox(height: 12),

          ...filtered.map(
            (item) => _tile(
              Icons.location_on_outlined,
              item[0],
              item[1],
              () {
                setState(() {
                  selected = item[0];
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // ====================================================
          // SELECTED PICKUP
          // ====================================================

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selected pickup: $selected',
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOCATION TILE
  // ==========================================================

  Widget _tile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: primary.withValues(alpha: .08),
          child: Icon(
            icon,
            color: primary,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
        ),
      ),
    );
  }
}

// ============================================================
// MAP CHIP
// ============================================================

class _MapChip extends StatelessWidget {
  const _MapChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            Icons.map_rounded,
            color: Color(0xFF173B6D),
            size: 18,
          ),
          SizedBox(width: 6),
          Text(
            'Route preview',
            style: TextStyle(
              color: Color(0xFF173B6D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ROUTE PREVIEW PAINTER
// ============================================================

class _RoutePreviewPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint bg = Paint()
      ..color = const Color(0xFFEAF3FF);

    canvas.drawRect(
      Offset.zero & size,
      bg,
    );

    final Paint road = Paint()
      ..color = Colors.white
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..moveTo(
        0,
        size.height * .75,
      )
      ..cubicTo(
        size.width * .25,
        size.height * .35,
        size.width * .55,
        size.height * .9,
        size.width,
        size.height * .3,
      );

    canvas.drawPath(
      path,
      road,
    );

    final Paint line = Paint()
      ..color = const Color(0xFF173B6D)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      path,
      line,
    );

    canvas.drawCircle(
      Offset(
        size.width * .18,
        size.height * .68,
      ),
      9,
      Paint()..color = Colors.green,
    );

    canvas.drawCircle(
      Offset(
        size.width * .82,
        size.height * .34,
      ),
      9,
      Paint()..color = Colors.red,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}