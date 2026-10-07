package com.beoff.app.bridge

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.VpnService
import androidx.core.content.ContextCompat
import com.beoff.app.ml.ContentSafetyClassifier
import com.beoff.app.vpn.BeOffVpnService
import com.beoff.app.vpn.BlockCategory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class BeOffBridgePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {

    companion object {
        const val METHOD_CHANNEL_NAME = "com.beoff.app/control"
        const val EVENT_CHANNEL_STATS = "com.beoff.app/stats_stream"
        const val REQUEST_CODE_VPN = 1002
    }

    private var applicationContext: Context? = null
    private var currentActivity: Activity? = null
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var vpnPendingResult: MethodChannel.Result? = null

    private val classifier = ContentSafetyClassifier()
    private val scope = CoroutineScope(Dispatchers.Main)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL_NAME).apply {
            setMethodCallHandler(this@BeOffBridgePlugin)
        }
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL_STATS).apply {
            setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    // Send periodic or event-driven real-time stats
                    events?.success(getStatsMap())
                }

                override fun onCancel(arguments: Any?) {}
            })
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        methodChannel = null
        eventChannel = null
        applicationContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        currentActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        currentActivity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        currentActivity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startProtection" -> {
                val context = applicationContext ?: run {
                    result.error("NO_CONTEXT", "Application context is null", null)
                    return
                }
                val activity = currentActivity
                val prepareIntent = VpnService.prepare(context)

                if (prepareIntent != null) {
                    if (activity != null) {
                        vpnPendingResult = result
                        activity.startActivityForResult(prepareIntent, REQUEST_CODE_VPN)
                    } else {
                        result.error("NO_ACTIVITY", "Cannot request VPN permission without activity", null)
                    }
                } else {
                    // VPN permission already granted
                    startVpnServiceInternal(context)
                    result.success(true)
                }
            }

            "stopProtection" -> {
                val context = applicationContext ?: run {
                    result.error("NO_CONTEXT", "Application context is null", null)
                    return
                }
                val stopIntent = Intent(context, BeOffVpnService::class.java).apply {
                    action = BeOffVpnService.ACTION_STOP
                }
                context.startService(stopIntent)
                result.success(true)
            }

            "isProtectionActive" -> {
                result.success(BeOffVpnService.isRunning.get())
            }

            "getProtectionStats" -> {
                result.success(getStatsMap())
            }

            "resetProtectionStats" -> {
                BeOffVpnService.filterEngine.resetStats()
                result.success(true)
            }

            "updateRules" -> {
                val categoryName = call.argument<String>("category") ?: "AD"
                val rules = call.argument<List<String>>("rules") ?: emptyList()
                val category = try {
                    BlockCategory.valueOf(categoryName.uppercase())
                } catch (e: Exception) {
                    BlockCategory.AD
                }
                BeOffVpnService.filterEngine.loadRuleSet(category, rules)
                result.success(true)
            }

            "updateAllowlist" -> {
                val domains = call.argument<List<String>>("domains") ?: emptyList()
                BeOffVpnService.filterEngine.updateAllowlist(domains)
                result.success(true)
            }

            "updateBlocklist" -> {
                val domains = call.argument<List<String>>("domains") ?: emptyList()
                BeOffVpnService.filterEngine.updateBlocklist(domains)
                result.success(true)
            }

            "configureToggles" -> {
                val adBlock = call.argument<Boolean>("adBlock") ?: true
                val trackerBlock = call.argument<Boolean>("trackerBlock") ?: true
                val malwareBlock = call.argument<Boolean>("malwareBlock") ?: true
                val explicitBlock = call.argument<Boolean>("explicitBlock") ?: true
                val childMode = call.argument<Boolean>("childMode") ?: false

                val engine = BeOffVpnService.filterEngine
                engine.isAdBlockingEnabled = adBlock
                engine.isTrackerBlockingEnabled = trackerBlock
                engine.isMalwareBlockingEnabled = malwareBlock
                engine.isExplicitBlockingEnabled = explicitBlock
                engine.isChildProtectionMode = childMode
                result.success(true)
            }

            "classifyImage" -> {
                val imageBytes = call.argument<ByteArray>("imageBytes") ?: ByteArray(0)
                val sensitivity = call.argument<String>("sensitivity") ?: "HIGH"
                classifier.sensitivityLevel = sensitivity

                scope.launch {
                    val classification = withContext(Dispatchers.Default) {
                        classifier.classifyImageBytes(imageBytes)
                    }
                    result.success(
                        mapOf(
                            "category" to classification.category.name,
                            "confidence" to classification.confidence,
                            "isUnsafe" to classification.isUnsafe,
                            "shouldBlur" to classification.shouldBlur,
                            "shouldBlock" to classification.shouldBlock,
                            "executionTimeMs" to classification.executionTimeMs
                        )
                    )
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun startVpnServiceInternal(context: Context) {
        val startIntent = Intent(context, BeOffVpnService::class.java).apply {
            action = BeOffVpnService.ACTION_START
        }
        ContextCompat.startForegroundService(context, startIntent)
    }

    private fun getStatsMap(): Map<String, Any> {
        val stats = BeOffVpnService.filterEngine.getStats()
        return mapOf(
            "adsBlocked" to stats.adsBlocked,
            "trackersBlocked" to stats.trackersBlocked,
            "malwareBlocked" to stats.malwareBlocked,
            "explicitBlocked" to stats.explicitBlocked,
            "totalQueries" to stats.totalQueries,
            "isActive" to BeOffVpnService.isRunning.get()
        )
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CODE_VPN) {
            if (resultCode == Activity.RESULT_OK) {
                applicationContext?.let { startVpnServiceInternal(it) }
                vpnPendingResult?.success(true)
            } else {
                vpnPendingResult?.error("PERMISSION_DENIED", "User denied VPN permission", null)
            }
            vpnPendingResult = null
            return true
        }
        return false
    }
}
