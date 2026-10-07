package com.beoff.app.vpn

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            val prefs = context.getSharedPreferences("beoff_prefs", Context.MODE_PRIVATE)
            val shouldAutoStart = prefs.getBoolean("protection_enabled", false)

            if (shouldAutoStart) {
                val serviceIntent = Intent(context, BeOffVpnService::class.java).apply {
                    action = BeOffVpnService.ACTION_START
                }
                ContextCompat.startForegroundService(context, serviceIntent)
            }
        }
    }
}
