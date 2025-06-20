package com.support_libs.readotp

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Telephony
import android.telephony.SmsMessage
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel

/**
 * Plugin to listen for incoming OTP SMS messages and stream them to Flutter via EventChannel.
 */
class ReadOtpPlugin : FlutterPlugin, EventChannel.StreamHandler, BroadcastReceiver(), ActivityAware {
    // EventChannel for communicating with Flutter
    private var eventChannel: EventChannel? = null
    // Sink to send events to Flutter
    private var eventSink: EventChannel.EventSink? = null
    // Context for registering the broadcast receiver
    private lateinit var context: Context
    // Activity reference (if needed for future use)
    private lateinit var activity: Activity

    /**
     * Called when the plugin is attached to the Flutter engine.
     * Registers the SMS broadcast receiver and sets up the EventChannel.
     */
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        // Register receiver for SMS_RECEIVED broadcasts
        context.registerReceiver(this, IntentFilter("android.provider.Telephony.SMS_RECEIVED"))
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "readotp")
        eventChannel!!.setStreamHandler(this)
    }

    /**
     * Called when Flutter starts listening to the EventChannel.
     */
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    /**
     * Called when Flutter cancels listening to the EventChannel.
     */
    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    /**
     * Receives incoming SMS broadcasts and processes OTP messages.
     */
    override fun onReceive(context: Context?, intent: Intent?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT && intent != null) {
            // Extract SMS messages from the intent
            val smsList = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            // Group messages by sender (originating address)
            val messagesGroupedBySender = smsList.groupBy { it.originatingAddress }
            // Process each group of messages
            messagesGroupedBySender.forEach { group ->
                processIncomingSms(group.value)
            }
        }
    }

    /**
     * Processes a list of SMS messages from the same sender and sends the result to Flutter.
     */
    private fun processIncomingSms(smsList: List<SmsMessage>) {
        if (smsList.isEmpty()) return
        val messageMap = smsList.first().toMap()
        // Concatenate message bodies if multipart
        smsList.drop(1).forEach { smsMessage ->
            messageMap["message_body"] = (messageMap["message_body"] as String) + smsMessage.messageBody.trim()
        }
        // Prepare result as a list for Flutter
        val resultSms = listOf(
            messageMap["message_body"],
            messageMap["originating_address"],
            messageMap["timestamp"]
        )
        eventSink?.success(resultSms)
    }

    /**
     * Extension function to convert an SmsMessage to a HashMap.
     */
    private fun SmsMessage.toMap(): HashMap<String, Any?> {
        return hashMapOf(
            "message_body" to messageBody,
            "timestamp" to timestampMillis.toString(),
            "originating_address" to originatingAddress,
            "status" to status.toString(),
            "service_center_address" to serviceCenterAddress
        )
    }

    /**
     * Called when the plugin is detached from the Flutter engine.
     * Cleans up resources.
     */
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel = null
        eventSink = null
    }

    /**
     * Called when the plugin is attached to an Activity.
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // No-op
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // No-op
    }

    override fun onDetachedFromActivity() {
        // No-op
    }
}
