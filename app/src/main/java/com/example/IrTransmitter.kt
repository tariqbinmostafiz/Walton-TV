package com.example

import android.content.Context
import android.hardware.ConsumerIrManager

class IrTransmitter(context: Context) {

    companion object {
        private const val CARRIER_FREQUENCY = 38000

        private const val HEADER_MARK = 9000
        private const val HEADER_SPACE = 4500

        private const val BIT_MARK = 560
        private const val ZERO_SPACE = 560
        private const val ONE_SPACE = 1690

        private const val TRAILER_MARK = 560
    }

    private val irManager =
        context.getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager

    fun hasIrEmitter(): Boolean {
        return irManager?.hasIrEmitter() == true
    }

    fun sendCommand(command: Int): Boolean {
        val manager = irManager ?: return false

        if (!manager.hasIrEmitter()) {
            return false
        }

        require(command in 0..0xFF) {
            "Command must be between 0x00 and 0xFF"
        }

        val inverse = command xor 0xFF

        val bytes = intArrayOf(
            0x00,
            0xBC,
            command,
            inverse
        )

        val pattern = ArrayList<Int>(67)

        // Header: 9000µs mark + 4500µs space
        pattern.add(HEADER_MARK)
        pattern.add(HEADER_SPACE)

        // 32-bit payload transmitted TRUE LSB (bit 0 first)
        for (value in bytes) {
            for (bit in 0 until 8) {
                val one = ((value shr bit) and 0x01) == 1

                pattern.add(BIT_MARK)

                if (one) {
                    pattern.add(ONE_SPACE)
                } else {
                    pattern.add(ZERO_SPACE)
                }
            }
        }

        // Trailer mark: 560µs
        pattern.add(TRAILER_MARK)

        manager.transmit(
            CARRIER_FREQUENCY,
            pattern.toIntArray()
        )

        return true
    }
}
