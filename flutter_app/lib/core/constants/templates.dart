// Encouragement message templates

class MessageTemplate {
  final String id;
  final String emoji;
  final String content;
  final String category; // 'motivation', 'hope', 'comfort', 'support'

  const MessageTemplate({
    required this.id,
    required this.emoji,
    required this.content,
    required this.category,
  });
}

class AppTemplates {
  static const List<MessageTemplate> all = [
    MessageTemplate(
      id: 'motivation_1',
      emoji: '💪',
      content: 'Bạn làm được! Mình tin bạn!',
      category: 'motivation',
    ),
    MessageTemplate(
      id: 'hope_1',
      emoji: '🌈',
      content: 'Ngày mai sẽ tốt hơn! Hãy kiên nhẫn với bản thân nhé.',
      category: 'hope',
    ),
    MessageTemplate(
      id: 'support_1',
      emoji: '🤗',
      content: 'Mình ở đây nếu bạn cần nói chuyện. Bạn không cô đơn đâu.',
      category: 'support',
    ),
    MessageTemplate(
      id: 'hope_2',
      emoji: '☀️',
      content: 'Sau cơn mưa trời lại sáng. Gửi bạn nhiều năng lượng tích cực!',
      category: 'hope',
    ),
    MessageTemplate(
      id: 'comfort_1',
      emoji: '🌸',
      content: 'Hãy cho phép bản thân được buồn, rồi mọi thứ sẽ ổn thôi.',
      category: 'comfort',
    ),
    MessageTemplate(
      id: 'motivation_2',
      emoji: '🎯',
      content: 'Mỗi ngày là một cơ hội mới. Bạn đang làm tốt lắm rồi!',
      category: 'motivation',
    ),
    MessageTemplate(
      id: 'comfort_2',
      emoji: '💕',
      content: 'Gửi bạn một cái ôm ấm áp. Take your time.',
      category: 'comfort',
    ),
    MessageTemplate(
      id: 'motivation_3',
      emoji: '🌟',
      content: 'Bạn mạnh mẽ hơn bạn nghĩ đó!',
      category: 'motivation',
    ),
  ];

  /// Get templates by category
  static List<MessageTemplate> getByCategory(String category) {
    return all.where((t) => t.category == category).toList();
  }

  /// Get template by ID
  static MessageTemplate? getById(String id) {
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all categories
  static List<String> get categories => ['motivation', 'hope', 'comfort', 'support'];

  /// Get category Vietnamese name
  static String getCategoryName(String category) {
    switch (category) {
      case 'motivation':
        return 'Động lực';
      case 'hope':
        return 'Hy vọng';
      case 'comfort':
        return 'An ủi';
      case 'support':
        return 'Hỗ trợ';
      default:
        return category;
    }
  }
}
