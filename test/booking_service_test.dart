import 'package:flutter_test/flutter_test.dart';
import 'package:we_drive_v2/services/booking_service.dart';

void main() {
  group('BookingService payment and status guards', () {
    test('payment status cannot be changed from the customer app', () async {
      expect(
        () => BookingService.updatePaymentStatus(
          bookingId: 'booking-test',
          paymentStatus: 'paid',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('operational booking status cannot be changed from the customer app', () async {
      expect(
        () => BookingService.updateBookingStatus(
          bookingId: 'booking-test',
          bookingStatus: 'completed',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
