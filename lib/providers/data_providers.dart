import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/auth_session_store.dart';
import '../core/network/dio_client.dart';

import '../domain/models/models.dart';
import '../domain/booking_rules.dart';
import '../data/repositories/api_booking_repository.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../data/repositories/api_auth_repository.dart';
import '../data/repositories/api_auth_flow_repository.dart';
import '../data/repositories/api_photographer_profile_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(
    ref.watch(dioProvider),
    ref.watch(authSessionStoreProvider),
  ),
);

final authFlowRepositoryProvider = Provider<ApiAuthFlowRepository>(
  (ref) => ApiAuthFlowRepository(
    ref.watch(dioProvider),
    ref.watch(authSessionStoreProvider),
  ),
);

final apiPhotographerProfileRepositoryProvider =
    Provider<ApiPhotographerProfileRepository>(
      (ref) => ApiPhotographerProfileRepository(ref.watch(dioProvider)),
    );

final apiBookingRepositoryProvider = Provider<ApiBookingRepository>(
  (ref) => ApiBookingRepository(ref.watch(dioProvider)),
);

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => ref.watch(apiBookingRepositoryProvider),
);

final creatorBookingDetailProvider = FutureProvider.family<Booking, String>((
  ref,
  bookingId,
) {
  final user = ref.watch(authUserProvider);
  if (user == null || user.role != 'photographer') {
    throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia.');
  }
  return ref.read(apiBookingRepositoryProvider).getBooking(bookingId);
});

final creatorBookingTimelineProvider =
    FutureProvider.family<List<BookingTimelineEntry>, String>((ref, bookingId) {
      final user = ref.watch(authUserProvider);
      if (user == null || user.role != 'photographer') {
        throw StateError('Vui lòng đăng nhập tài khoản nhiếp ảnh gia.');
      }
      return ref.read(apiBookingRepositoryProvider).getTimeline(bookingId);
    });

class AuthUserNotifier extends Notifier<User?> {
  @override
  User? build() {
    ref.read(authSessionStoreProvider).onSessionExpired = () => setUser(null);
    return ref.read(initialAuthUserProvider);
  }

  void setUser(User? user) {
    state = user;
    // AsyncBookingsNotifier watches authUserProvider and reloads itself when
    // the signed-in account changes. Invalidating it here creates a cycle
    // while Riverpod is already rebuilding its dependent providers.
  }

  Future<User> loginWithGoogleCode(String code) async {
    final user = await ref
        .read(authFlowRepositoryProvider)
        .exchangeGoogleCode(code);
    setUser(user);
    return user;
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Remote logout failures should never block local sign-out.
    } finally {
      setUser(null);
    }
  }
}

final authUserProvider = NotifierProvider<AuthUserNotifier, User?>(
  () => AuthUserNotifier(),
);

// No Backend directory endpoint exists for this legacy landing preview.
final photographersProvider = Provider<List<Photographer>>((ref) => const []);

class CurrentPhotographerNotifier extends Notifier<Photographer?> {
  String? _loadingUserId;

  @override
  Photographer? build() {
    final user = ref.watch(authUserProvider);
    if (user == null) {
      _loadingUserId = null;
      return null;
    }
    if (_loadingUserId != user.id) {
      _loadingUserId = user.id;
      Future<void>.microtask(() => refresh(user.id));
    }
    return null;
  }

  Future<void> refresh([String? expectedUserId]) async {
    final user = ref.read(authUserProvider);
    if (user == null || (expectedUserId != null && user.id != expectedUserId)) {
      return;
    }
    try {
      final profile = await ref
          .read(apiPhotographerProfileRepositoryProvider)
          .getMine();
      if (ref.read(authUserProvider)?.id == user.id) state = profile;
    } catch (_) {
      if (ref.read(authUserProvider)?.id == user.id) state = null;
    }
  }

  Future<void> update(Photographer profile) async {
    final current = state;
    if (current == null) {
      throw StateError('Chưa tải được hồ sơ từ Backend. Hãy thử tải lại.');
    }
    state = await ref
        .read(apiPhotographerProfileRepositoryProvider)
        .update(profile, current);
  }
}

final currentPhotographerProvider =
    NotifierProvider<CurrentPhotographerNotifier, Photographer?>(
      CurrentPhotographerNotifier.new,
    );

final myPhotographerProvider = Provider<Photographer?>(
  (ref) => ref.watch(currentPhotographerProvider),
);

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
    BookingStatus newStatus, {
    String? reason,
  }) async {
    try {
      await ref
          .read(bookingRepositoryProvider)
          .updateBookingStatus(bookingId, newStatus, reason: reason);
      final user = ref.read(authUserProvider);
      if (user == null) throw StateError('Phiên đăng nhập đã hết hạn.');
      final refreshed = await ref
          .read(bookingRepositoryProvider)
          .getBookings(user.id, user.role);
      state = AsyncData(refreshed);
    } catch (e, stack) {
      state = AsyncError(e, stack);
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

  Future<void> inviteCollaborator(
    String bookingId,
    Photographer photographer,
    int sharePct,
  ) async {
    final previous = state.value ?? [];
    final updated = await ref
        .read(bookingRepositoryProvider)
        .inviteCollaborator(bookingId, photographer, sharePct);
    state = AsyncData([
      for (final booking in previous)
        if (booking.id == bookingId) updated else booking,
    ]);
    ref.read(bookingRevisionProvider.notifier).advance();
  }

  Future<void> respondToCollaboration(
    String bookingId,
    CollaborationStatus status,
  ) async {
    await ref
        .read(bookingRepositoryProvider)
        .respondToCollaboration(bookingId, status);
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
  BookingRevisionNotifier.new,
);

final myCollaborationsProvider = Provider<List<Booking>>((ref) {
  ref.watch(bookingRevisionProvider);
  return const [];
});
