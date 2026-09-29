import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/models.dart';
import '../data/mock_database.dart';
import '../data/mock_api_service.dart';
import '../domain/booking_rules.dart';
import '../data/datasources/mock/mock_booking_data_source.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../domain/repositories/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepositoryImpl(MockBookingDataSource(mockApiService)),
);

class AuthUserNotifier extends Notifier<User?> {
  @override
  User? build() {
    return MockDatabase.currentUser;
  }

  void setUser(User? user) {
    state = user;
    MockDatabase.currentUser = user;
    // When user changes, refresh bookings
    ref.invalidate(asyncBookingsProvider);
  }
}

final authUserProvider = NotifierProvider<AuthUserNotifier, User?>(
  () => AuthUserNotifier(),
);

class PhotographersNotifier extends Notifier<List<Photographer>> {
  @override
  List<Photographer> build() => List.of(MockDatabase.photographers);

  void update(Photographer photographer) {
    state = [
      for (final current in state)
        if (current.id == photographer.id) photographer else current,
    ];
    final index = MockDatabase.photographers.indexWhere(
      (p) => p.id == photographer.id,
    );
    if (index >= 0) MockDatabase.photographers[index] = photographer;
  }

  void add(Photographer photographer) {
    state = [...state, photographer];
    MockDatabase.photographers.add(photographer);
  }
}

final photographersProvider =
    NotifierProvider<PhotographersNotifier, List<Photographer>>(
      PhotographersNotifier.new,
    );

final myPhotographerProvider = Provider<Photographer?>((ref) {
  final user = ref.watch(authUserProvider);
  if (user == null) return null;
  for (final photographer in ref.watch(photographersProvider)) {
    if (photographer.id == user.id) return photographer;
  }
  return null;
});

// Using AsyncNotifier to handle API loading states
class AsyncBookingsNotifier extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() async {
    final user = ref.watch(authUserProvider);
    if (user == null) return [];

    return await ref
        .read(bookingRepositoryProvider)
        .getBookings(user.id, user.role);
  }

  Future<void> createBooking(Booking booking) async {
    // Keep old state
    final previousState = state.value ?? [];

    // Set loading
    state = const AsyncLoading();

    try {
      final newBooking = await ref
          .read(bookingRepositoryProvider)
          .createBooking(booking);
      state = AsyncData([...previousState, newBooking]);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    final previousState = state.value ?? [];

    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(bookingId, newStatus);

      // Update local state without re-fetching everything
      final updatedList = previousState.map((b) {
        if (b.id == bookingId) {
          return b.copyWith(status: newStatus);
        }
        return b;
      }).toList();

      state = AsyncData(updatedList);
    } catch (e, stack) {
      state = AsyncData(previousState);
      Error.throwWithStackTrace(e, stack);
    }
  }

  Future<void> addDeliveryPhotos(String bookingId, List<String> urls) async {
    final previous = state.value ?? [];
    try {
      final updated = await ref
          .read(bookingRepositoryProvider)
          .addDeliveryPhotos(bookingId, urls);
      state = AsyncData([
        for (final booking in previous)
          if (booking.id == bookingId) updated else booking,
      ]);
    } catch (error, stack) {
      Error.throwWithStackTrace(error, stack);
    }
  }

  Future<void> inviteCollaborator(String bookingId,
      Photographer photographer, int sharePct) async {
    final previous = state.value ?? [];
    final updated = await ref.read(bookingRepositoryProvider)
        .inviteCollaborator(bookingId, photographer, sharePct);
    state = AsyncData([for (final booking in previous)
      if (booking.id == bookingId) updated else booking]);
    ref.read(bookingRevisionProvider.notifier).advance();
  }

  Future<void> respondToCollaboration(String bookingId,
      CollaborationStatus status) async {
    await ref.read(bookingRepositoryProvider).respondToCollaboration(bookingId, status);
    ref.read(bookingRevisionProvider.notifier).advance();
  }
}

final asyncBookingsProvider =
    AsyncNotifierProvider<AsyncBookingsNotifier, List<Booking>>(
      () => AsyncBookingsNotifier(),
    );

// We can still provide a synchronous snapshot for simple screens,
// but they won't show loading states properly unless they use asyncBookingsProvider directly.
final myBookingsProvider = Provider<List<Booking>>((ref) {
  return ref.watch(asyncBookingsProvider).value ?? [];
});

final incomingBookingsProvider = Provider<AsyncValue<List<Booking>>>((ref) {
  return ref
      .watch(asyncBookingsProvider)
      .whenData(
        (bookings) =>
            bookings.where(BookingRules.visibleToPhotographer).toList(),
      );
});

class BookingRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void advance() => state++;
}

final bookingRevisionProvider = NotifierProvider<BookingRevisionNotifier, int>(
    BookingRevisionNotifier.new);

final myCollaborationsProvider = Provider<List<Booking>>((ref) {
  ref.watch(bookingRevisionProvider);
  final user = ref.watch(authUserProvider);
  if (user == null) return [];
  return MockDatabase.bookings.where((booking) => booking.collaborators.any(
      (item) => item.photographerId == user.id)).toList();
});
