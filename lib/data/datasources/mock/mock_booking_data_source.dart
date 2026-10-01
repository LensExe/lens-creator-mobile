import '../../../domain/models/models.dart';
import '../../mock_api_service.dart';

class MockBookingDataSource {
  MockBookingDataSource(this.api);
  final MockApiService api;

  Future<List<Booking>> getBookings(String userId, String role) =>
      api.getMyBookings(userId, role);
  Future<Booking> createBooking(Booking booking) => api.createBooking(booking);
  Future<void> updateBookingStatus(String id, BookingStatus status) =>
      api.updateBookingStatus(id, status);
  Future<Booking> addDeliveryPhotos(String id, List<String> urls) =>
      api.addDeliveryPhotos(id, urls);
  Future<Booking> inviteCollaborator(
    String id,
    Photographer photographer,
    int sharePct,
  ) => api.inviteCollaborator(id, photographer, sharePct);
  Future<Booking> respondToCollaboration(
    String id,
    CollaborationStatus status,
  ) => api.respondToCollaboration(id, status);
}
