package com.example.we_drive_v2

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val PHONE_CHANNEL = "we_drive/phone"
    private val SMS_CHANNEL = "we_drive/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // PHONE CALL
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PHONE_CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "call") {

                val phone = call.argument<String>("phone")

                if (phone.isNullOrEmpty()) {
                    result.error(
                        "INVALID_PHONE",
                        "Phone number is missing",
                        null
                    )
                    return@setMethodCallHandler
                }

                try {
                    val intent = Intent(
                        Intent.ACTION_DIAL,
                        Uri.parse("tel:$phone")
                    )

                    startActivity(intent)
                    result.success(true)

                } catch (e: Exception) {
                    result.error(
                        "CALL_ERROR",
                        "Unable to open phone dialer",
                        e.message
                    )
                }

            } else {
                result.notImplemented()
            }
        }

        // SMS MESSAGE
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SMS_CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "message") {

                val phone = call.argument<String>("phone")

                if (phone.isNullOrEmpty()) {
                    result.error(
                        "INVALID_PHONE",
                        "Phone number is missing",
                        null
                    )
                    return@setMethodCallHandler
                }

                try {
                    val intent = Intent(
                        Intent.ACTION_SENDTO,
                        Uri.parse("smsto:$phone")
                    )

                    startActivity(intent)
                    result.success(true)

                } catch (e: Exception) {
                    result.error(
                        "SMS_ERROR",
                        "Unable to open messaging app",
                        e.message
                    )
                }

            } else {
                result.notImplemented()
            }
        }
    }
}