class ProtectionStats {
  final int adsBlocked;
  final int trackersBlocked;
  final int malwareBlocked;
  final int explicitBlocked;
  final int annoyancesBlocked;
  final int totalQueries;
  final DateTime date;

  const ProtectionStats({
    this.adsBlocked = 0,
    this.trackersBlocked = 0,
    this.malwareBlocked = 0,
    this.explicitBlocked = 0,
    this.annoyancesBlocked = 0,
    this.totalQueries = 0,
    required this.date,
  });

  int get totalBlocked =>
      adsBlocked + trackersBlocked + malwareBlocked + explicitBlocked + annoyancesBlocked;

  ProtectionStats copyWith({
    int? adsBlocked,
    int? trackersBlocked,
    int? malwareBlocked,
    int? explicitBlocked,
    int? annoyancesBlocked,
    int? totalQueries,
    DateTime? date,
  }) {
    return ProtectionStats(
      adsBlocked: adsBlocked ?? this.adsBlocked,
      trackersBlocked: trackersBlocked ?? this.trackersBlocked,
      malwareBlocked: malwareBlocked ?? this.malwareBlocked,
      explicitBlocked: explicitBlocked ?? this.explicitBlocked,
      annoyancesBlocked: annoyancesBlocked ?? this.annoyancesBlocked,
      totalQueries: totalQueries ?? this.totalQueries,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().split('T').first,
      'adsBlocked': adsBlocked,
      'trackersBlocked': trackersBlocked,
      'malwareBlocked': malwareBlocked,
      'explicitBlocked': explicitBlocked,
      'annoyancesBlocked': annoyancesBlocked,
      'totalQueries': totalQueries,
    };
  }

  factory ProtectionStats.fromMap(Map<String, dynamic> map) {
    return ProtectionStats(
      adsBlocked: map['adsBlocked'] as int? ?? 0,
      trackersBlocked: map['trackersBlocked'] as int? ?? 0,
      malwareBlocked: map['malwareBlocked'] as int? ?? 0,
      explicitBlocked: map['explicitBlocked'] as int? ?? 0,
      annoyancesBlocked: map['annoyancesBlocked'] as int? ?? 0,
      totalQueries: map['totalQueries'] as int? ?? 0,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
