import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ride_history_screen.dart';
import 'payment_methods_screen.dart';
import 'safety_security_screen.dart';
import '../auth/login_screen.dart';
import '../concierge/concierge_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFF1F5F9);

  static const String supportPhone = '+919876543210';
  static const String supportEmail = 'support@wedrive.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream() {
    final User? user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  String _getName(Map<String, dynamic> data, User user) {
    final name = data['name'];
    if (name is String && name.trim().isNotEmpty) return name.trim();
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    return 'WE DRIVE Customer';
  }

  String _getPhone(Map<String, dynamic> data, User user) {
    final phone = data['phone'];
    if (phone is String && phone.trim().isNotEmpty) return phone.trim();
    if (user.phoneNumber != null && user.phoneNumber!.trim().isNotEmpty) {
      return user.phoneNumber!;
    }
    return 'Phone number not available';
  }

  String _getEmail(Map<String, dynamic> data, User user) {
    final email = data['email'];
    if (email is String && email.trim().isNotEmpty) return email.trim();
    if (user.email != null && user.email!.trim().isNotEmpty) {
      return user.email!;
    }
    return 'Email not added';
  }

  String _getMemberType(Map<String, dynamic> data) {
    final role = data['role'];
    if (role == 'customer' || role == null) return 'Premium Member';
    if (role is String && role.trim().isNotEmpty) return role.trim();
    return 'Premium Member';
  }

  Future<void> _callSupport(BuildContext context) async {
    final uri = Uri.parse('tel:$supportPhone');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showMessage(context, 'Unable to open phone dialer.');
      }
    } catch (_) {
      if (context.mounted) _showMessage(context, 'Unable to open phone dialer.');
    }
  }

  Future<void> _emailSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {'subject': 'WE DRIVE Customer Support'},
    );
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showMessage(context, 'No email application found.');
      }
    } catch (_) {
      if (context.mounted) _showMessage(context, 'Unable to open email application.');
    }
  }

  void _showMembershipPerks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Icon(Icons.military_tech_rounded, color: gold, size: 28),
                SizedBox(width: 8),
                Text(
                  "We Drive Club Membership",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: primary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Exclusive Privileges for Hyderabad Elite Car Owners",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            _benefitRow(Icons.bolt_rounded, "Priority Chauffeur Dispatch", "Fast-track assignment even in peak traffic"),
            const SizedBox(height: 14),
            _benefitRow(Icons.cancel_outlined, "Zero Cancellation Surcharge", "Flexible scheduling without penalties"),
            const SizedBox(height: 14),
            _benefitRow(Icons.verified_user_rounded, "Top Rated 5-Star Drivers Only", "Background-verified, uniformed chauffeurs"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text("Got It", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String title, String sub) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primary)),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  void _rateUs(BuildContext context) {
    double rating = 5;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Rate WE DRIVE', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('How was your chauffeur experience?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final selected = index < rating;
                      return IconButton(
                        onPressed: () => setModalState(() => rating = index + 1.0),
                        icon: Icon(selected ? Icons.star_rounded : Icons.star_border_rounded, color: gold, size: 34),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text('${rating.toInt()} / 5', style: const TextStyle(color: primary, fontSize: 17, fontWeight: FontWeight.bold)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(color: primary))),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: primary),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showMessage(context, 'Thank you for rating WE DRIVE ${rating.toInt()}/5.');
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _contactUs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 45, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 22),
                Container(width: 58, height: 58, decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.support_agent_rounded, color: primary, size: 32)),
                const SizedBox(height: 14),
                const Text('Contact WE DRIVE', style: TextStyle(color: primary, fontSize: 21, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Our chauffeur concierge desk is here to help you.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 22),
                _contactOption(
                  icon: Icons.phone_rounded,
                  title: 'Call Support',
                  subtitle: supportPhone,
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _callSupport(context);
                  },
                ),
                const SizedBox(height: 12),
                _contactOption(
                  icon: Icons.email_rounded,
                  title: 'Email Support',
                  subtitle: supportEmail,
                  color: primary,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _emailSupport(context);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _contactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await _auth.signOut();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      _showMessage(context, 'Unable to logout. Please try again.');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Logout', style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to logout from WE DRIVE?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(color: primary))),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = _userStream();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: background,
        elevation: 0,
        centerTitle: true,
        title: const Text('My Profile', style: TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: border, width: 1.2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: stream == null
                    ? _profileHeader(name: 'WE DRIVE Customer', phone: 'Not signed in', email: 'Email not added', memberType: 'Premium Member')
                    : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: stream,
                        builder: (context, snapshot) {
                          final User? user = _auth.currentUser;
                          if (user == null) {
                            return _profileHeader(name: 'WE DRIVE Customer', phone: 'Not signed in', email: 'Email not added', memberType: 'Premium Member');
                          }
                          final data = snapshot.data?.data() ?? <String, dynamic>{};
                          return _profileHeader(name: _getName(data, user), phone: _getPhone(data, user), email: _getEmail(data, user), memberType: _getMemberType(data));
                        },
                      ),
              ),
              const SizedBox(height: 20),

              _profileTile(
                icon: Icons.auto_awesome_rounded,
                title: 'Concierge',
                subtitle: 'Manage premium chauffeur preferences & signature service',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ConciergeScreen()));
                },
              ),

              _profileTile(
                icon: Icons.access_time_rounded,
                title: 'Ride History',
                subtitle: 'View all your completed & upcoming rides',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RideHistoryScreen()));
                },
              ),

              _profileTile(
                icon: Icons.credit_card_rounded,
                title: 'Payment Methods',
                subtitle: 'Manage cards, UPI & cash payments',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
                },
              ),

              _profileTile(
                icon: Icons.shield_rounded,
                title: 'Safety & Security',
                subtitle: 'Manage your safety, privacy & account security',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetySecurityScreen()));
                },
              ),

              _profileTile(
                icon: Icons.support_agent_rounded,
                title: 'Contact Us',
                subtitle: 'Get help from the WE DRIVE support team',
                onTap: () => _contactUs(context),
              ),

              _profileTile(
                icon: Icons.star_outline_rounded,
                title: 'Rate Us',
                subtitle: 'Share your experience with WE DRIVE',
                onTap: () => _rateUs(context),
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade200, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text('WE DRIVE v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader({
    required String name,
    required String phone,
    required String email,
    required String memberType,
  }) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(color: primary.withOpacity(0.08), shape: BoxShape.circle, border: Border.all(color: primary.withOpacity(0.18), width: 2)),
          child: const Icon(Icons.person_rounded, color: primary, size: 42),
        ),
        const SizedBox(height: 14),
        Text(name, textAlign: TextAlign.center, style: const TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text(phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(email, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _showMembershipPerks(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20), border: Border.all(color: gold, width: 1.2), boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.military_tech_rounded, color: gold, size: 18),
                const SizedBox(width: 6),
                Text(memberType, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded, color: gold, size: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: primary, size: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
