import 'assistant_models.dart';

class AssistantRules {
  static const handoffMessage =
      'Vấn đề này cần nhiếp ảnh gia trực tiếp hỗ trợ. Mình đã chuyển cuộc trò chuyện cho nhiếp ảnh gia, bạn vui lòng chờ trong giây lát nhé.';
  static const _handoffKeywords = [
    'khiếu nại',
    'huỷ',
    'hủy',
    'hoàn tiền',
    'tranh chấp',
    'bồi thường',
    'khiếu kiện',
    'report',
  ];

  static bool needsHandoff(String text) {
    final lower = text.toLowerCase();
    return _handoffKeywords.any(lower.contains);
  }

  static String generateReply(AssistantConfig config, String text) {
    final lower = text.toLowerCase();
    for (final faq in config.faqs) {
      final words = faq.question
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((word) => word.length > 3);
      if (words.any(lower.contains)) return faq.answer;
    }
    if (lower.contains('giá') ||
        lower.contains('bao nhiêu') ||
        lower.contains('chi phí')) {
      return config.services.isNotEmpty
          ? config.services
          : 'Bạn tham khảo bảng giá dịch vụ của mình giúp nhé.';
    }
    if (lower.contains('khu vực') ||
        lower.contains('ở đâu') ||
        lower.contains('địa điểm')) {
      return 'Mình nhận chụp tại khu vực: ${config.area.isNotEmpty ? config.area : 'vui lòng hỏi thêm nhé'}.';
    }
    if (lower.contains('phong cách') || lower.contains('style')) {
      return 'Phong cách của mình: ${config.style.isNotEmpty ? config.style : 'đa dạng theo yêu cầu'}.';
    }
    return 'Cảm ơn bạn đã nhắn tin! Mình sẽ phản hồi chi tiết sớm. Tham khảo thêm: ${config.services.isNotEmpty ? config.services : 'các gói dịch vụ của mình'}.';
  }
}
