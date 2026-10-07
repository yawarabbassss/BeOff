enum ContentSafetyCategory {
  safe,
  suggestive,
  nudity,
  explicit,
  unknown,
}

enum ContentSafetySensitivity {
  low,
  medium,
  high,
  strictChild,
}

class ContentSafetyResult {
  final ContentSafetyCategory category;
  final double confidence;
  final bool isUnsafe;
  final bool shouldBlur;
  final bool shouldBlock;
  final int executionTimeMs;
  final String? reason;

  const ContentSafetyResult({
    required this.category,
    required this.confidence,
    required this.isUnsafe,
    required this.shouldBlur,
    required this.shouldBlock,
    required this.executionTimeMs,
    this.reason,
  });

  factory ContentSafetyResult.safe() {
    return const ContentSafetyResult(
      category: ContentSafetyCategory.safe,
      confidence: 0.99,
      isUnsafe: false,
      shouldBlur: false,
      shouldBlock: false,
      executionTimeMs: 1,
    );
  }

  factory ContentSafetyResult.fromMap(Map<dynamic, dynamic> map) {
    final catString = (map['category'] as String? ?? 'UNKNOWN').toLowerCase();
    final cat = ContentSafetyCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == catString,
      orElse: () => ContentSafetyCategory.unknown,
    );

    return ContentSafetyResult(
      category: cat,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      isUnsafe: map['isUnsafe'] as bool? ?? false,
      shouldBlur: map['shouldBlur'] as bool? ?? false,
      shouldBlock: map['shouldBlock'] as bool? ?? false,
      executionTimeMs: (map['executionTimeMs'] as num?)?.toInt() ?? 0,
      reason: map['reason'] as String?,
    );
  }

  String get displayLabel {
    switch (category) {
      case ContentSafetyCategory.safe:
        return 'Safe Content';
      case ContentSafetyCategory.suggestive:
        return 'Suggestive / Sensitive';
      case ContentSafetyCategory.nudity:
        return 'Nudity Detected';
      case ContentSafetyCategory.explicit:
        return 'Explicit Adult Content';
      case ContentSafetyCategory.unknown:
        return 'Unclassified';
    }
  }
}
