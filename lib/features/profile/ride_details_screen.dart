import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class RideDetailsScreen extends StatelessWidget {
  const RideDetailsScreen({
    super.key,
    required this.ride,
  });

  final Map<String, dynamic> ride;

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FB);

  // ==========================================================
  // CALL DRIVER
  // ONLY AVAILABLE FOR UPCOMING TRIPS
  // ==========================================================

  Future<void> _callDriver(BuildContext context) async {
    final uri = Uri.parse('tel:+919876543210');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      _message(
        context,
        'Unable to open phone dialer.',
      );
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _message(
    BuildContext context,
    String message,
  ) {
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
  // RATE DRIVER
  // ONLY COMPLETED
  // ==========================================================

  void _rateDriver(BuildContext context) {
    double rating = 5;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Rate Driver',
                style: GoogleFonts.poppins(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ride['driver']?.toString() ??
                        'Driver',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: primary,
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
                            setState(() {
                              rating = index + 1;
                            });
                          },
                          icon: Icon(
                            selected
                                ? Icons.star
                                : Icons.star_border,
                            color: gold,
                            size: 34,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
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
                    Navigator.pop(dialogContext);

                    _message(
                      context,
                      'Thank you! You rated the driver ${rating.toInt()}/5.',
                    );
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

  // ==========================================================
  // DOWNLOAD INVOICE
  // ONLY COMPLETED
  // ==========================================================

  void _downloadInvoice(BuildContext context) {
    _message(
      context,
      'Invoice generation started.',
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final status =
        ride['status']?.toString() ?? '';

    // IMPORTANT:
    // Call Driver -> ONLY Upcoming
    final isUpcoming =
        status == 'Upcoming';

    // Rate + Invoice -> ONLY Completed
    final isCompleted =
        status == 'Completed';

    // Cancelled -> No Call / No Rate / No Invoice
    final isCancelled =
        status == 'Cancelled';

    return Scaffold(
      backgroundColor: background,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Ride Details",
          style: GoogleFonts.poppins(
            color: primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ==================================================
            // DRIVER CARD
            // ==================================================

            _driverCard(
              context,
              isUpcoming: isUpcoming,
              isCancelled: isCancelled,
            ),

            const SizedBox(height: 24),

            // ==================================================
            // VEHICLE CARD
            // ==================================================

            _vehicleCard(),

            const SizedBox(height: 24),

            // ==================================================
            // FARE CARD
            // ==================================================

            _fareCard(),

            const SizedBox(height: 24),

            // ==================================================
            // COMPLETED ONLY
            // RATE DRIVER
            // ==================================================

            if (isCompleted)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _rateDriver(context),
                  icon: const Icon(
                    Icons.star,
                  ),
                  label: Text(
                    "Rate Driver",
                    style: GoogleFonts.poppins(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),
              ),

            // ==================================================
            // COMPLETED ONLY
            // DOWNLOAD INVOICE
            // ==================================================

            if (isCompleted)
              const SizedBox(height: 14),

            if (isCompleted)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _downloadInvoice(
                    context,
                  ),
                  icon: const Icon(
                    Icons.receipt_long,
                  ),
                  label: Text(
                    "Download Invoice",
                    style: GoogleFonts.poppins(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(
                      color: primary,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DRIVER CARD
  // ==========================================================

  Widget _driverCard(
    BuildContext context, {
    required bool isUpcoming,
    required bool isCancelled,
  }) {
    return _card(
      child: Row(
        children: [

          const CircleAvatar(
            radius: 34,
            backgroundColor:
                Color(0xFFEAF3FF),
            child: Icon(
              Icons.person,
              color: primary,
              size: 36,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  ride['driver']?.toString() ??
                      'Driver',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color: primary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  isCancelled
                      ? 'Driver was not assigned'
                      : isUpcoming
                          ? 'Professional Driver'
                          : 'Trip Driver',
                  style: GoogleFonts.poppins(
                    color:
                        Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),

                // Rating for Upcoming +
                // Completed
                if (!isCancelled) ...[
                  const SizedBox(height: 8),

                  Row(
                    children: [

                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '${ride['rating']} Rating',
                        style:
                            GoogleFonts.poppins(
                          fontWeight:
                              FontWeight.w600,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ==================================================
          // CALL BUTTON
          //
          // IMPORTANT:
          // ONLY UPCOMING
          // ==================================================

          if (isUpcoming)
            IconButton(
              tooltip: 'Call Driver',
              onPressed: () =>
                  _callDriver(context),
              icon: const Icon(
                Icons.call,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // VEHICLE CARD
  // ==========================================================

  Widget _vehicleCard() {
    return _card(
      child: Column(
        children: [

          Row(
            children: [
              const Icon(
                Icons.directions_car_rounded,
                color: primary,
              ),

              const SizedBox(width: 10),

              Text(
                "Vehicle Details",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ListTile(
            contentPadding:
                EdgeInsets.zero,

            leading:
                const CircleAvatar(
              backgroundColor:
                  Color(0xFFEAF3FF),
              child: Icon(
                Icons.directions_car,
                color: primary,
              ),
            ),

            title: Text(
              ride['vehicle']?.toString() ??
                  'Vehicle',
              style: GoogleFonts.poppins(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            subtitle: Text(
              ride['number']?.toString() ??
                  '',
              style:
                  GoogleFonts.poppins(),
            ),
          ),

          const Divider(height: 30),

          _locationRow(
            Icons.radio_button_checked,
            Colors.green,
            ride['pickup']?.toString() ??
                '',
          ),

          const SizedBox(height: 18),

          _locationRow(
            Icons.location_on,
            Colors.red,
            ride['drop']?.toString() ??
                '',
          ),

          const SizedBox(height: 22),

          Row(
            children: [

              const Icon(
                Icons.calendar_month,
                color: gold,
              ),

              const SizedBox(width: 8),

              Text(
                ride['date']?.toString() ??
                    '',
                style: GoogleFonts.poppins(
                  color:
                      Colors.grey.shade700,
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.access_time,
                color: gold,
              ),

              const SizedBox(width: 8),

              Text(
                ride['time']?.toString() ??
                    '',
                style: GoogleFonts.poppins(
                  color:
                      Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FARE CARD
  // ==========================================================

  Widget _fareCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            "Fare Details",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
              color: primary,
            ),
          ),

          const SizedBox(height: 18),

          _fareRow(
            "Trip Fare",
            ride['tripFare']?.toString() ??
                '₹0',
          ),

          _fareRow(
            "Driver Allowance",
            ride['allowance']?.toString() ??
                '₹0',
          ),

          _fareRow(
            "Platform Fee",
            ride['platformFee']?.toString() ??
                '₹0',
          ),

          const Divider(height: 30),

          _fareRow(
            "Total Paid",
            ride['fare']?.toString() ??
                '₹0',
            isTotal: true,
          ),

          const SizedBox(height: 22),

          Row(
            children: [

              const Icon(
                Icons.account_balance_wallet,
                color: gold,
              ),

              const SizedBox(width: 10),

              Text(
                "Payment : ${ride['payment']?.toString() ?? 'N/A'}",
                style: GoogleFonts.poppins(
                  fontWeight:
                      FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ==================================================
          // ROUTE MAP
          // ==================================================

          Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFEAF3FF),
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.map,
                  size: 50,
                  color: primary,
                ),

                const SizedBox(height: 12),

                Text(
                  "Route Map",
                  style: GoogleFonts.poppins(
                    fontWeight:
                        FontWeight.bold,
                    color: primary,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${ride['pickup'] ?? ''} → ${ride['drop'] ?? ''}",
                  textAlign:
                      TextAlign.center,
                  style: GoogleFonts.poppins(
                    color:
                        Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOCATION ROW
  // ==========================================================

  Widget _locationRow(
    IconData icon,
    Color color,
    String text,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          color: color,
          size: 20,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight:
                  FontWeight.w600,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FARE ROW
  // ==========================================================

  Widget _fareRow(
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [

          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize:
                  isTotal ? 16 : 14,
              fontWeight: isTotal
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: primary,
            ),
          ),

          const Spacer(),

          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize:
                  isTotal ? 18 : 15,
              fontWeight: isTotal
                  ? FontWeight.bold
                  : FontWeight.w600,
              color:
                  isTotal ? gold : primary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // COMMON CARD
  // ==========================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}