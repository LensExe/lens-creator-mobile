import '../models/models.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings(String userId, String role);
  Future<Booking> createBooking(Booking booking);
  Future<void> updateBookingStatus(String id, BookingStatus status);
  Future<Booking> addDeliveryPhotos(String id, List<String> urls);
  Future<Booking> inviteCollaborator(String id, Photographer photographer, int sharePct);
  Future<Booking> respondToCollaboration(String id, CollaborationStatus status);
}
