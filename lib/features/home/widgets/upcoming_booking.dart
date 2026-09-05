import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../journeys/journeys_screen.dart';

class UpcomingBooking extends StatelessWidget {
  const UpcomingBooking({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upcoming Booking",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Tomorrow",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFD4AF37),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Iconsax.verify5,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Confirmed",
                      style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    const Icon(Iconsax.location, color: Color(0xFF173B6D)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Banjara Hills",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 11),
                  child: SizedBox(
                    height: 28,
                    child: VerticalDivider(),
                  ),
                ),

                Row(
                  children: [
                    const Icon(Iconsax.location_add,
                        color: Color(0xFF173B6D)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Rajiv Gandhi International Airport",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(Iconsax.clock, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "09:00 AM",
                      style: GoogleFonts.poppins(),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JourneysScreen(),
                          ),
                        );
                      },
                      child: const Text("View"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}