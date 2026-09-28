import '../models/models.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings();
  Future<void> updateBookingStatus(String id, String status);
}
