import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/data_providers.dart';

class AssistantFaq {
  const AssistantFaq(this.question, this.answer);
  final String question;
  final String answer;
}

class AssistantConfig {
  const AssistantConfig({
    required this.enabled,
    required this.services,
    required this.style,
    required this.area,
    required this.tone,
    required this.faqs,
  });
  final bool enabled;
  final String services;
  final String style;
  final String area;
  final String tone;
  final List<AssistantFaq> faqs;
}

class AssistantNotifier extends Notifier<AssistantConfig> {
  @override
  AssistantConfig build() {
    if (ref.watch(authUserProvider)?.id != 'me') {
      return const AssistantConfig(enabled: false, services: '', style: '',
          area: '', tone: '', faqs: []);
    }
    return const AssistantConfig(
    enabled: true,
    services: 'Gói cơ bản 450k, Tiêu chuẩn 800k, Cao cấp 1.35tr.',
    style: 'Chân dung & gia đình, ánh sáng tự nhiên.',
    area: 'Hà Nội và khu vực lân cận',
    tone: 'Thân thiện, ngắn gọn',
    faqs: [
      AssistantFaq(
        'Bao lâu thì giao ảnh?',
        'Mình giao ảnh trong vòng 5–7 ngày sau buổi chụp nhé.',
      ),
      AssistantFaq(
        'Có hỗ trợ trang điểm không?',
        'Mình có thể kết nối makeup artist, chi phí tính riêng.',
      ),
    ],
    );
  }

  void save(AssistantConfig value) => state = value;
}

final assistantProvider = NotifierProvider<AssistantNotifier, AssistantConfig>(
  AssistantNotifier.new,
);
