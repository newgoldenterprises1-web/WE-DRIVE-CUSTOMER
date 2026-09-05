import 'package:flutter/material.dart';
import '../../booking/booking_screen.dart';

class ChauffeurSection extends StatelessWidget {
  const ChauffeurSection({super.key});

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Row(
          children: [

            Text(
              "Nearby Chauffeurs",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),

            Spacer(),

            Text(
              "View All",
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),

        const SizedBox(height: 18),

        chauffeurCard(
          context,
          "Ahmed Khan",
          "Executive Chauffeur",
          "4.9",
          "3 mins",
          "1.2 km",
          Colors.blue,
        ),

        const SizedBox(height: 15),

        chauffeurCard(
          context,
          "Salman Ali",
          "Luxury Driver",
          "4.8",
          "5 mins",
          "2.4 km",
          Colors.green,
        ),

        const SizedBox(height: 15),

        chauffeurCard(
          context,
          "Arif Shaikh",
          "Corporate Driver",
          "5.0",
          "7 mins",
          "3.1 km",
          Colors.orange,
        ),
      ],
    );
  }

  Widget chauffeurCard(
    BuildContext context,
    String name,
    String role,
    String rating,
    String eta,
    String distance,
    Color avatarColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 14,
          )
        ],
      ),
      child: Column(
        children: [

          Row(
            children: [

              CircleAvatar(
                radius: 28,
                backgroundColor: avatarColor.withValues(alpha: .15),
                child: Icon(
                  Icons.person,
                  color: avatarColor,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    Text(
                      role,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [

                    const Icon(
                      Icons.star,
                      color: gold,
                      size: 16,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      rating,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [

              const Icon(Icons.schedule,color: primary,size:18),
              const SizedBox(width:5),

              Text(eta),

              const SizedBox(width:18),

              const Icon(Icons.location_on,color: Colors.red,size:18),

              const SizedBox(width:5),

              Text(distance),

              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingScreen(),
                    ),
                  );
                },
                child: const Text("Book"),
              )

            ],
          )

        ],
      ),
    );
  }
}