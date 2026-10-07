package com.beoff.app.vpn

import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicLong

/**
 * High-performance, multi-threaded domain filtering engine.
 * Matches incoming hostnames against allowlists, custom blocklists, and categorized rules.
 */
class NetworkFilterEngine {

    // Allowlist takes absolute precedence
    private val allowlist = ConcurrentHashMap.newKeySet<String>()

    // Custom user blocklist
    private val blocklist = ConcurrentHashMap.newKeySet<String>()

    // Categorized Rule sets
    private val adDomains = ConcurrentHashMap.newKeySet<String>()
    private val trackerDomains = ConcurrentHashMap.newKeySet<String>()
    private val malwareDomains = ConcurrentHashMap.newKeySet<String>()
    private val explicitDomains = ConcurrentHashMap.newKeySet<String>()

    // Configuration flags
    @Volatile var isAdBlockingEnabled: Boolean = true
    @Volatile var isTrackerBlockingEnabled: Boolean = true
    @Volatile var isMalwareBlockingEnabled: Boolean = true
    @Volatile var isExplicitBlockingEnabled: Boolean = true
    @Volatile var isChildProtectionMode: Boolean = false

    // Real-time aggregate statistics (ZERO URL logging, counters only)
    val adsBlockedCounter = AtomicLong(0)
    val trackersBlockedCounter = AtomicLong(0)
    val malwareBlockedCounter = AtomicLong(0)
    val explicitBlockedCounter = AtomicLong(0)
    val totalQueriesCounter = AtomicLong(0)

    init {
        // Seed default high-impact protection domains
        seedDefaultRules()
    }

    fun checkDomain(domain: String): DomainDecision {
        totalQueriesCounter.incrementAndGet()
        val cleanDomain = domain.trim().lowercase().removeSuffix(".")

        // 1. Check Allowlist (Explicit user bypass)
        if (isDomainInSet(cleanDomain, allowlist)) {
            return DomainDecision(cleanDomain, false, null, "Allowlisted by user")
        }

        // 2. Check Custom Blocklist
        if (isDomainInSet(cleanDomain, blocklist)) {
            adsBlockedCounter.incrementAndGet()
            return DomainDecision(cleanDomain, true, BlockCategory.CUSTOM_BLOCKLIST, "User blocklist")
        }

        // 3. Check Malware / Phishing (High Priority Security)
        if (isMalwareBlockingEnabled && isDomainInSet(cleanDomain, malwareDomains)) {
            malwareBlockedCounter.incrementAndGet()
            return DomainDecision(cleanDomain, true, BlockCategory.MALWARE, "Malicious or phishing domain detected")
        }

        // 4. Check Explicit / Adult Content (Child & Family Safety)
        if ((isExplicitBlockingEnabled || isChildProtectionMode) && isDomainInSet(cleanDomain, explicitDomains)) {
            explicitBlockedCounter.incrementAndGet()
            return DomainDecision(cleanDomain, true, BlockCategory.EXPLICIT, "Explicit/Adult domain blocked")
        }

        // 5. Check Trackers & Telemetry
        if (isTrackerBlockingEnabled && isDomainInSet(cleanDomain, trackerDomains)) {
            trackersBlockedCounter.incrementAndGet()
            return DomainDecision(cleanDomain, true, BlockCategory.TRACKER, "Privacy tracker blocked")
        }

        // 6. Check Advertising Networks
        if (isAdBlockingEnabled && isDomainInSet(cleanDomain, adDomains)) {
            adsBlockedCounter.incrementAndGet()
            return DomainDecision(cleanDomain, true, BlockCategory.AD, "Ad network blocked")
        }

        // Passed all filters: Allowed
        return DomainDecision(cleanDomain, false, null, null)
    }

    /**
     * Checks if domain or any of its parent subdomains (e.g. ad.doubleclick.net -> doubleclick.net) matches the set.
     */
    private fun isDomainInSet(domain: String, set: Set<String>): Boolean {
        if (set.contains(domain)) return true

        var sub = domain
        while (sub.contains(".")) {
            val nextDot = sub.indexOf('.')
            sub = sub.substring(nextDot + 1)
            if (set.contains(sub)) return true
        }
        return false
    }

    fun updateAllowlist(domains: List<String>) {
        allowlist.clear()
        allowlist.addAll(domains.map { it.trim().lowercase() })
    }

    fun updateBlocklist(domains: List<String>) {
        blocklist.clear()
        blocklist.addAll(domains.map { it.trim().lowercase() })
    }

    fun loadRuleSet(category: BlockCategory, rules: List<String>) {
        val targetSet = when (category) {
            BlockCategory.AD -> adDomains
            BlockCategory.TRACKER -> trackerDomains
            BlockCategory.MALWARE -> malwareDomains
            BlockCategory.EXPLICIT -> explicitDomains
            BlockCategory.CUSTOM_BLOCKLIST -> blocklist
        }
        targetSet.clear()
        targetSet.addAll(rules.map { it.trim().lowercase() })
    }

    fun getStats(): FilterStats {
        return FilterStats(
            adsBlocked = adsBlockedCounter.get(),
            trackersBlocked = trackersBlockedCounter.get(),
            malwareBlocked = malwareBlockedCounter.get(),
            explicitBlocked = explicitBlockedCounter.get(),
            totalQueries = totalQueriesCounter.get()
        )
    }

    fun resetStats() {
        adsBlockedCounter.set(0)
        trackersBlockedCounter.set(0)
        malwareBlockedCounter.set(0)
        explicitBlockedCounter.set(0)
        totalQueriesCounter.set(0)
    }

    private fun seedDefaultRules() {
        // Default High-Frequency Ad Domains
        adDomains.addAll(listOf(
            "doubleclick.net", "googleads.g.doubleclick.net", "pagead2.googlesyndication.com",
            "adservice.google.com", "adcolony.com", "unityads.unity3d.com", "applovin.com",
            "vungle.com", "mopub.com", "inmobi.com", "ironsrc.com", "taboola.com",
            "outbrain.com", "adnxs.com", "rubiconproject.com", "criteo.com", "popads.net",
            "adroll.com", "zedo.com", "bidswitch.net", "pubmatic.com", "openx.net"
        ))

        // Default High-Frequency Tracker Domains
        trackerDomains.addAll(listOf(
            "google-analytics.com", "analytics.google.com", "firebaseinstallations.googleapis.com",
            "app-measurement.com", "segment.io", "mixpanel.com", "amplitude.com",
            "branch.io", "adjust.com", "appsflyer.com", "hotjar.com", "crazyegg.com",
            "statcounter.com", "quantserve.com", "scorecardresearch.com", "facebook.net",
            "connect.facebook.net", "telemetry.sdk.inmobi.com", "ads-twitter.com"
        ))

        // Default Known Malware & Phishing Domains
        malwareDomains.addAll(listOf(
            "malware-traffic-analysis.net", "phishing-bank-secure.com", "paypa1-update-account.com",
            "apple-id-verify-security.org", "trojan-distribution-cdn.com", "ransomware-payment.biz",
            "crypto-drainer-secure.xyz", "free-giftcard-generator.top", "account-alert-security-update.com"
        ))

        // Default Adult & Explicit Content Domains
        explicitDomains.addAll(listOf(
            "pornhub.com", "xvideos.com", "xnxx.com", "redtube.com", "youporn.com",
            "xhamster.com", "chaturbate.com", "onlyfans.com", "adultfriendfinder.com",
            "brazzers.com", "stripchat.com", "livejasmin.com", "cams.com", "erome.com"
        ))
    }
}
