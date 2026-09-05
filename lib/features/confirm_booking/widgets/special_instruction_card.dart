import 'package:flutter/material.dart';

class SpecialInstructionCard extends StatelessWidget {
  const SpecialInstructionCard({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  static const Color primaryColor = Color(0xFF173B6D);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                Icons.edit_note_rounded,
                color: accentColor,
              ),
              SizedBox(width: 8),
              Text(
                "Special Instructions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              hintText:
                  "Example:\n• Please call before arrival.\n• Pickup from Gate No. 3.\n• I have 2 luggage bags.",
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(
                icon: Icons.call,
                text: "Call Before Arrival",
                value: "Please call before arrival.",
              ),
              _chip(
                icon: Icons.luggage,
                text: "2 Luggage",
                value: "I have 2 luggage bags.",
              ),
              _chip(
                icon: Icons.meeting_room,
                text: "Gate No. 3",
                value: "Pickup from Gate No. 3.",
              ),
              _chip(
                icon: Icons.pets,
                text: "Pet Onboard",
                value: "Travelling with a pet.",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required IconData icon,
    required String text,
    required String value,
  }) {
    return Builder(
      builder: (context) {
        return ActionChip(
          avatar: Icon(
            icon,
            size: 18,
            color: primaryColor,
          ),
          label: Text(text),
          backgroundColor: accentColor.withValues(alpha: .12),
          onPressed: () {
            controller.text = value;
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          },
        );
      },
    );
  }
}