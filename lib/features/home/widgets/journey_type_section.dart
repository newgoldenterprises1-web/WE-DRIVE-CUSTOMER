import 'package:flutter/material.dart';

class JourneyTypeSection extends StatefulWidget {
  const JourneyTypeSection({super.key});

  @override
  State<JourneyTypeSection> createState() => _JourneyTypeSectionState();
}

class _JourneyTypeSectionState extends State<JourneyTypeSection> {
  int selected = 0;

  final List<Map<String, dynamic>> items = [
    {"icon": Icons.arrow_forward, "title": "One Way"},
    {"icon": Icons.sync_alt, "title": "Round Trip"},
    {"icon": Icons.access_time_filled, "title": "Hourly"},
    {"icon": Icons.calendar_today, "title": "Daily"},
    {"icon": Icons.route, "title": "Outstation"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Journey Type",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B6D),
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          height: 88,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final isSelected = selected == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selected = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 82,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF173B6D)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[index]["icon"],
                        size: 26,
                        color: isSelected
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFF173B6D),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        items[index]["title"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF173B6D),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}