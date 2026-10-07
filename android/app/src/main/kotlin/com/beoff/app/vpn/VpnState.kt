package com.beoff.app.vpn

enum class VpnStatus {
    DISCONNECTED,
    CONNECTING,
    CONNECTED,
    STOPPING,
    ERROR
}

data class FilterStats(
    var adsBlocked: Long = 0,
    var trackersBlocked: Long = 0,
    var malwareBlocked: Long = 0,
    var explicitBlocked: Long = 0,
    var totalQueries: Long = 0
)

data class DomainDecision(
    val domain: String,
    val isBlocked: Boolean,
    val category: BlockCategory?,
    val reason: String?
)

enum class BlockCategory {
    AD,
    TRACKER,
    MALWARE,
    EXPLICIT,
    CUSTOM_BLOCKLIST
}
