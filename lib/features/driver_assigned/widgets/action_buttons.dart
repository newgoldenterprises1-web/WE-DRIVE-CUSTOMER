import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onChat;
  final VoidCallback onTrack;
  final VoidCallback onShare;

  const ActionButtons({
    super.key,
    required this.onCall,
    required this.onChat,
    required this.onTrack,
    required this.onShare,
  });

  Widget _buildBtn(IconData icon, String label, VoidCallback onTap, {Color color = const Color(0xFF173B6D)}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBtn(Icons.call, "Call", onCall),
          _buildBtn(Icons.message, "Chat", onChat),
          _buildBtn(Icons.my_location, "Track", onTrack),
          _buildBtn(Icons.share, "Share", onShare),
        ],
      ),
    );
  }
}