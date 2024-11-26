package com.example.call_guard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import android.util.Log // Add this import
import io.flutter.plugin.common.MethodChannel

class CallReceiver : BroadcastReceiver() {
    companion object {
        var methodChannel: MethodChannel? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d("CallReceiver", "onReceive triggered")
        if (intent?.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            Log.d("CallReceiver", "Phone state: $state")
            if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
                Log.d("CallReceiver", "Incoming number: $incomingNumber")
                incomingNumber?.replace(" ", "")?.let { normalizedNumber ->
                    methodChannel?.invokeMethod("onIncomingCall", normalizedNumber)
                    Log.d("CallReceiver", "Method channel invoked with number: $normalizedNumber")
                }
            }
        }
    }
    
}
