package com.beoff.app.ml

enum class SafetyCategory {
    SAFE,
    SUGGESTIVE,
    NUDITY,
    EXPLICIT,
    UNKNOWN
}

data class SafetyClassification(
    val category: SafetyCategory,
    val confidence: Float,
    val isUnsafe: Boolean,
    val shouldBlur: Boolean,
    val shouldBlock: Boolean,
    val executionTimeMs: Long
)
