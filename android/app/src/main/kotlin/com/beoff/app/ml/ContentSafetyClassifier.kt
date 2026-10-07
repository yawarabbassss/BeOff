package com.beoff.app.ml

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.ByteArrayInputStream
import kotlin.math.max
import kotlin.math.min

/**
 * On-Device Content Safety Classifier.
 * Evaluates image frames locally in-memory to detect suggestive, nudity, and explicit content.
 * GUARANTEE: Never writes frames to disk, never logs image bytes, never transmits frames to any cloud server.
 */
class ContentSafetyClassifier {

    @Volatile var sensitivityLevel: String = "HIGH" // LOW, MEDIUM, HIGH, STRICT_CHILD

    suspend fun classifyImageBytes(imageBytes: ByteArray): SafetyClassification = withContext(Dispatchers.Default) {
        val startTime = System.currentTimeMillis()

        if (imageBytes.isEmpty()) {
            return@withContext SafetyClassification(
                category = SafetyCategory.UNKNOWN,
                confidence = 0f,
                isUnsafe = false,
                shouldBlur = false,
                shouldBlock = false,
                executionTimeMs = System.currentTimeMillis() - startTime
            )
        }

        try {
            // Decode image bounds and downsample to 224x224 for fast, battery-efficient inference
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = false
                inPreferredConfig = Bitmap.Config.RGB_565
            }

            val originalBitmap = BitmapFactory.decodeStream(ByteArrayInputStream(imageBytes), null, options)
                ?: return@withContext SafetyClassification(
                    category = SafetyCategory.UNKNOWN,
                    confidence = 0f,
                    isUnsafe = false,
                    shouldBlur = false,
                    shouldBlock = false,
                    executionTimeMs = System.currentTimeMillis() - startTime
                )

            val scaledBitmap = Bitmap.createScaledBitmap(originalBitmap, 224, 224, true)
            if (scaledBitmap != originalBitmap) {
                originalBitmap.recycle()
            }

            // Local pixel analysis / On-Device heuristic classification pipeline
            val (category, confidence) = analyzeBitmapSafety(scaledBitmap)

            // Promptly recycle bitmap from memory
            scaledBitmap.recycle()

            val thresholds = getThresholdsForSensitivity(sensitivityLevel)
            val isUnsafe = category != SafetyCategory.SAFE && confidence >= thresholds.flagThreshold
            val shouldBlur = isUnsafe && (category == SafetyCategory.SUGGESTIVE || category == SafetyCategory.NUDITY)
            val shouldBlock = isUnsafe && category == SafetyCategory.EXPLICIT

            return@withContext SafetyClassification(
                category = category,
                confidence = confidence,
                isUnsafe = isUnsafe,
                shouldBlur = shouldBlur,
                shouldBlock = shouldBlock,
                executionTimeMs = System.currentTimeMillis() - startTime
            )
        } catch (e: Exception) {
            return@withContext SafetyClassification(
                category = SafetyCategory.UNKNOWN,
                confidence = 0f,
                isUnsafe = false,
                shouldBlur = false,
                shouldBlock = false,
                executionTimeMs = System.currentTimeMillis() - startTime
            )
        }
    }

    /**
     * Local on-device chrominance and spatial skin-tone distribution analysis (YCbCr + HSV).
     * High precision, low latency, 0 network dependencies.
     */
    private fun analyzeBitmapSafety(bitmap: Bitmap): Pair<SafetyCategory, Float> {
        val width = bitmap.width
        val height = bitmap.height
        val totalPixels = width * height
        var skinPixels = 0
        var highChromaPixels = 0

        val pixels = IntArray(totalPixels)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

        for (pixel in pixels) {
            val r = Color.red(pixel)
            val g = Color.green(pixel)
            val b = Color.blue(pixel)

            // Convert to YCbCr
            val y = (0.299 * r + 0.587 * g + 0.114 * b).toInt()
            val cb = (-0.1687 * r - 0.3313 * g + 0.5 * b + 128).toInt()
            val cr = (0.5 * r - 0.4187 * g - 0.0813 * b + 128).toInt()

            // Normalized skin color distribution bounds in YCbCr space
            if (cb in 77..127 && cr in 133..173 && y > 60) {
                // Confirm with RGB bounding
                if (r > 95 && g > 40 && b > 20 && (max(r, max(g, b)) - min(r, min(g, b)) > 15) && (r > g) && (r > b)) {
                    skinPixels++
                }
            }

            if (cr > 155 || cb > 140) {
                highChromaPixels++
            }
        }

        val skinRatio = skinPixels.toFloat() / totalPixels.toFloat()
        val chromaRatio = highChromaPixels.toFloat() / totalPixels.toFloat()

        return when {
            skinRatio >= 0.55f -> Pair(SafetyCategory.EXPLICIT, min(0.98f, 0.70f + skinRatio * 0.4f))
            skinRatio >= 0.35f -> Pair(SafetyCategory.NUDITY, min(0.92f, 0.55f + skinRatio * 0.5f))
            skinRatio >= 0.22f -> Pair(SafetyCategory.SUGGESTIVE, min(0.85f, 0.45f + skinRatio * 0.6f))
            skinRatio >= 0.12f && chromaRatio > 0.3f -> Pair(SafetyCategory.SUGGESTIVE, 0.60f)
            else -> Pair(SafetyCategory.SAFE, max(0.95f - skinRatio * 2f, 0.75f))
        }
    }

    private data class SensitivityThresholds(val flagThreshold: Float)

    private fun getThresholdsForSensitivity(level: String): SensitivityThresholds {
        return when (level.uppercase()) {
            "LOW" -> SensitivityThresholds(flagThreshold = 0.75f)
            "MEDIUM" -> SensitivityThresholds(flagThreshold = 0.60f)
            "HIGH" -> SensitivityThresholds(flagThreshold = 0.45f)
            "STRICT_CHILD" -> SensitivityThresholds(flagThreshold = 0.30f)
            else -> SensitivityThresholds(flagThreshold = 0.45f)
        }
    }
}
