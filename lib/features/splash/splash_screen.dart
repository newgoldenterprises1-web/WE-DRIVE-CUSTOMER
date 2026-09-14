import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/navigation_screen.dart';
import '../auth/login_screen.dart';
import '../auth/profile_completion_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryDark = Color(0xFF0F2547);
  static const Color gold = Color(0xFFD4AF37);

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _checkAuthentication();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted || _navigated) return;

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _goToLogin();
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 4));

      final data = snapshot.data() ?? <String, dynamic>{};
      final phone = (data['phone'] ?? user.phoneNumber ?? '').toString().trim();
      final gender = (data['gender'] ?? '').toString().trim();
      final complete = data['profileCompleted'] == true &&
          phone.isNotEmpty &&
          data['age'] != null &&
          gender.isNotEmpty;

      if (!mounted || _navigated) return;

      _navigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => complete
              ? const NavigationScreen()
              : ProfileCompletionScreen(user: user),
        ),
      );
    } catch (_) {
      // Do not allow a Firestore/network problem to trap the app on splash.
      // An authenticated user can still enter the app and retry data loading.
      _goToHome();
    }
  }

  void _goToLogin() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goToHome() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.1),
                  radius: 1.15,
                  colors: [
                    Color(0xFF1B3D6E),
                    Color(0xFF0F2547),
                    Color(0xFF091629),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                "We Drive",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 44,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: gold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 1,
                                color: gold.withValues(alpha: 0.5),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "We Drive When You Don't",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 1,
                                color: gold.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 5),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 40,
                      height: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(gold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
