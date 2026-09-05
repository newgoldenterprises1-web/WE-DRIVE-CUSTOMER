import 'package:flutter/material.dart';

class RecentTripCard extends StatelessWidget {
  const RecentTripCard({
    super.key,
    required this.pickup,
    required this.drop,
    required this.driverName,
    required this.vehicle,
    required this.fare,
    required this.date,
    required this.rating,
    this.onTap,
  });

  final String pickup;
  final String drop;
  final String driverName;
  final String vehicle;
  final String fare;
  final String date;
  final double rating;
  final VoidCallback? onTap;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      "Recent Trip",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Completed",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  const Icon(
                    Icons.my_location,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pickup,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  height: 24,
                  child: VerticalDivider(),
                ),
              ),

              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      drop,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(driverName),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(vehicle),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Text(
                    fare,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                date,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}