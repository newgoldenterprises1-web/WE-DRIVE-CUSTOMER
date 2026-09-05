import 'package:flutter/material.dart';

import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'wallet_screen.dart';
import 'payment_methods_screen.dart';
import 'saved_addresses_screen.dart';
import 'executive_support_screen.dart';
import 'refer_earn_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import 'about_screen.dart';
import '../fleet/fleet_screen.dart';
import '../journeys/journeys_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "My Account",
          style: TextStyle(
            color: primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ========================================================
          // PROFILE HEADER
          // ========================================================

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF173B6D),
                  Color(0xFF2563EB),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [

                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: primary,
                    size: 34,
                  ),
                ),

                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Mohd Shahed",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "Premium Member",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.verified,
                  color: gold,
                  size: 28,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ========================================================
          // ACCOUNT OPTIONS
          // ========================================================

          accountTile(
            Icons.edit,
            "Edit Profile",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const EditProfileScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.directions_car,
            "My Vehicles",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const FleetScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.route,
            "My Journeys",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const JourneysScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.location_on,
            "Saved Addresses",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SavedAddressesScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.account_balance_wallet,
            "Wallet",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const WalletScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.payment,
            "Payment Methods",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PaymentMethodsScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.support_agent,
            "Executive Support",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ExecutiveSupportScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.settings,
            "Settings",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SettingsScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.card_giftcard,
            "Refer & Earn",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ReferEarnScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.info_outline,
            "About Us",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AboutScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.privacy_tip_outlined,
            "Privacy Policy",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          accountTile(
            Icons.description_outlined,
            "Terms & Conditions",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const TermsConditionsScreen(),
                ),
              );
            },
          ),

          // ========================================================
          // CONTACT US
          // ========================================================

          accountTile(
            Icons.contact_support_rounded,
            "Contact Us",
            () {
              _showContactUs(context);
            },
          ),

          // ========================================================
          // RATE US
          // ========================================================

          accountTile(
            Icons.star_rate_rounded,
            "Rate Us",
            () {
              _showRateUs(context);
            },
          ),

          const SizedBox(height: 10),

          // ========================================================
          // LOGOUT
          // ========================================================

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(
                Icons.logout,
              ),
              label: const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ========================================================
          // VERSION
          // ========================================================

          const Center(
            child: Text(
              "WE DRIVE v1.0.0",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ==============================================================
  // CONTACT US
  // ==============================================================

  void _showContactUs(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              30,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Handle

                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                const Icon(
                  Icons.support_agent_rounded,
                  color: primary,
                  size: 46,
                ),

                const SizedBox(height: 12),

                const Text(
                  "Contact WE DRIVE",
                  style: TextStyle(
                    color: primary,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Our support team is here to help you.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 22),

                // Call Support

                _contactOption(
                  icon: Icons.phone_rounded,
                  title: "Call Support",
                  subtitle:
                      "Speak with WE DRIVE support",
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _showMessage(
                      context,
                      "Support calling will be connected here.",
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Email Support

                _contactOption(
                  icon: Icons.email_rounded,
                  title: "Email Support",
                  subtitle:
                      "Send us your query",
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _showMessage(
                      context,
                      "Email support will be connected here.",
                    );
                  },
                ),

                const SizedBox(height: 10),

                // Executive Support

                _contactOption(
                  icon: Icons.support_agent_rounded,
                  title: "Executive Support",
                  subtitle:
                      "Get assistance from our support team",
                  onTap: () {
                    Navigator.pop(sheetContext);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ExecutiveSupportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==============================================================
  // CONTACT OPTION
  // ==============================================================

  Widget _contactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [

            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .08),
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // RATE US
  // ==============================================================

  void _showRateUs(BuildContext context) {
    double rating = 5;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(24),
              ),
              title: const Text(
                "Rate WE DRIVE",
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "How would you rate your WE DRIVE experience?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) {
                        final selected =
                            index < rating;

                        return IconButton(
                          onPressed: () {
                            setDialogState(() {
                              rating =
                                  index + 1;
                            });
                          },
                          icon: Icon(
                            selected
                                ? Icons.star_rounded
                                : Icons
                                    .star_border_rounded,
                            color: gold,
                            size: 34,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "${rating.toInt()} / 5",
                    style: const TextStyle(
                      color: primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: primary,
                    ),
                  ),
                ),

                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );

                    _showMessage(
                      context,
                      "Thank you for rating WE DRIVE ${rating.toInt()}/5!",
                    );
                  },
                  child: const Text(
                    "Submit",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==============================================================
  // LOGOUT DIALOG
  // ==============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          title: const Row(
            children: [

              Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),

              SizedBox(width: 10),

              Text(
                "Logout",
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to logout?",
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: primary,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                _showMessage(
                  context,
                  "Logged out successfully",
                );
              },
              child: const Text(
                "Logout",
              ),
            ),
          ],
        );
      },
    );
  }

  // ==============================================================
  // MESSAGE
  // ==============================================================

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  // ==============================================================
  // ACCOUNT TILE
  // ==============================================================

  Widget accountTile(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(
          radius: 22,
          backgroundColor:
              primary.withValues(alpha: .10),
          child: Icon(
            icon,
            color: primary,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}