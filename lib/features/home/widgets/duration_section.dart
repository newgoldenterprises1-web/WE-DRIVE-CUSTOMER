import 'package:flutter/material.dart';

class DurationSection extends StatefulWidget {
  const DurationSection({super.key});

  @override
  State<DurationSection> createState() => _DurationSectionState();
}

class _DurationSectionState extends State<DurationSection> {
  int selected = 2;

  final List<String> duration = [
    "1H",
    "2H",
    "4H",
    "6H",
    "8H",
    "10H",
    "12H",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Booking Duration",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF173B6D),
          ),
        ),

        const SizedBox(height: 15),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(
            duration.length,
            (index) {
              final isSelected = selected == index;

              return InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  setState(() {
                    selected = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF173B6D)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
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
                      ),
                    ],
                  ),
                  child: Text(
                    duration[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF173B6D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF173B6D),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Need more time? You can extend your booking anytime during your journey.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF173B6D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}