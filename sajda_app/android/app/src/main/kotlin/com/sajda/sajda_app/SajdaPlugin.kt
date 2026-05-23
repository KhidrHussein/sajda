package com.sajda.sajda_app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.AlarmManager
import android.app.PendingIntent

import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.NewIntentListener

class SajdaPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, NewIntentListener {
    private lateinit var permissionsChannel: MethodChannel
    private lateinit var lockChannel: MethodChannel
    private var activity: Activity? = null
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        setupChannels(binding.binaryMessenger)
    }

    private fun setupChannels(messenger: BinaryMessenger) {
        permissionsChannel = MethodChannel(messenger, "com.sajda.sajda_app/permissions")
        permissionsChannel.setMethodCallHandler(this)

        lockChannel = MethodChannel(messenger, "com.sajda.sajda_app/lock")
        lockChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        permissionsChannel.setMethodCallHandler(null)
        lockChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d("SajdaPlugin", "Method called: ${call.method}")
        when (call.method) {
            "checkOverlayPermission" -> {
                val allowed = canDrawOverlays()
                Log.d("SajdaPlugin", "checkOverlayPermission: $allowed")
                result.success(allowed)
            }
            "requestOverlayPermission" -> {
                if (canDrawOverlays()) {
                    Log.d("SajdaPlugin", "requestOverlayPermission: already allowed")
                    result.success(true)
                } else {
                    Log.d("SajdaPlugin", "requestOverlayPermission: launching intent")
                    requestOverlayPermission()
                    result.success(false)
                }
            }
            "checkBatteryOptimization" -> {
                val pm = context.getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
                val isIgnoring = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    pm.isIgnoringBatteryOptimizations(context.packageName)
                } else {
                    true
                }
                result.success(isIgnoring)
            }
            "requestBatteryOptimization" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val pm = context.getSystemService(Context.POWER_SERVICE) as android.os.PowerManager
                    if (!pm.isIgnoringBatteryOptimizations(context.packageName)) {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = Uri.parse("package:${context.packageName}")
                        }
                        activity?.startActivityForResult(intent, 1235)
                        result.success(false)
                        return
                    }
                }
                result.success(true)
            }
            "startLock" -> {
                val prayerName = call.argument<String>("prayerName") ?: "Prayer"
                val duration = (call.argument<Any>("duration") as? Number)?.toInt() ?: 600
                Log.d("SajdaPlugin", "startLock: $prayerName, $duration")
                LockOverlayService.startLock(context, prayerName, duration)
                result.success(null)
            }
            "stopLock" -> {
                Log.d("SajdaPlugin", "stopLock")
                LockOverlayService.stopLock(context)
                result.success(null)
            }
            "scheduleNativeAlarm" -> {
                val prayerName = call.argument<String>("prayerName") ?: "Prayer"
                val duration = (call.argument<Any>("duration") as? Number)?.toInt() ?: 600
                val triggerAt = (call.argument<Any>("triggerAt") as? Number)?.toLong() ?: System.currentTimeMillis()
                val nextPrayerText = call.argument<String>("nextPrayerText")
                
                scheduleNativeAlarm(prayerName, duration, triggerAt, nextPrayerText)
                result.success(true)
            }
            "getInitialIntent" -> {
                val intent = activity?.intent
                if (intent != null && intent.getBooleanExtra("show_reflection", false)) {
                    val data = mapOf(
                        "show_reflection" to true,
                        "prayer_name" to intent.getStringExtra("prayer_name")
                    )
                    result.success(data)
                } else {
                    result.success(null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onNewIntent(intent: Intent): Boolean {
        if (intent.getBooleanExtra("show_reflection", false)) {
            val prayerName = intent.getStringExtra("prayer_name")
            Log.d("SajdaPlugin", "onNewIntent: show_reflection for $prayerName")
            lockChannel.invokeMethod("onReflectionTriggered", mapOf("prayerName" to prayerName))
            return true
        }
        return false
    }

    private fun scheduleNativeAlarm(prayerName: String, duration: Int, triggerAt: Long, nextPrayerText: String?) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, LockBroadcastReceiver::class.java).apply {
            putExtra("prayerName", prayerName)
            putExtra("duration", duration)
            putExtra("triggerAt", triggerAt)
            if (nextPrayerText != null) {
                putExtra("nextPrayerText", nextPrayerText)
            }
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            prayerName.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
        }
        Log.d("SajdaPlugin", "Native alarm scheduled for $prayerName at $triggerAt")
    }

    private fun canDrawOverlays(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:${context.packageName}")
            )
            activity?.startActivityForResult(intent, 1234)
        }
    }

    // ActivityAware implementation
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
