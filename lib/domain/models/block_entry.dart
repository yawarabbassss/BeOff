enum BlockType {
  ad,
  tracker,
  malware,
  annoyance,
  explicit,
  custom,
}

enum ListType {
  allowlist,
  blocklist,
}

class BlockEntry {
  final String domain;
  final BlockType type;
  final ListType listType;
  final DateTime addedAt;
  final String? note;
  final bool isEnabled;

  BlockEntry({
    required this.domain,
    required this.type,
    required this.listType,
    required this.addedAt,
    this.note,
    this.isEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'domain': domain,
      'type': type.name,
      'listType': listType.name,
      'addedAt': addedAt.toIso8601String(),
      'note': note,
      'isEnabled': isEnabled ? 1 : 0,
    };
  }

  factory BlockEntry.fromMap(Map<String, dynamic> map) {
    return BlockEntry(
      domain: map['domain'] as String,
      type: BlockType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BlockType.custom,
      ),
      listType: ListType.values.firstWhere(
        (e) => e.name == map['listType'],
        orElse: () => ListType.blocklist,
      ),
      addedAt: DateTime.tryParse(map['addedAt'] as String? ?? '') ?? DateTime.now(),
      note: map['note'] as String?,
      isEnabled: (map['isEnabled'] as int? ?? 1) == 1,
    );
  }

  BlockEntry copyWith({
    String? domain,
    BlockType? type,
    ListType? listType,
    DateTime? addedAt,
    String? note,
    bool? isEnabled,
  }) {
    return BlockEntry(
      domain: domain ?? this.domain,
      type: type ?? this.type,
      listType: listType ?? this.listType,
      addedAt: addedAt ?? this.addedAt,
      note: note ?? this.note,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
