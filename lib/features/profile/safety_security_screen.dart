import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SafetySecurityScreen extends StatefulWidget {
  const SafetySecurityScreen({super.key});

  @override
  State<SafetySecurityScreen> createState() =>
      _SafetySecurityScreenState();
}

class _SafetySecurityScreenState
    extends State<SafetySecurityScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FB);

  bool biometricEnabled = true;
  bool locationSharingEnabled = true;
  bool tripDataEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // --------------------------------------------------
      // APP BAR
      // --------------------------------------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: primary,
        title: Text(
          "Safety & Security",
          style: GoogleFonts.poppins(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // --------------------------------------------------
      // BODY
      // --------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              // --------------------------------------------------
              // SECURITY HEADER
              // --------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF173B6D),
                      Color(0xFF295FA7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: .20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: gold,
                        size: 32,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Safety Matters",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Manage your safety and account security.",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // --------------------------------------------------
              // ACCOUNT SECURITY
              // --------------------------------------------------
              _sectionTitle("Account Security"),

              const SizedBox(height: 12),

              _securityTile(
                icon: Icons.phone_android_rounded,
                title: "Phone Number",
                subtitle: "+91 98765 43210",
                trailing: "Verified",
                trailingColor: Colors.green,
                onTap: () {
                  _showMessage(
                    "Your phone number is verified.",
                  );
                },
              ),

              const SizedBox(height: 12),

              _securityTile(
                icon: Icons.lock_outline_rounded,
                title: "Login Security",
                subtitle:
                    "Manage your account login security",
                trailing: "Secure",
                trailingColor: Colors.green,
                onTap: _showLoginSecurity,
              ),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // SAFETY
              // --------------------------------------------------
              _sectionTitle("Safety"),

              const SizedBox(height: 12),

              _securityTile(
                icon: Icons.emergency_rounded,
                title: "Emergency Assistance",
                subtitle:
                    "Get help during an active trip",
                onTap: _showEmergencyDialog,
              ),

              const SizedBox(height: 12),

              _securityTile(
                icon: Icons.share_location_rounded,
                title: "Trip Safety",
                subtitle:
                    "Safety features for your active trip",
                onTap: () {
                  _showTripSafety();
                },
              ),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // PRIVACY
              // --------------------------------------------------
              _sectionTitle("Privacy & Data"),

              const SizedBox(height: 12),

              _securityTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy Settings",
                subtitle:
                    "Manage your privacy preferences",
                onTap: _showPrivacySettings,
              ),

              const SizedBox(height: 12),

              _securityTile(
                icon: Icons.delete_outline_rounded,
                title: "Account & Data",
                subtitle:
                    "Manage your account data",
                onTap: _showAccountData,
              ),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // APP SECURITY
              // --------------------------------------------------
              _sectionTitle("App Security"),

              const SizedBox(height: 12),

              _securityTile(
                icon: Icons.fingerprint_rounded,
                title: "Biometric Security",
                subtitle:
                    biometricEnabled
                        ? "Fingerprint or face unlock is enabled"
                        : "Fingerprint or face unlock is disabled",
                trailingWidget: Switch(
                  value: biometricEnabled,
                  activeThumbColor: gold,
                  activeTrackColor:
                      primary.withValues(alpha: .35),
                  onChanged: (value) {
                    setState(() {
                      biometricEnabled = value;
                    });

                    _showMessage(
                      value
                          ? "Biometric security enabled."
                          : "Biometric security disabled.",
                    );
                  },
                ),
                onTap: () {
                  setState(() {
                    biometricEnabled = !biometricEnabled;
                  });

                  _showMessage(
                    biometricEnabled
                        ? "Biometric security enabled."
                        : "Biometric security disabled.",
                  );
                },
              ),

              const SizedBox(height: 12),

              _securityTile(
                icon: Icons.devices_rounded,
                title: "Logged-in Devices",
                subtitle:
                    "Review devices using your account",
                onTap: _showDevicesDialog,
              ),

              const SizedBox(height: 26),

              // --------------------------------------------------
              // INFORMATION
              // --------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primary.withValues(alpha: .06),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: primary,
                      size: 24,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "WE DRIVE will never ask you to share your password, OTP or other sensitive account information.",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade700,
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "WE DRIVE",
                style: GoogleFonts.poppins(
                  color: primary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "Your safety. Your security. Our priority.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 11.5,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SECTION TITLE
  // --------------------------------------------------
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          color: primary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SECURITY TILE
  // --------------------------------------------------
  Widget _securityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? trailing,
    Color? trailingColor,
    Widget? trailingWidget,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .035),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: primary,
                size: 24,
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
                    style: GoogleFonts.poppins(
                      color: primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (trailingColor ?? primary)
                      .withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trailing,
                  style: GoogleFonts.poppins(
                    color: trailingColor ?? primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else if (trailingWidget != null)
              trailingWidget
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // LOGIN SECURITY
  // --------------------------------------------------
  void _showLoginSecurity() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              22,
              18,
              22,
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
                _handle(),

                const SizedBox(height: 22),

                const Icon(
                  Icons.lock_rounded,
                  color: primary,
                  size: 42,
                ),

                const SizedBox(height: 12),

                Text(
                  "Login Security",
                  style: GoogleFonts.poppins(
                    color: primary,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Your account is protected with secure login verification.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                _bottomOption(
                  icon: Icons.password_rounded,
                  title: "Change Password",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showMessage(
                      "Password change will be connected later.",
                    );
                  },
                ),

                const SizedBox(height: 10),

                _bottomOption(
                  icon: Icons.verified_user_rounded,
                  title: "OTP Verification",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showMessage(
                      "OTP verification is active for secure login.",
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

  // --------------------------------------------------
  // TRIP SAFETY
  // --------------------------------------------------
  void _showTripSafety() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              22,
              18,
              22,
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
                _handle(),

                const SizedBox(height: 20),

                const Icon(
                  Icons.shield_rounded,
                  color: primary,
                  size: 44,
                ),

                const SizedBox(height: 12),

                Text(
                  "Trip Safety",
                  style: GoogleFonts.poppins(
                    color: primary,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Safety tools become available when you have an active trip.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                _bottomOption(
                  icon: Icons.share_location_rounded,
                  title: "Share Trip Status",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showMessage(
                      "Trip sharing will be available during an active trip.",
                    );
                  },
                ),

                const SizedBox(height: 10),

                _bottomOption(
                  icon: Icons.emergency_rounded,
                  title: "Emergency Assistance",
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showEmergencyDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // PRIVACY SETTINGS
  // --------------------------------------------------
  void _showPrivacySettings() {
    bool tempLocation = locationSharingEnabled;
    bool tempTripData = tripDataEnabled;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  24,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _handle(),

                      const SizedBox(height: 20),

                      const Icon(
                        Icons.privacy_tip_rounded,
                        color: primary,
                        size: 44,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Privacy Settings",
                        style: GoogleFonts.poppins(
                          color: primary,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Control how your information is used inside WE DRIVE.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _privacySwitch(
                        icon: Icons.location_on_rounded,
                        title: "Location Sharing",
                        subtitle:
                            "Allow location access for trip-related features.",
                        value: tempLocation,
                        onChanged: (value) {
                          setSheetState(() {
                            tempLocation = value;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      _privacySwitch(
                        icon: Icons.route_rounded,
                        title: "Trip Data",
                        subtitle:
                            "Allow trip information to be used for service improvement.",
                        value: tempTripData,
                        onChanged: (value) {
                          setSheetState(() {
                            tempTripData = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              locationSharingEnabled =
                                  tempLocation;
                              tripDataEnabled =
                                  tempTripData;
                            });

                            Navigator.pop(sheetContext);

                            _showMessage(
                              "Privacy preferences saved.",
                            );
                          },
                          child: const Text(
                            "Save Preferences",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --------------------------------------------------
  // PRIVACY SWITCH
  // --------------------------------------------------
  Widget _privacySwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              borderRadius: BorderRadius.circular(13),
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
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            activeThumbColor: gold,
            activeTrackColor:
                primary.withValues(alpha: .35),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
// ACCOUNT DATA
// --------------------------------------------------
void _showAccountData() {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          "Account & Data",
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Your account information, ride history and saved preferences are associated with your WE DRIVE account. Data management options will be connected here later.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text(
              "Done",
              style: TextStyle(color: primary),
            ),
          ),
        ],
      );
    },
  );
}

  // --------------------------------------------------
  // EMERGENCY
  // --------------------------------------------------
  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.emergency_rounded,
                color: Colors.red,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Emergency Assistance",
                  style: GoogleFonts.poppins(
                    color: primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "Emergency assistance will be available during an active trip.",
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Close",
                style: TextStyle(color: primary),
              ),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // DEVICES
  // --------------------------------------------------
  void _showDevicesDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Logged-in Devices",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.phone_android_rounded,
              color: primary,
            ),
            title: Text(
              "This Device",
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "Currently active",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Close",
                style: TextStyle(color: primary),
              ),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // BOTTOM OPTION
  // --------------------------------------------------
  Widget _bottomOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primary,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
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

  // --------------------------------------------------
  // BOTTOM SHEET HANDLE
  // --------------------------------------------------
  Widget _handle() {
    return Container(
      width: 45,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // --------------------------------------------------
  // MESSAGE
  // --------------------------------------------------
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}