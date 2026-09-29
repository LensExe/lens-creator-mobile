import 'models/models.dart';

/// Photographer-visible statuses and transitions mirror the portal booking flow.
class BookingRules {
  static const double depositRate = 0.30;
  static const double commissionRate = 0.10;

  static int deposit(int price) =>
      ((price * depositRate) / 1000).round() * 1000;
  static int commission(int price) =>
      ((price * commissionRate) / 1000).round() * 1000;
  static int payout(int price) => price - commission(price);

  /// Escrow release allocates rounded shares only to accepted collaborators.
  /// The lead receives the remainder, keeping the total equal to net payout.
  static int payoutFor(Booking booking, String photographerId) {
    final net = payout(booking.price);
    final accepted = booking.collaborators.where(
      (item) => item.status == CollaborationStatus.accepted,
    );
    int share(int percent) => ((net * percent / 100) / 1000).round() * 1000;
    if (photographerId == booking.photographerId) {
      return net -
          accepted.fold<int>(0, (sum, item) => sum + share(item.sharePct));
    }
    for (final item in accepted) {
      if (item.photographerId == photographerId) return share(item.sharePct);
    }
    return 0;
  }

  static bool visibleToPhotographer(Booking booking) =>
      booking.status != BookingStatus.awaitingDeposit;

  static bool canDecide(Booking booking) =>
      booking.status == BookingStatus.pending;

  static bool canTransition(BookingStatus from, BookingStatus to) =>
      from == BookingStatus.pending &&
      (to == BookingStatus.confirmed || to == BookingStatus.cancelled);

  static String statusLabel(BookingStatus status) => switch (status) {
    BookingStatus.awaitingDeposit => 'Chờ đặt cọc',
    BookingStatus.pending => 'Chờ xác nhận',
    BookingStatus.confirmed => 'Chờ thanh toán',
    BookingStatus.held => 'Sàn đang giữ tiền',
    BookingStatus.released => 'Hoàn thành',
    BookingStatus.cancelled => 'Đã huỷ',
  };
}
