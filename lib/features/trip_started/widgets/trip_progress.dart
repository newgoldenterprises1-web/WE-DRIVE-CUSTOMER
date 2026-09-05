import 'package:flutter/material.dart';

enum TripStage {
  pickupCompleted,
  tripStarted,
  onTheWay,
  nearDestination,
  completed,
}

class TripProgress extends StatelessWidget {
  const TripProgress({
    super.key,
    required this.stage,
    required this.progress,
  });

  final TripStage stage;

  /// Value between 0.0 and 1.0
  final double progress;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Row(
            children: [
              Icon(
                Icons.timeline,
                color: accentColor,
              ),
              SizedBox(width: 10),
              Text(
                "Trip Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(
                accentColor,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(progress * 100).round()}% Completed",
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 25),

          _step(
            active: stage.index >= TripStage.pickupCompleted.index,
            icon: Icons.check_circle,
            title: "Pickup Completed",
            subtitle: "Customer boarded successfully",
          ),

          _connector(stage.index >= TripStage.tripStarted.index),

          _step(
            active: stage.index >= TripStage.tripStarted.index,
            icon: Icons.directions_car,
            title: "Trip Started",
            subtitle: "Journey has started",
          ),

          _connector(stage.index >= TripStage.onTheWay.index),

          _step(
            active: stage.index >= TripStage.onTheWay.index,
            icon: Icons.navigation,
            title: "On The Way",
            subtitle: "Heading towards destination",
          ),

          _connector(stage.index >= TripStage.nearDestination.index),

          _step(
            active: stage.index >= TripStage.nearDestination.index,
            icon: Icons.flag_circle,
            title: "Near Destination",
            subtitle: "Almost reached",
          ),

          _connector(stage.index >= TripStage.completed.index),

          _step(
            active: stage.index >= TripStage.completed.index,
            icon: Icons.verified,
            title: "Trip Completed",
            subtitle: "Thank you for choosing WE DRIVE",
          ),
        ],
      ),
    );
  }

  Widget _connector(bool active) {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: Container(
        width: 2,
        height: 22,
        color: active ? accentColor : Colors.grey.shade300,
      ),
    );
  }

  Widget _step({
    required bool active,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        CircleAvatar(
          radius: 17,
          backgroundColor:
              active ? accentColor : Colors.grey.shade300,
          child: Icon(
            icon,
            size: 18,
            color:
                active ? primaryColor : Colors.grey.shade600,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: active
                        ? primaryColor
                        : Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}