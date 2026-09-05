import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ride_details_screen.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  static const Color primary = Color(0xFF173B6D);
  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFF5F7FB);

  final List<Map<String, dynamic>> rides = const [
    {
      'status': 'Upcoming',
      'pickup': 'Hitech City, Hyderabad',
      'drop': 'Rajiv Gandhi International Airport',
      'date': '28 Aug 2026',
      'time': '09:30 AM',
      'fare': '₹450',
      'driver': 'Mohammed Arif',
      'rating': '4.9',
      'vehicle': 'Hyundai Verna',
      'number': 'TS09 AB 1234',
      'payment': 'UPI',
      'tripFare': '₹400',
      'allowance': '₹30',
      'platformFee': '₹20',
    },
    {
      'status': 'Upcoming',
      'pickup': 'Banjara Hills, Hyderabad',
      'drop': 'Gachibowli, Hyderabad',
      'date': '30 Aug 2026',
      'time': '07:00 PM',
      'fare': '₹380',
      'driver': 'Ahmed Khan',
      'rating': '4.8',
      'vehicle': 'Honda City',
      'number': 'TS10 CD 5678',
      'payment': 'UPI',
      'tripFare': '₹340',
      'allowance': '₹20',
      'platformFee': '₹20',
    },
    {
      'status': 'Completed',
      'pickup': 'Hitech City, Hyderabad',
      'drop': 'Rajiv Gandhi International Airport',
      'date': '28 Jul 2026',
      'time': '09:30 AM',
      'fare': '₹450',
      'driver': 'Mohammed Arif',
      'rating': '4.9',
      'vehicle': 'Hyundai Verna',
      'number': 'TS09 AB 1234',
      'payment': 'UPI',
      'tripFare': '₹400',
      'allowance': '₹30',
      'platformFee': '₹20',
    },
    {
      'status': 'Completed',
      'pickup': 'Kukatpally, Hyderabad',
      'drop': 'Banjara Hills, Hyderabad',
      'date': '21 Jul 2026',
      'time': '06:45 PM',
      'fare': '₹320',
      'driver': 'Sohail Ahmed',
      'rating': '4.7',
      'vehicle': 'Maruti Ciaz',
      'number': 'TS08 EF 9012',
      'payment': 'Card',
      'tripFare': '₹280',
      'allowance': '₹20',
      'platformFee': '₹20',
    },
    {
      'status': 'Cancelled',
      'pickup': 'Madhapur, Hyderabad',
      'drop': 'Secunderabad',
      'date': '18 Jul 2026',
      'time': '08:00 PM',
      'fare': '₹400',
      'driver': 'Not Assigned',
      'rating': '0',
      'vehicle': 'Not Assigned',
      'number': '-',
      'payment': 'UPI',
      'tripFare': '₹360',
      'allowance': '₹20',
      'platformFee': '₹20',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Ride History",
            style: GoogleFonts.poppins(
              color: primary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          bottom: TabBar(
            indicatorColor: gold,
            indicatorWeight: 3,
            labelColor: primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RideTab(status: 'Upcoming'),
            _RideTab(status: 'Completed'),
            _RideTab(status: 'Cancelled'),
          ],
        ),
      ),
    );
  }
}

class _RideTab extends StatelessWidget {
  const _RideTab({
    required this.status,
  });

  final String status;

  List<Map<String, dynamic>> get rides {
    const allRides = [
      {
        'status': 'Upcoming',
        'pickup': 'Hitech City, Hyderabad',
        'drop': 'Rajiv Gandhi International Airport',
        'date': '28 Aug 2026',
        'time': '09:30 AM',
        'fare': '₹450',
        'driver': 'Mohammed Arif',
        'rating': '4.9',
        'vehicle': 'Hyundai Verna',
        'number': 'TS09 AB 1234',
        'payment': 'UPI',
        'tripFare': '₹400',
        'allowance': '₹30',
        'platformFee': '₹20',
      },
      {
        'status': 'Upcoming',
        'pickup': 'Banjara Hills, Hyderabad',
        'drop': 'Gachibowli, Hyderabad',
        'date': '30 Aug 2026',
        'time': '07:00 PM',
        'fare': '₹380',
        'driver': 'Ahmed Khan',
        'rating': '4.8',
        'vehicle': 'Honda City',
        'number': 'TS10 CD 5678',
        'payment': 'UPI',
        'tripFare': '₹340',
        'allowance': '₹20',
        'platformFee': '₹20',
      },
      {
        'status': 'Completed',
        'pickup': 'Hitech City, Hyderabad',
        'drop': 'Rajiv Gandhi International Airport',
        'date': '28 Jul 2026',
        'time': '09:30 AM',
        'fare': '₹450',
        'driver': 'Mohammed Arif',
        'rating': '4.9',
        'vehicle': 'Hyundai Verna',
        'number': 'TS09 AB 1234',
        'payment': 'UPI',
        'tripFare': '₹400',
        'allowance': '₹30',
        'platformFee': '₹20',
      },
      {
        'status': 'Completed',
        'pickup': 'Kukatpally, Hyderabad',
        'drop': 'Banjara Hills, Hyderabad',
        'date': '21 Jul 2026',
        'time': '06:45 PM',
        'fare': '₹320',
        'driver': 'Sohail Ahmed',
        'rating': '4.7',
        'vehicle': 'Maruti Ciaz',
        'number': 'TS08 EF 9012',
        'payment': 'Card',
        'tripFare': '₹280',
        'allowance': '₹20',
        'platformFee': '₹20',
      },
      {
        'status': 'Cancelled',
        'pickup': 'Madhapur, Hyderabad',
        'drop': 'Secunderabad',
        'date': '18 Jul 2026',
        'time': '08:00 PM',
        'fare': '₹400',
        'driver': 'Not Assigned',
        'rating': '0',
        'vehicle': 'Not Assigned',
        'number': '-',
        'payment': 'UPI',
        'tripFare': '₹360',
        'allowance': '₹20',
        'platformFee': '₹20',
      },
    ];

    return allRides
        .where((ride) => ride['status'] == status)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = rides;

    if (list.isEmpty) {
      return Center(
        child: Text(
          'No $status rides',
          style: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final ride = list[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.radio_button_checked,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ride['pickup'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: RideHistoryScreen.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ride['drop'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: RideHistoryScreen.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Divider(color: Colors.grey.shade300),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: RideHistoryScreen.gold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ride['date'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.access_time,
                    color: RideHistoryScreen.gold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ride['time'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Text(
                    ride['fare'],
                    style: GoogleFonts.poppins(
                      color: RideHistoryScreen.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  _statusBadge(ride['status']),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RideDetailsScreen(
                          ride: ride,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RideHistoryScreen.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "View Details",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    final Color bg;
    final Color text;

    if (status == 'Upcoming') {
      bg = Colors.blue.shade50;
      text = Colors.blue;
    } else if (status == 'Completed') {
      bg = Colors.green.shade50;
      text = Colors.green;
    } else {
      bg = Colors.red.shade50;
      text = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}