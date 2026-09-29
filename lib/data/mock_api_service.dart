import 'dart:math';

import '../domain/models/models.dart';
import '../domain/booking_rules.dart';
import 'mock_database.dart';

class MockApiService {
  static const _delay = Duration(seconds: 1);

  // --- BOOKINGS ---

  Future<List<Booking>> getMyBookings(String userId, String role) async {
    await Future.delayed(_delay); // Simulate network delay

    // In a real API, the BE filters this. Here we filter mock DB.
    if (role == 'photographer') {
      return MockDatabase.bookings
          .where(
            (b) =>
                b.photographerId == userId &&
                BookingRules.visibleToPhotographer(b),
          )
          .toList();
    } else {
      return MockDatabase.bookings.where((b) => b.clientId == userId).toList();
    }
  }

  Future<Booking> createBooking(Booking booking) async {
    await Future.delayed(_delay);

    // Assign a new ID if needed (though UI might generate a temp one)
    final newBooking = Booking(
      id: 'b${Random().nextInt(10000)}',
      clientId: booking.clientId,
      clientName: booking.clientName,
      photographerId: booking.photographerId,
      photographerName: booking.photographerName,
      style: booking.style,
      date: booking.date,
      location: booking.location,
      price: booking.price,
      packageId: booking.packageId,
      packageName: booking.packageName,
      promisedPhotos: booking.promisedPhotos,
      durationHours: booking.durationHours,
      deliveryDays: booking.deliveryDays,
      timeSlot: booking.timeSlot,
      contactPhone: booking.contactPhone,
      note: booking.note,
      depositAmount: BookingRules.deposit(booking.price),
      status: BookingStatus.awaitingDeposit,
    );

    MockDatabase.bookings.add(newBooking);
    return newBooking;
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    await Future.delayed(_delay);

    final index = MockDatabase.bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) throw StateError('Không tìm thấy lịch đặt');
    final booking = MockDatabase.bookings[index];
    final actor = MockDatabase.currentUser;
    if (actor?.role != 'photographer' || actor?.id != booking.photographerId) {
      throw StateError('Bạn không có quyền xử lý lịch này');
    }
    if (!BookingRules.canTransition(booking.status, newStatus)) {
      throw StateError('Không thể chuyển trạng thái lịch đặt');
    }
    MockDatabase.bookings[index] = booking.copyWith(status: newStatus);
  }

  Future<Booking> addDeliveryPhotos(String bookingId, List<String> urls) async {
    await Future.delayed(_delay);
    final index = MockDatabase.bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) throw StateError('Không tìm thấy lịch đặt');
    final booking = MockDatabase.bookings[index];
    final actor = MockDatabase.currentUser;
    if (actor?.role != 'photographer' || actor?.id != booking.photographerId) {
      throw StateError('Bạn không có quyền giao ảnh cho lịch này');
    }
    if (booking.status != BookingStatus.held) {
      throw StateError('Chỉ có thể giao ảnh khi sàn đang giữ tiền');
    }
    final updated = booking.copyWith(
      deliveredPhotos: booking.deliveredPhotos + urls.length,
      deliveredPhotoUrls: [...booking.deliveredPhotoUrls, ...urls],
    );
    MockDatabase.bookings[index] = updated;
    return updated;
  }

  Future<Booking> inviteCollaborator(String bookingId,
      Photographer photographer, int sharePct) async {
    await Future.delayed(_delay);
    final index = MockDatabase.bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) throw StateError('Không tìm thấy lịch đặt');
    final booking = MockDatabase.bookings[index];
    if (MockDatabase.currentUser?.id != booking.photographerId ||
        (booking.status != BookingStatus.confirmed && booking.status != BookingStatus.held) ||
        booking.deliveredPhotos > 0) {
      throw StateError('Không thể mời thợ cho lịch này');
    }
    final used = booking.collaborators.fold<int>(0, (sum, item) => sum + item.sharePct);
    if (photographer.id == booking.photographerId ||
        booking.collaborators.any((item) => item.photographerId == photographer.id) ||
        sharePct <= 0 || sharePct > 100 - used) {
      throw StateError('Nhiếp ảnh gia hoặc tỷ lệ chia không hợp lệ');
    }
    final updated = booking.copyWith(collaborators: [
      ...booking.collaborators,
      BookingCollaborator(photographerId: photographer.id,
          photographerName: photographer.name, sharePct: sharePct),
    ]);
    MockDatabase.bookings[index] = updated;
    return updated;
  }

  Future<Booking> respondToCollaboration(String bookingId,
      CollaborationStatus response) async {
    await Future.delayed(_delay);
    final index = MockDatabase.bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) throw StateError('Không tìm thấy lịch đặt');
    final booking = MockDatabase.bookings[index];
    final userId = MockDatabase.currentUser?.id;
    final invitation = booking.collaborators.where((item) =>
        item.photographerId == userId && item.status == CollaborationStatus.invited);
    if (invitation.isEmpty ||
        (response != CollaborationStatus.accepted && response != CollaborationStatus.declined)) {
      throw StateError('Không có lời mời đang chờ');
    }
    final updated = booking.copyWith(collaborators: [
      for (final item in booking.collaborators)
        if (item.photographerId == userId) item.copyWith(status: response) else item,
    ]);
    MockDatabase.bookings[index] = updated;
    return updated;
  }
}

// Global instance for simple DI
final mockApiService = MockApiService();
