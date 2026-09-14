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

    final userSnapshot =
        await _firestore.collection('users').doc(user.uid).get();
    final userData = userSnapshot.data() ?? <String, dynamic>{};
    final bookingRef = _bookings.doc();

    final data = <String, dynamic>{
      'bookingId': bookingRef.id,
      'customerId': user.uid,
      'customerName': userData['name'] ?? user.displayName ?? '',
      'customerPhone': userData['phone'] ?? user.phoneNumber ?? '',
      'customerEmail': userData['email'] ?? user.email ?? '',
      'serviceType': serviceType,
      'vehicleType': vehicleType,
      'transmission': transmission,
      'fuelType': fuelType,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      if (pickupLatitude != null) 'pickupLatitude': pickupLatitude,
      if (pickupLongitude != null) 'pickupLongitude': pickupLongitude,
      if (dropLatitude != null) 'dropLatitude': dropLatitude,
      if (dropLongitude != null) 'dropLongitude': dropLongitude,
      if (bookingDate != null) 'bookingDate': Timestamp.fromDate(bookingDate),
      if (bookingTime != null) 'bookingTime': bookingTime,
      if (selectedHours != null) 'selectedHours': selectedHours,
      'fare': fare,
      'currency': 'INR',
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': 'REQUESTED',
      'bookingStatus': 'REQUESTED',
      'partnerId': null,
      'driverId': null,
      'driverName': null,
      'driverPhone': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (additionalData != null && additionalData.isNotEmpty) {
      data.addAll(additionalData);
    }

    // Keep customer-created bookings compatible with the Partner backend.
    data['status'] = 'REQUESTED';
    data['bookingStatus'] = 'REQUESTED';
    data['partnerId'] = null;
    data['driverId'] = null;

    await bookingRef.set(data);
    return bookingRef.id;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getBooking(
    String bookingId,
  ) async {
    return _bookings.doc(bookingId).get();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchBooking(
    String bookingId,
  ) {
    return _bookings.doc(bookingId).snapshots();
  }

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
    if (currentStatus == 'COMPLETED' || currentStatus == 'CANCELLED') return;

    await bookingRef.update({
      'status': 'CANCELLED',
      'bookingStatus': 'CANCELLED',
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

  /// Trip status is controlled by the WE DRIVE Partner backend.
  static Future<void> updateBookingStatus({
    required String bookingId,
    required String bookingStatus,
  }) async {
    throw StateError(
      'Booking status is controlled by the WE DRIVE Partner backend.',
    );
  }
}
