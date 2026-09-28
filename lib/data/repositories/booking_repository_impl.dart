import '../../domain/repositories/booking_repository.dart';
import '../datasources/mock/mock_booking_data_source.dart';

import '../../domain/models/models.dart';

class BookingRepositoryImpl implements BookingRepository {
  final MockBookingDataSource mockDataSource;

  BookingRepositoryImpl(this.mockDataSource);

  @override
  Future<List<Booking>> getBookings() async {
    return await mockDataSource.getBookings();
  }

  @override
  Future<void> updateBookingStatus(String id, String status) async {
    // Implement mock update logic
  }
}
