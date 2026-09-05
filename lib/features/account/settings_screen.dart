import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color background = Color(0xFFF5F7FB);

  bool notifications = true;
  bool biometric = false;

  String selectedLanguage = "English";

  // ==========================================================
  // LANGUAGE
  // ==========================================================

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Select Language",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption(dialogContext, "English"),
              _languageOption(dialogContext, "Hindi"),
              _languageOption(dialogContext, "Telugu"),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption(
    BuildContext dialogContext,
    String language,
  ) {
    final isSelected = selectedLanguage == language;

    return ListTile(
      leading: Icon(
        isSelected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_off_rounded,
        color: isSelected ? primary : Colors.grey,
      ),
      title: Text(
        language,
        style: TextStyle(
          color: isSelected ? primary : Colors.black87,
          fontWeight:
              isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });

        Navigator.pop(dialogContext);

        _showMessage("$language selected");
      },
    );
  }

  // ==========================================================
  // HELP & SUPPORT
  // ==========================================================

  void _showHelpSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
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
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: primary,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  "WE DRIVE Support",
                  style: TextStyle(
                    color: primary,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "How can we help you?",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 22),

                _supportOption(
                  Icons.phone_rounded,
                  "Call Support",
                  "+91 98765 43210",
                  _callSupport,
                ),

                const SizedBox(height: 12),

                _supportOption(
                  Icons.email_rounded,
                  "Email Support",
                  "support@wedrive.com",
                  _emailSupport,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _supportOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: primary,
              ),
            ),

            const SizedBox(width: 14),

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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
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

  // ==========================================================
  // CALL SUPPORT
  // ==========================================================

  Future<void> _callSupport() async {
    final uri = Uri.parse("tel:+919876543210");

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage("Unable to open phone dialer.");
      }
    } catch (_) {
      _showMessage("Unable to open phone dialer.");
    }
  }

  // ==========================================================
  // EMAIL SUPPORT
  // ==========================================================

  Future<void> _emailSupport() async {
    final uri = Uri(
      scheme: "mailto",
      path: "support@wedrive.com",
      queryParameters: {
        "subject": "WE DRIVE Customer Support",
      },
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage("No email application found.");
      }
    } catch (_) {
      _showMessage("Unable to open email application.");
    }
  }

  // ==========================================================
  // PRIVACY POLICY
  // ==========================================================

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  // ==========================================================
  // TERMS
  // ==========================================================

  void _openTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TermsConditionsScreen(),
      ),
    );
  }

  // ==========================================================
  // ABOUT
  // ==========================================================

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutScreen(),
      ),
    );
  }

  // ==========================================================
  // SAVE SETTINGS
  // ==========================================================

  void _saveSettings() {
    _showMessage("Settings saved successfully");
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          4,
          20,
          30,
        ),
        children: [
          // ==================================================
          // NOTIFICATIONS
          // ==================================================

          _switchTile(
            icon: Icons.notifications_rounded,
            title: "Notifications",
            value: notifications,
            onChanged: (value) {
              setState(() {
                notifications = value;
              });

              _showMessage(
                value
                    ? "Notifications enabled"
                    : "Notifications disabled",
              );
            },
          ),

          // ==================================================
          // BIOMETRIC LOGIN
          // ==================================================

          _switchTile(
            icon: Icons.fingerprint_rounded,
            title: "Biometric Login",
            value: biometric,
            onChanged: (value) {
              setState(() {
                biometric = value;
              });

              _showMessage(
                value
                    ? "Biometric Login enabled"
                    : "Biometric Login disabled",
              );
            },
          ),

          const SizedBox(height: 12),

          // ==================================================
          // LANGUAGE
          // ==================================================

          _menuTile(
            icon: Icons.language_rounded,
            title: "Language",
            subtitle: selectedLanguage,
            onTap: _showLanguageDialog,
          ),

          // ==================================================
          // PRIVACY POLICY
          // ==================================================

          _menuTile(
            icon: Icons.lock_outline_rounded,
            title: "Privacy Policy",
            onTap: _openPrivacyPolicy,
          ),

          // ==================================================
          // TERMS & CONDITIONS
          // ==================================================

          _menuTile(
            icon: Icons.description_outlined,
            title: "Terms & Conditions",
            onTap: _openTerms,
          ),

          // ==================================================
          // ABOUT
          // ==================================================

          _menuTile(
            icon: Icons.info_outline_rounded,
            title: "About WE DRIVE",
            onTap: _openAbout,
          ),

          // ==================================================
          // HELP & SUPPORT
          // ==================================================

          _menuTile(
            icon: Icons.help_outline_rounded,
            title: "Help & Support",
            onTap: _showHelpSupport,
          ),

          const SizedBox(height: 24),

          // ==================================================
          // SAVE SETTINGS
          // ==================================================

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              onPressed: _saveSettings,
              icon: const Icon(
                Icons.save_rounded,
              ),
              label: const Text(
                "SAVE SETTINGS",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ==================================================
          // VERSION
          // ==================================================

          const Center(
            child: Text(
              "WE DRIVE v1.0.0",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SWITCH TILE
  // ==========================================================

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 4,
        ),
        secondary: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        value: value,
        activeThumbColor: primary,
        activeTrackColor: primary.withValues(alpha: .35),
        onChanged: onChanged,
      ),
    );
  }

  // ==========================================================
  // MENU TILE
  // ==========================================================

  Widget _menuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 5,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}