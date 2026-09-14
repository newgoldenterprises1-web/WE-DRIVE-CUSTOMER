import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  BookingService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _bookings =>
      _firestore.collection('bookings');

  static Future<String> createBooking({
    required String serviceType,
    required String pickupLocation,
    String? dropLocation,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropLatitude,
    double? dropLongitude,
    DateTime? bookingDate,
    String? bookingTime,
    int? selectedHours,
    String? vehicleType,
    String? transmission,
    String? fuelType,
    required double fare,
    String paymentMethod = 'Cash',
    String paymentStatus = 'pending',
    Map<String, dynamic>? additionalData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-signed-in',
        message: 'Please login before creating a booking.',
      );
    }

    final requestPreferences = Map<String, dynamic>.from(
      (additionalData?['requestPreferences'] as Map?) ?? {},
    );

    final bookingRef = _bookings.doc();
    final data = <String, dynamic>{
      ...?additionalData,
      'bookingId': bookingRef.id,
      'customerId': user.uid,
      'serviceType': serviceType,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'dropLatitude': dropLatitude,
      'dropLongitude': dropLongitude,
      'bookingDate': bookingDate?.toIso8601String(),
      'bookingTime': bookingTime,
      'selectedHours': selectedHours,
      'vehicleType': vehicleType,
      'transmission': transmission,
      'fuelType': fuelType,
      'fare': fare,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': 'searching',
      'bookingStatus': 'searching',
      'driverId': null,
      'requestPreferences': requestPreferences,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await bookingRef.set(data);
    return bookingRef.id;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getBooking(
    String bookingId,
  ) async =>
      _bookings.doc(bookingId).get();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchBooking(
    String bookingId,
  ) =>
      _bookings.doc(bookingId).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchMyBookings() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _bookings
        .where('customerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> cancelBooking({
    required String bookingId,
    String reason = 'Cancelled by customer',
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-signed-in',
        message: 'Please login first.',
      );
    }

    final bookingRef = _bookings.doc(bookingId);
    final snapshot = await bookingRef.get();
    if (!snapshot.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'booking-not-found',
        message: 'Booking not found.',
      );
    }

    final data = snapshot.data() ?? {};
    if (data['customerId'] != user.uid) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'You cannot cancel this booking.',
      );
    }

    final currentStatus = (data['status'] ?? data['bookingStatus'] ?? '')
        .toString()
        .toUpperCase();
    if ({'COMPLETED', 'CANCELLED', 'TRIP_STARTED'}.contains(currentStatus)) {
      return;
    }

    await bookingRef.update({
      'status': 'cancelled',
      'bookingStatus': 'cancelled',
      'cancelledBy': 'customer',
      'cancellationReason': reason,
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
  }) async {
    await _bookings.doc(bookingId).update({
      'paymentStatus': paymentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateBookingStatus({
    required String bookingId,
    required String bookingStatus,
  }) async {
    throw StateError(
      'Booking status is controlled by the WE DRIVE Partner backend.',
    );
  }
}
