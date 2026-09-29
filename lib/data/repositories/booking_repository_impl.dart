import '../../domain/repositories/booking_repository.dart';
import '../datasources/mock/mock_booking_data_source.dart';

import '../../domain/models/models.dart';

class BookingRepositoryImpl implements BookingRepository {
  final MockBookingDataSource mockDataSource;

  BookingRepositoryImpl(this.mockDataSource);

  @override
  Future<List<Booking>> getBookings(String userId, String role) =>
      mockDataSource.getBookings(userId, role);

  @override
  Future<Booking> createBooking(Booking booking) =>
      mockDataSource.createBooking(booking);

  @override
  Future<void> updateBookingStatus(String id, BookingStatus status) =>
      mockDataSource.updateBookingStatus(id, status);

  @override
  Future<Booking> addDeliveryPhotos(String id, List<String> urls) =>
      mockDataSource.addDeliveryPhotos(id, urls);

  @override
  Future<Booking> inviteCollaborator(String id, Photographer photographer, int sharePct) =>
      mockDataSource.inviteCollaborator(id, photographer, sharePct);

  @override
  Future<Booking> respondToCollaboration(String id, CollaborationStatus status) =>
      mockDataSource.respondToCollaboration(id, status);
}
