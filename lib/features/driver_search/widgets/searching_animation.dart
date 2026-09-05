import 'package:flutter/material.dart';

class SearchingAnimation extends StatefulWidget {
  const SearchingAnimation({super.key});

  @override
  State<SearchingAnimation> createState() => _SearchingAnimationState();
}

class _SearchingAnimationState extends State<SearchingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      width: 230,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final scale = 1 + (controller.value * .25);

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: .08),
                  ),
                ),
              ),

              Transform.scale(
                scale: scale * .82,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: .15),
                  ),
                ),
              ),

              Container(
                width: 95,
                height: 95,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 46,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}