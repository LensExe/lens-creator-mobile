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
