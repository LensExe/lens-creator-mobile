import '../../../data/mock_database.dart';

import '../../../domain/models/models.dart';

class MockBookingDataSource {
  Future<List<Booking>> getBookings() async {
    return MockDatabase.bookings;
  }
}
