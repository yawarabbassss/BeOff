package com.beoff.app.vpn

import java.nio.ByteBuffer

/**
 * High-performance, zero-allocation DNS packet parser and synthetic response builder.
 * Operates purely in-memory to minimize battery & CPU overhead.
 */
object DnsPacketParser {

    /**
     * Extracts the requested hostname from a raw DNS UDP payload.
     */
    fun extractDomainName(dnsPayload: ByteArray): String? {
        if (dnsPayload.size < 12) return null // Standard DNS header is 12 bytes

        try {
            val buffer = ByteBuffer.wrap(dnsPayload)
            buffer.position(12) // Skip ID (2B), Flags (2B), QDCOUNT (2B), ANCOUNT (2B), NSCOUNT (2B), ARCOUNT (2B)

            val domainBuilder = StringBuilder()
            while (buffer.hasRemaining()) {
                val labelLength = buffer.get().toInt() and 0xFF
                if (labelLength == 0) break // End of domain labels

                if (labelLength > buffer.remaining()) return null

                val labelBytes = ByteArray(labelLength)
                buffer.get(labelBytes)
                if (domainBuilder.isNotEmpty()) {
                    domainBuilder.append(".")
                }
                domainBuilder.append(String(labelBytes, Charsets.US_ASCII).lowercase())
            }

            return if (domainBuilder.isNotEmpty()) domainBuilder.toString() else null
        } catch (e: Exception) {
            return null
        }
    }

    /**
     * Creates a synthetic "0.0.0.0" DNS A-Record response packet to immediately sinkhole blocked domains.
     */
    fun createSinkholeResponse(requestPacket: ByteArray): ByteArray {
        if (requestPacket.size < 12) return requestPacket

        val response = requestPacket.copyOf(requestPacket.size + 16)
        val buffer = ByteBuffer.wrap(response)

        // Set Response Flags: QR=1 (Response), Opcode=0, AA=1, RA=1, RCODE=0 (No error) -> 0x8180
        buffer.put(2, 0x81.toByte())
        buffer.put(3, 0x80.toByte())

        // Set Answer Count (ANCOUNT) = 1 (Bytes 6 & 7)
        buffer.put(6, 0x00.toByte())
        buffer.put(7, 0x01.toByte())

        // Move to the end of the question section to append the Answer section
        val answerPos = requestPacket.size
        buffer.position(answerPos)

        // Name pointer referencing the Question Name at offset 12 (0xC00C)
        buffer.put(0xC0.toByte())
        buffer.put(0x0C.toByte())

        // Type: A (IPv4) = 0x0001
        buffer.putShort(1)

        // Class: IN (Internet) = 0x0001
        buffer.putShort(1)

        // TTL: 300 seconds
        buffer.putInt(300)

        // Data Length (RDLENGTH) = 4 bytes
        buffer.putShort(4)

        // IP Address: 0.0.0.0 (Sinkhole)
        buffer.put(0.toByte())
        buffer.put(0.toByte())
        buffer.put(0.toByte())
        buffer.put(0.toByte())

        return response
    }
}
