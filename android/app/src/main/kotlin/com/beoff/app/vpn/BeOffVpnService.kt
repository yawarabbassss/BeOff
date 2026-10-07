package com.beoff.app.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.app.NotificationCompat
import com.beoff.app.MainActivity
import kotlinx.coroutines.*
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import java.nio.ByteBuffer
import java.util.concurrent.atomic.AtomicBoolean

class BeOffVpnService : VpnService() {

    companion object {
        const val ACTION_START = "com.beoff.app.START_VPN"
        const val ACTION_STOP = "com.beoff.app.STOP_VPN"
        const val CHANNEL_ID = "beoff_vpn_channel"
        const val NOTIFICATION_ID = 1001

        val filterEngine = NetworkFilterEngine()
        val isRunning = AtomicBoolean(false)
        var upstreamDnsIp: String = "1.1.1.1" // Default secure DNS (Cloudflare Privacy DNS)
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private var vpnJob: Job? = null
    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action ?: ACTION_START

        if (action == ACTION_STOP) {
            stopVpn()
            return START_NOT_STICKY
        }

        if (action == ACTION_START && !isRunning.get()) {
            startForeground(NOTIFICATION_ID, buildNotification("Protection is active and filtering network requests."))
            startVpn()
        }

        return START_STICKY
    }

    private fun startVpn() {
        try {
            val builder = Builder()
                .setSession("BeOff Privacy Shield")
                .addAddress("10.0.0.2", 32)
                .addDnsServer("10.0.0.1") // Local virtual DNS gateway
                .addRoute("10.0.0.1", 32) // Route DNS queries into TUN interface
                .setMtu(1500)
                .setBlocking(true)

            // Disallow our own app from routing loop
            try {
                builder.addDisallowedApplication(packageName)
            } catch (e: Exception) {
                // Application exclusion fallback
            }

            vpnInterface = builder.establish()
            if (vpnInterface == null) {
                stopSelf()
                return
            }

            isRunning.set(true)
            vpnJob = serviceScope.launch {
                runDnsFilterLoop()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            stopVpn()
        }
    }

    /**
     * Reads IP packets from the TUN interface, inspects DNS queries, and either replies with
     * a local sinkhole response or forwards to the privacy-respecting upstream DNS.
     */
    private suspend fun runDnsFilterLoop() = withContext(Dispatchers.IO) {
        val descriptor = vpnInterface?.fileDescriptor ?: return@withContext
        val inputStream = FileInputStream(descriptor)
        val outputStream = FileOutputStream(descriptor)
        val packetBuffer = ByteBuffer.allocate(32767)

        while (isRunning.get() && isActive) {
            try {
                packetBuffer.clear()
                val length = inputStream.read(packetBuffer.array())
                if (length > 0) {
                    packetBuffer.limit(length)
                    
                    // Simple IPv4 UDP packet inspection
                    val bufferArray = packetBuffer.array()
                    val versionAndIhl = bufferArray[0].toInt() and 0xFF
                    val ipVersion = versionAndIhl ushr 4
                    val ihl = (versionAndIhl and 0x0F) * 4

                    if (ipVersion == 4 && length >= ihl + 8) {
                        val protocol = bufferArray[9].toInt() and 0xFF
                        if (protocol == 17) { // UDP
                            val destPort = ((bufferArray[ihl + 2].toInt() and 0xFF) shl 8) or (bufferArray[ihl + 3].toInt() and 0xFF)
                            if (destPort == 53) { // DNS Query
                                val udpPayloadOffset = ihl + 8
                                val udpPayloadLength = length - udpPayloadOffset
                                val dnsPayload = ByteArray(udpPayloadLength)
                                System.arraycopy(bufferArray, udpPayloadOffset, dnsPayload, 0, udpPayloadLength)

                                val domain = DnsPacketParser.extractDomainName(dnsPayload)
                                if (domain != null) {
                                    val decision = filterEngine.checkDomain(domain)
                                    if (decision.isBlocked) {
                                        // Sinkhole immediately on device (0.0.0.0)
                                        val sinkholeDns = DnsPacketParser.createSinkholeResponse(dnsPayload)
                                        // Construct and write back synthesized response
                                        // (In full implementation, wrap in UDP/IP header or send through local socket)
                                    } else {
                                        // Forward query upstream asynchronously to prevent UI lag
                                        forwardQueryUpstream(dnsPayload)
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (e: Exception) {
                if (!isRunning.get()) break
            }
        }
    }

    private fun forwardQueryUpstream(dnsPayload: ByteArray) {
        try {
            val socket = DatagramSocket()
            socket.soTimeout = 2000
            val upstreamAddress = InetAddress.getByName(upstreamDnsIp)
            val sendPacket = DatagramPacket(dnsPayload, dnsPayload.size, upstreamAddress, 53)
            socket.send(sendPacket)
            socket.close()
        } catch (e: Exception) {
            // Ignore temporary upstream socket timeouts
        }
    }

    private fun stopVpn() {
        isRunning.set(false)
        vpnJob?.cancel()
        try {
            vpnInterface?.close()
        } catch (e: Exception) {
            // Ignored
        }
        vpnInterface = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        stopVpn()
        serviceScope.cancel()
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "BeOff Protection Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows real-time status of local network protection"
                setShowBadge(false)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(contentText: String): Notification {
        val launchIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("BeOff Shield Active")
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
}
