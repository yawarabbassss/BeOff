enum FilterListStatus {
  idle,
  downloading,
  updated,
  error,
}

class FilterListMeta {
  final String id;
  final String name;
  final String description;
  final String url;
  final String localAssetPath;
  final int ruleCount;
  final String version;
  final String license;
  final bool isEnabled;
  final DateTime? lastUpdatedAt;
  final FilterListStatus status;
  final String? errorMessage;

  FilterListMeta({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.localAssetPath,
    required this.ruleCount,
    required this.version,
    required this.license,
    this.isEnabled = true,
    this.lastUpdatedAt,
    this.status = FilterListStatus.idle,
    this.errorMessage,
  });

  FilterListMeta copyWith({
    String? id,
    String? name,
    String? description,
    String? url,
    String? localAssetPath,
    int? ruleCount,
    String? version,
    String? license,
    bool? isEnabled,
    DateTime? lastUpdatedAt,
    FilterListStatus? status,
    String? errorMessage,
  }) {
    return FilterListMeta(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      url: url ?? this.url,
      localAssetPath: localAssetPath ?? this.localAssetPath,
      ruleCount: ruleCount ?? this.ruleCount,
      version: version ?? this.version,
      license: license ?? this.license,
      isEnabled: isEnabled ?? this.isEnabled,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'url': url,
      'localAssetPath': localAssetPath,
      'ruleCount': ruleCount,
      'version': version,
      'license': license,
      'isEnabled': isEnabled ? 1 : 0,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  factory FilterListMeta.fromMap(Map<String, dynamic> map) {
    return FilterListMeta(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      url: map['url'] as String? ?? '',
      localAssetPath: map['localAssetPath'] as String? ?? '',
      ruleCount: map['ruleCount'] as int? ?? 0,
      version: map['version'] as String? ?? '1.0',
      license: map['license'] as String? ?? 'Open Source',
      isEnabled: (map['isEnabled'] as int? ?? 1) == 1,
      lastUpdatedAt: DateTime.tryParse(map['lastUpdatedAt'] as String? ?? ''),
    );
  }
}
