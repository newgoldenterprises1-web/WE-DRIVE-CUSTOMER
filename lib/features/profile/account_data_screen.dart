import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountDataScreen extends StatefulWidget {
  const AccountDataScreen({super.key});

  @override
  State<AccountDataScreen> createState() => _AccountDataScreenState();
}

class _AccountDataScreenState extends State<AccountDataScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FB);

  bool _clearSavedData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: primary,
        title: Text(
          "Account & Data",
          style: GoogleFonts.poppins(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --------------------------------------------------
              // HEADER
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
                      color: primary.withValues(alpha: .18),
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
                        Icons.manage_accounts_rounded,
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
                            "Manage Your Account",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Control your personal information and account data.",
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
              // ACCOUNT INFORMATION
              // --------------------------------------------------
              _sectionTitle("Account Information"),

              const SizedBox(height: 12),

              _dataTile(
                icon: Icons.person_outline_rounded,
                title: "Personal Information",
                subtitle: "Name, phone number and email",
                onTap: () {
                  _showPersonalInformation();
                },
              ),

              const SizedBox(height: 12),

              _dataTile(
                icon: Icons.history_rounded,
                title: "Ride Data",
                subtitle: "Your ride and booking information",
                onTap: () {
                  _showRideData();
                },
              ),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // YOUR DATA
              // --------------------------------------------------
              _sectionTitle("Your Data"),

              const SizedBox(height: 12),

              _dataTile(
                icon: Icons.download_rounded,
                title: "Download My Data",
                subtitle:
                    "Request a copy of your WE DRIVE account data",
                onTap: () {
                  _showDownloadDataDialog();
                },
              ),

              const SizedBox(height: 12),

              _dataTile(
                icon: Icons.cleaning_services_outlined,
                title: "Clear Saved Data",
                subtitle:
                    "Remove saved addresses and preferences",
                trailingWidget: Switch(
                  value: _clearSavedData,
                  activeThumbColor: gold,
                  activeTrackColor:
                      primary.withValues(alpha: .35),
                  onChanged: (value) {
                    if (value) {
                      _showClearDataConfirmation();
                    } else {
                      setState(() {
                        _clearSavedData = false;
                      });
                    }
                  },
                ),
                onTap: () {
                  if (!_clearSavedData) {
                    _showClearDataConfirmation();
                  }
                },
              ),

              const SizedBox(height: 24),

              // --------------------------------------------------
              // ACCOUNT ACTIONS
              // --------------------------------------------------
              _sectionTitle("Account Actions"),

              const SizedBox(height: 12),

              _dataTile(
                icon: Icons.pause_circle_outline_rounded,
                title: "Deactivate Account",
                subtitle:
                    "Temporarily deactivate your WE DRIVE account",
                onTap: () {
                  _showDeactivateDialog();
                },
              ),

              const SizedBox(height: 12),

              _dataTile(
                icon: Icons.delete_forever_outlined,
                title: "Delete Account",
                subtitle:
                    "Permanently delete your account and data",
                iconColor: Colors.red,
                titleColor: Colors.red,
                onTap: () {
                  _showDeleteAccountDialog();
                },
              ),

              const SizedBox(height: 26),

              // --------------------------------------------------
              // WARNING
              // --------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: .10),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 24,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Account deletion is permanent. Your account information and associated data may no longer be recoverable.",
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

              const SizedBox(height: 24),

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
                "Your data. Your control.",
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
  // DATA TILE
  // --------------------------------------------------
  Widget _dataTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
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
                color: (iconColor ?? primary)
                    .withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor ?? primary,
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
                      color: titleColor ?? primary,
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

            if (trailingWidget != null)
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
  // PERSONAL INFORMATION
  // --------------------------------------------------
  void _showPersonalInformation() {
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
                _dragHandle(),

                const SizedBox(height: 22),

                const Icon(
                  Icons.person_rounded,
                  color: primary,
                  size: 42,
                ),

                const SizedBox(height: 12),

                Text(
                  "Personal Information",
                  style: GoogleFonts.poppins(
                    color: primary,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                _infoRow(
                  Icons.person_outline,
                  "Name",
                  "Mohammed Shahed",
                ),

                const SizedBox(height: 10),

                _infoRow(
                  Icons.phone_outlined,
                  "Phone",
                  "+91 98765 43210",
                ),

                const SizedBox(height: 10),

                _infoRow(
                  Icons.email_outlined,
                  "Email",
                  "shahed@example.com",
                ),

                const SizedBox(height: 20),

                _primaryButton(
                  text: "Done",
                  onPressed: () {
                    Navigator.pop(sheetContext);
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
  // RIDE DATA
  // --------------------------------------------------
  void _showRideData() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Ride Data",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Your completed and upcoming ride information is associated with your WE DRIVE account.",
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
  // DOWNLOAD DATA
  // --------------------------------------------------
  void _showDownloadDataDialog() {
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
                Icons.download_rounded,
                color: primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Download My Data",
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
            "A data export request will be created for your WE DRIVE account.",
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
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                _showMessage(
                  "Data export request submitted.",
                );
              },
              child: const Text("Request"),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // CLEAR DATA
  // --------------------------------------------------
  void _showClearDataConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Clear Saved Data?",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "This will remove saved addresses and local app preferences. Your account and ride history will not be deleted.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: primary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                setState(() {
                  _clearSavedData = true;
                });

                _showMessage(
                  "Saved data cleared.",
                );
              },
              child: const Text("Clear"),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // DEACTIVATE ACCOUNT
  // --------------------------------------------------
  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Deactivate Account?",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Your account will be temporarily deactivated. You can reactivate it later.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: primary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                _showMessage(
                  "Account deactivation request submitted.",
                );
              },
              child: const Text("Deactivate"),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // DELETE ACCOUNT
  // --------------------------------------------------
  void _showDeleteAccountDialog() {
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
                Icons.delete_forever_rounded,
                color: Colors.red,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Delete Account?",
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "This action is permanent. Your account and associated data may be deleted and cannot be recovered.",
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
                "Cancel",
                style: TextStyle(color: primary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                _showMessage(
                  "Account deletion request submitted.",
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // INFO ROW
  // --------------------------------------------------
  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // DRAG HANDLE
  // --------------------------------------------------
  Widget _dragHandle() {
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
  // PRIMARY BUTTON
  // --------------------------------------------------
  Widget _primaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // MESSAGE
  // --------------------------------------------------
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}