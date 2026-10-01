import '../../../features/photographer/assistant/assistant_models.dart';

class MockAssistantDataSource {
  static const _delay = Duration(milliseconds: 300);
  static final Map<String, AssistantConfig> _configs = {
    'me': const AssistantConfig(
      enabled: true,
      services: 'Gói cơ bản 450k (1h, 15 ảnh), Tiêu chuẩn 800k (2h, 35 ảnh), Cao cấp 1.35tr (nửa ngày, 70 ảnh + album).',
      style: 'Chân dung & gia đình, ánh sáng tự nhiên, cảm xúc chân thật.',
      area: 'Hà Nội và khu vực lân cận',
      tone: 'Thân thiện, ngắn gọn',
      faqs: [
        AssistantFaq(
          'Bao lâu thì giao ảnh?',
          'Mình giao ảnh trong vòng 5–7 ngày sau buổi chụp nhé.',
        ),
        AssistantFaq(
          'Có hỗ trợ trang điểm không?',
          'Mình có thể kết nối makeup artist, chi phí tính riêng theo nhu cầu.',
        ),
        AssistantFaq(
          'Thanh toán và đặt cọc thế nào?',
          'Bạn đặt cọc 30% để giữ lịch, phần còn lại thanh toán sau khi mình xác nhận. Tiền do sàn Lens giữ đến khi bạn nhận đủ ảnh. Huỷ trước buổi chụp từ 7 ngày được hoàn 100%, muộn hơn sẽ mất cọc.',
        ),
      ],
    ),
    'p2': AssistantConfig(
      enabled: false,
      services: 'Gói ảnh cưới từ 3.2tr, nhận chụp tại TP. Hồ Chí Minh và các tỉnh lân cận.',
      style: 'Ảnh cưới phóng sự, cảm xúc tự nhiên.',
      area: 'TP. Hồ Chí Minh và khu vực lân cận',
      tone: 'Thân thiện, ngắn gọn',
      faqs: const [],
    ),
  };

  AssistantConfig cachedConfig(String photographerId) =>
      _configs[photographerId] ??
      const AssistantConfig(
        enabled: false,
        services: '',
        style: '',
        area: '',
        tone: '',
        faqs: [],
      );

  Future<AssistantConfig> getConfig(String photographerId) async {
    await Future.delayed(_delay);
    return cachedConfig(photographerId);
  }

  Future<AssistantConfig> saveConfig(
    String photographerId,
    AssistantConfig config,
  ) async {
    await Future.delayed(_delay);
    _configs[photographerId] = config;
    return config;
  }
}
