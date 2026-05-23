package com.sajda.sajda_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class LockBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val prayerName = intent.getStringExtra("prayerName") ?: "Prayer"
        val duration = intent.getIntExtra("duration", 600)
        val triggerAt = intent.getLongExtra("triggerAt", System.currentTimeMillis())
        val nextPrayerText = intent.getStringExtra("nextPrayerText")
        
        Log.d("LockBroadcastReceiver", "Native alarm received for $prayerName! Starting lock...")
        
        val endTime = triggerAt + (duration * 1000L)
        if (System.currentTimeMillis() >= endTime) {
            Log.d("LockBroadcastReceiver", "Lock time already passed for $prayerName. Skipping lock and showing reflection.")
            val reflectionIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("show_reflection", true)
                putExtra("prayer_name", prayerName)
            }
            context.startActivity(reflectionIntent)
            return
        }
        
        // Directly start the overlay service
        LockOverlayService.startLock(context, prayerName, duration, triggerAt, nextPrayerText)
    }
}
