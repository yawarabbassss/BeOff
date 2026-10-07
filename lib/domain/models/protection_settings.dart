import 'content_safety_result.dart';

class ProtectionSettings {
  final bool isProtectionEnabled;
  final bool isAdBlockingEnabled;
  final bool isTrackerBlockingEnabled;
  final bool isMalwareProtectionEnabled;
  final bool isAnnoyanceBlockingEnabled;
  final bool isCleanSearchEnabled;
  final bool isContentSafetyEnabled;
  final ContentSafetySensitivity contentSafetySensitivity;
  final bool isChildProtectionMode;
  final bool isAutoStartOnBoot;
  final String upstreamDnsProvider; // 'CLOUDFLARE', 'QUAD9', 'ADGUARD_DNS', 'CUSTOM'
  final String customDnsIp;

  const ProtectionSettings({
    this.isProtectionEnabled = true,
    this.isAdBlockingEnabled = true,
    this.isTrackerBlockingEnabled = true,
    this.isMalwareProtectionEnabled = true,
    this.isAnnoyanceBlockingEnabled = true,
    this.isCleanSearchEnabled = true,
    this.isContentSafetyEnabled = true,
    this.contentSafetySensitivity = ContentSafetySensitivity.high,
    this.isChildProtectionMode = false,
    this.isAutoStartOnBoot = true,
    this.upstreamDnsProvider = 'CLOUDFLARE',
    this.customDnsIp = '1.1.1.1',
  });

  ProtectionSettings copyWith({
    bool? isProtectionEnabled,
    bool? isAdBlockingEnabled,
    bool? isTrackerBlockingEnabled,
    bool? isMalwareProtectionEnabled,
    bool? isAnnoyanceBlockingEnabled,
    bool? isCleanSearchEnabled,
    bool? isContentSafetyEnabled,
    ContentSafetySensitivity? contentSafetySensitivity,
    bool? isChildProtectionMode,
    bool? isAutoStartOnBoot,
    String? upstreamDnsProvider,
    String? customDnsIp,
  }) {
    return ProtectionSettings(
      isProtectionEnabled: isProtectionEnabled ?? this.isProtectionEnabled,
      isAdBlockingEnabled: isAdBlockingEnabled ?? this.isAdBlockingEnabled,
      isTrackerBlockingEnabled: isTrackerBlockingEnabled ?? this.isTrackerBlockingEnabled,
      isMalwareProtectionEnabled: isMalwareProtectionEnabled ?? this.isMalwareProtectionEnabled,
      isAnnoyanceBlockingEnabled: isAnnoyanceBlockingEnabled ?? this.isAnnoyanceBlockingEnabled,
      isCleanSearchEnabled: isCleanSearchEnabled ?? this.isCleanSearchEnabled,
      isContentSafetyEnabled: isContentSafetyEnabled ?? this.isContentSafetyEnabled,
      contentSafetySensitivity: contentSafetySensitivity ?? this.contentSafetySensitivity,
      isChildProtectionMode: isChildProtectionMode ?? this.isChildProtectionMode,
      isAutoStartOnBoot: isAutoStartOnBoot ?? this.isAutoStartOnBoot,
      upstreamDnsProvider: upstreamDnsProvider ?? this.upstreamDnsProvider,
      customDnsIp: customDnsIp ?? this.customDnsIp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isProtectionEnabled': isProtectionEnabled,
      'isAdBlockingEnabled': isAdBlockingEnabled,
      'isTrackerBlockingEnabled': isTrackerBlockingEnabled,
      'isMalwareProtectionEnabled': isMalwareProtectionEnabled,
      'isAnnoyanceBlockingEnabled': isAnnoyanceBlockingEnabled,
      'isCleanSearchEnabled': isCleanSearchEnabled,
      'isContentSafetyEnabled': isContentSafetyEnabled,
      'contentSafetySensitivity': contentSafetySensitivity.name,
      'isChildProtectionMode': isChildProtectionMode,
      'isAutoStartOnBoot': isAutoStartOnBoot,
      'upstreamDnsProvider': upstreamDnsProvider,
      'customDnsIp': customDnsIp,
    };
  }

  factory ProtectionSettings.fromMap(Map<String, dynamic> map) {
    return ProtectionSettings(
      isProtectionEnabled: map['isProtectionEnabled'] as bool? ?? true,
      isAdBlockingEnabled: map['isAdBlockingEnabled'] as bool? ?? true,
      isTrackerBlockingEnabled: map['isTrackerBlockingEnabled'] as bool? ?? true,
      isMalwareProtectionEnabled: map['isMalwareProtectionEnabled'] as bool? ?? true,
      isAnnoyanceBlockingEnabled: map['isAnnoyanceBlockingEnabled'] as bool? ?? true,
      isCleanSearchEnabled: map['isCleanSearchEnabled'] as bool? ?? true,
      isContentSafetyEnabled: map['isContentSafetyEnabled'] as bool? ?? true,
      contentSafetySensitivity: ContentSafetySensitivity.values.firstWhere(
        (e) => e.name == map['contentSafetySensitivity'],
        orElse: () => ContentSafetySensitivity.high,
      ),
      isChildProtectionMode: map['isChildProtectionMode'] as bool? ?? false,
      isAutoStartOnBoot: map['isAutoStartOnBoot'] as bool? ?? true,
      upstreamDnsProvider: map['upstreamDnsProvider'] as String? ?? 'CLOUDFLARE',
      customDnsIp: map['customDnsIp'] as String? ?? '1.1.1.1',
    );
  }
}
