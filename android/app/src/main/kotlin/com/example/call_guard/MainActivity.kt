package com.example.call_guard

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "call_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).also { channel ->
            CallReceiver.methodChannel = channel // Assign to CallReceiver
            channel.setMethodCallHandler { call, result ->
                if (call.method == "initialize") {
                    result.success(null)
                }
            }
        }
    }
}
