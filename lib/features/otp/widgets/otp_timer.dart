import 'dart:async';

import 'package:flutter/material.dart';

class OtpTimer extends StatefulWidget {
  const OtpTimer({
    super.key,
    required this.onExpired,
  });

  final VoidCallback onExpired;

  @override
  State<OtpTimer> createState() => OtpTimerState();
}

class OtpTimerState extends State<OtpTimer> {
  static const Color primary = Color(0xFF173B6D);

  Timer? _timer;
  int _seconds = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void restart() {
    _timer?.cancel();

    setState(() {
      _seconds = 30;
    });

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_seconds == 0) {
          timer.cancel();
          widget.onExpired();
          return;
        }

        setState(() {
          _seconds--;
        });
      },
    );
  }

  String get formattedTime {
    final sec = _seconds.toString().padLeft(2, '0');
    return "00:$sec";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              const Icon(
                Icons.timer_outlined,
                color: primary,
                size: 18,
              ),

              const SizedBox(width: 8),

              Text(
                formattedTime,
                style: const TextStyle(
                  color: primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Text(
          _seconds == 0
              ? "OTP Expired"
              : "OTP expires in",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}