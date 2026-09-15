package com.shifat.waltontvremote

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "walton_tv_ir"
    private lateinit var irTransmitter: IrTransmitter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        irTransmitter = IrTransmitter(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasIrEmitter" -> {
                    result.success(irTransmitter.hasIrEmitter())
                }

                "sendCommand" -> {
                    val command = call.argument<Int>("command")

                    if (command == null) {
                        result.error(
                            "INVALID_COMMAND",
                            "Missing command",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    if (command !in 0..0xFF) {
                        result.error(
                            "INVALID_COMMAND",
                            "Command must be 0x00..0xFF",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val success = irTransmitter.sendCommand(command)
                        result.success(success)
                    } catch (e: SecurityException) {
                        result.error(
                            "PERMISSION_DENIED",
                            "TRANSMIT_IR permission denied: ${e.message}",
                            null
                        )
                    } catch (e: IllegalStateException) {
                        result.error(
                            "NO_IR_HARDWARE",
                            e.message,
                            null
                        )
                    } catch (e: Exception) {
                        result.error(
                            "IR_TRANSMISSION_FAILED",
                            e.message ?: "Failed to transmit IR signal",
                            null
                        )
                    }
                }

                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (!url.isNullOrEmpty()) {
                        try {
                            val intent = android.content.Intent(android.content.Intent.ACTION_VIEW, android.net.Uri.parse(url))
                            intent.addFlags(android.content.Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("OPEN_URL_FAILED", e.message, null)
                        }
                    } else {
                        result.error("INVALID_URL", "URL is empty", null)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
