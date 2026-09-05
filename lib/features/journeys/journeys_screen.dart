import 'package:flutter/material.dart';

import '../booking/trip_details_screen.dart';
import '../trip/trip_active_screen.dart';

class JourneysScreen extends StatefulWidget {
  const JourneysScreen({super.key});

  @override
  State<JourneysScreen> createState() => _JourneysScreenState();
}

class _JourneysScreenState extends State<JourneysScreen> {
  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);

  final List<Map<String, dynamic>> journeys = [
    {
      'bookingId': 'WD-LIVE-001',
      'status': 'LIVE',
      'statusColor': Colors.green,
      'chauffeur': 'Ahmed Khan',
      'vehicle': 'Mercedes C-Class',
      'pickup': 'Banjara Hills',
      'destination': 'Rajiv Gandhi Airport',
      'date': 'Today • 4:30 PM',
      'type': 'active',
    },
    {
      'bookingId': 'WD-UPCOMING-001',
      'status': 'UPCOMING',
      'statusColor': Colors.orange,
      'chauffeur': 'Salman Ali',
      'vehicle': 'BMW 5 Series',
      'pickup': 'Gachibowli',
      'destination': 'Hitech City',
      'date': 'Tomorrow • 10:00 AM',
      'type': 'upcoming',
    },
  ];

  // ==========================================================
  // ACTIVE JOURNEY
  // ==========================================================

  void _trackLiveJourney(
    Map<String, dynamic> journey,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripActiveScreen(
          bookingId:
              journey['bookingId']?.toString() ??
                  'WD-LIVE-001',
          pickupLocation:
              journey['pickup']?.toString() ??
                  'Pickup Location',
          dropLocation:
              journey['destination']?.toString() ??
                  'Destination',
        ),
      ),
    );
  }

  // ==========================================================
  // UPCOMING JOURNEY
  // ==========================================================

  void _viewJourneyDetails(
    Map<String, dynamic> journey,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripDetailsScreen(
          booking: {
            'bookingId':
                journey['bookingId']?.toString() ?? '',
            'pickupLocation':
                journey['pickup']?.toString() ?? '',
            'dropLocation':
                journey['destination']?.toString() ?? '',
            'serviceName':
                journey['vehicle']?.toString() ??
                    'Chauffeur Service',
            'chauffeurName':
                journey['chauffeur']?.toString() ??
                    'Chauffeur',
            'date':
                journey['date']?.toString() ?? '',
            'status':
                journey['status']?.toString() ?? '',
          },
        ),
      ),
    );
  }

  // ==========================================================
  // JOURNEY ACTION
  // ==========================================================

  void _handleJourneyTap(
    Map<String, dynamic> journey,
  ) {
    if (journey['type'] == 'active') {
      _trackLiveJourney(journey);
    } else {
      _viewJourneyDetails(journey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeJourneys = journeys
        .where(
          (journey) =>
              journey['type'] == 'active',
        )
        .toList();

    final upcomingJourneys = journeys
        .where(
          (journey) =>
              journey['type'] == 'upcoming',
        )
        .toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "My Journeys",
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),

      body: RefreshIndicator(
        color: primary,
        onRefresh: () async {
          await Future.delayed(
            const Duration(milliseconds: 500),
          );

          if (mounted) {
            setState(() {});
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ==================================================
            // SUMMARY
            // ==================================================

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF173B6D),
                    Color(0xFF2563EB),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(
                      alpha: .18,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "${journeys.length} Active Journeys",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Track your active and upcoming chauffeur bookings in one place.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryItem(
                          "Active",
                          activeJourneys
                              .length
                              .toString(),
                          Icons
                              .directions_car_rounded,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _summaryItem(
                          "Upcoming",
                          upcomingJourneys
                              .length
                              .toString(),
                          Icons
                              .schedule_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // ACTIVE JOURNEYS
            // ==================================================

            if (activeJourneys.isNotEmpty) ...[
              const Text(
                "Active Journey",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),

              const SizedBox(height: 16),

              ...activeJourneys.map(
                (journey) => Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 22,
                  ),
                  child:
                      _journeyCard(journey),
                ),
              ),
            ],

            // ==================================================
            // UPCOMING JOURNEYS
            // ==================================================

            if (upcomingJourneys.isNotEmpty) ...[
              const Text(
                "Upcoming",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),

              const SizedBox(height: 16),

              ...upcomingJourneys.map(
                (journey) => Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 22,
                  ),
                  child:
                      _journeyCard(journey),
                ),
              ),
            ],

            // ==================================================
            // EMPTY STATE
            // ==================================================

            if (activeJourneys.isEmpty &&
                upcomingJourneys.isEmpty)
              _emptyJourneyState(),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SUMMARY ITEM
  // ==========================================================

  Widget _summaryItem(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: .12,
        ),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: gold,
            size: 23,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
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
  // JOURNEY CARD
  // ==========================================================

  Widget _journeyCard(
    Map<String, dynamic> journey,
  ) {
    final Color statusColor =
        journey['statusColor'] as Color;

    final bool isActive =
        journey['type'] == 'active';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: .06,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==================================================
          // STATUS + DATE
          // ==================================================

          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(
                    alpha: .15,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  journey['status']
                      .toString(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.calendar_today_rounded,
                size: 17,
                color: primary,
              ),

              const SizedBox(width: 6),

              Flexible(
                child: Text(
                  journey['date']
                      .toString(),
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ==================================================
          // CHAUFFEUR
          // ==================================================

          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEAF2FF),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: primary,
                  size: 32,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey['chauffeur']
                          .toString(),
                      style:
                          const TextStyle(
                        color: primary,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      journey['vehicle']
                          .toString(),
                      style:
                          const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green
                        .withValues(
                      alpha: .10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          // ==================================================
          // ROUTE
          // ==================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(
                    Icons
                        .radio_button_checked,
                    color: Colors.green,
                    size: 18,
                  ),

                  Container(
                    height: 22,
                    width: 2,
                    color:
                        Colors.grey.shade300,
                  ),

                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                ],
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey['pickup']
                          .toString(),
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      journey['destination']
                          .toString(),
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),

          const SizedBox(height: 18),

          // ==================================================
          // ACTION BUTTON
          // ==================================================

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor:
                    Colors.white,
                elevation: 2,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              onPressed: () {
                _handleJourneyTap(
                  journey,
                );
              },
              icon: Icon(
                isActive
                    ? Icons
                        .my_location_rounded
                    : Icons
                        .arrow_forward_rounded,
              ),
              label: Text(
                isActive
                    ? "Track Live"
                    : "View Details",
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _emptyJourneyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.route_rounded,
            color: primary,
            size: 60,
          ),

          SizedBox(height: 16),

          Text(
            "No Active Journeys",
            style: TextStyle(
              color: primary,
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 8),

          Text(
            "Your active and upcoming chauffeur bookings will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}