// Badge definitions for MoodBridge
// Theme: "Thiên Thần Lan Tỏa" (Spreading Angel)

class Badge {
  final String code;
  final String name;
  final String description;
  final String icon;
  final String requirementType; // 'sends', 'streak', 'helped'
  final int requirementValue;

  const Badge({
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    required this.requirementType,
    required this.requirementValue,
  });
}

class AppBadges {
  static const List<Badge> all = [
    Badge(
      code: 'first_send',
      name: 'Thiên Thần Nhỏ',
      description: 'Gửi lời động viên đầu tiên',
      icon: '🌟',
      requirementType: 'sends',
      requirementValue: 1,
    ),
    Badge(
      code: '5_day_streak',
      name: 'Thiên Thần Kiên Nhẫn',
      description: '5 ngày liên tiếp gửi động viên',
      icon: '😇',
      requirementType: 'streak',
      requirementValue: 5,
    ),
    Badge(
      code: '10_helped',
      name: 'Thiên Thần Lan Tỏa',
      description: 'Giúp 10 người vui hơn',
      icon: '👼',
      requirementType: 'helped',
      requirementValue: 10,
    ),
    Badge(
      code: '30_day_streak',
      name: 'Thiên Thần Thủ Hộ',
      description: '30 ngày liên tiếp',
      icon: '🕊️',
      requirementType: 'streak',
      requirementValue: 30,
    ),
    Badge(
      code: '50_helped',
      name: 'Tổng Thiên Thần',
      description: 'Giúp 50 người vui hơn',
      icon: '👑',
      requirementType: 'helped',
      requirementValue: 50,
    ),
  ];

  /// Get badge by code
  static Badge? getByCode(String code) {
    try {
      return all.firstWhere((b) => b.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Check if user has earned a badge based on stats
  static List<Badge> getEarnedBadges({
    required int totalSent,
    required int currentStreak,
    required int peopleHelped,
  }) {
    return all.where((badge) {
      switch (badge.requirementType) {
        case 'sends':
          return totalSent >= badge.requirementValue;
        case 'streak':
          return currentStreak >= badge.requirementValue;
        case 'helped':
          return peopleHelped >= badge.requirementValue;
        default:
          return false;
      }
    }).toList();
  }
}
