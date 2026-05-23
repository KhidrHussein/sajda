package com.sajda.sajda_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.core.app.NotificationCompat
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.MotionEvent
import android.view.WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
import androidx.appcompat.app.AlertDialog
import android.view.ContextThemeWrapper
import androidx.appcompat.R as AppCompatR
import java.util.Timer
import java.util.TimerTask

class LockOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var prayerName: String = ""
    private var lockDuration: Int = 600 // 10 minutes in seconds
    private var lockEndTime: Long = 0
    private var lockTimer: Timer? = null
    private var holdTimer: Timer? = null
    private var holdSeconds: Int = 0
    private var isHolding: Boolean = false
    private var quoteIndices: IntArray = IntArray(0)
    private var currentQuoteIndex = 0

    private val quotes = arrayOf(
        Pair("Indeed, prayer has been decreed upon the believers a decree of specified times.", "Quran 4:103"),
        Pair("And seek help through patience and prayer, and indeed, it is difficult except for the humbly submissive.", "Quran 2:45"),
        Pair("Successful indeed are the believers, those who offer their prayers with all solemnity.", "Quran 23:1-2"),
        Pair("The most beloved of deeds to Allah are: Prayer offered on time.", "Sahih al-Bukhari"),
        Pair("A person is closest to his Lord when he is in prostration.", "Sahih Muslim"),
        Pair("The coolness of my eyes has been placed in the prayer.", "Sunan an-Nasa'i"),
        Pair("Whenever you stand for your prayer, pray as if it is your farewell prayer.", "Sunan Ibn Majah")
    )

    private var nextPrayerText: String? = null

    companion object {
        private const val CHANNEL_ID = "sajda_lock_channel"
        private const val NOTIFICATION_ID = 1
        const val ACTION_START_LOCK = "com.sajda.START_LOCK"
        const val ACTION_STOP_LOCK = "com.sajda.STOP_LOCK"
        const val EXTRA_PRAYER_NAME = "prayer_name"
        const val EXTRA_LOCK_DURATION = "lock_duration"
        const val EXTRA_TRIGGER_AT = "trigger_at"
        const val EXTRA_NEXT_PRAYER_TEXT = "next_prayer_text"
        
        var isOverlayActive = false
            private set

        fun startLock(context: Context, prayerName: String, duration: Int, triggerAt: Long = System.currentTimeMillis(), nextPrayerText: String? = null) {
            val intent = Intent(context, LockOverlayService::class.java).apply {
                action = ACTION_START_LOCK
                putExtra(EXTRA_PRAYER_NAME, prayerName)
                putExtra(EXTRA_LOCK_DURATION, duration)
                putExtra(EXTRA_TRIGGER_AT, triggerAt)
                if (nextPrayerText != null) {
                    putExtra(EXTRA_NEXT_PRAYER_TEXT, nextPrayerText)
                }
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                Log.e("LockOverlayService", "Failed to start service: \${e.message}")
            }
        }

        fun stopLock(context: Context) {
            val intent = Intent(context, LockOverlayService::class.java).apply {
                action = ACTION_STOP_LOCK
            }
            context.startService(intent)
        }
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("LockOverlayService", "onCreate called")
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("LockOverlayService", "onStartCommand action: ${intent?.action}")
        when (intent?.action) {
            ACTION_START_LOCK -> {
                prayerName = intent.getStringExtra(EXTRA_PRAYER_NAME) ?: "Prayer"
                lockDuration = intent.getIntExtra(EXTRA_LOCK_DURATION, 600)
                nextPrayerText = intent.getStringExtra(EXTRA_NEXT_PRAYER_TEXT)
                val triggerAt = intent.getLongExtra(EXTRA_TRIGGER_AT, System.currentTimeMillis())
                lockEndTime = triggerAt + (lockDuration * 1000L)
                
                if (System.currentTimeMillis() >= lockEndTime) {
                    Log.d("LockOverlayService", "Lock time passed. Stopping lock.")
                    stopLock()
                    return START_NOT_STICKY
                }
                
                Log.d("LockOverlayService", "Starting lock for $prayerName with duration $lockDuration")
                startForeground(NOTIFICATION_ID, createNotification())
                showOverlay()
            }
            ACTION_STOP_LOCK -> {
                Log.d("LockOverlayService", "Stopping lock")
                hideOverlay()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Sajda Lock",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notification for prayer lock"
            }
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Sajda Lock Active")
            .setContentText("Take this time to pray")
            .setSmallIcon(android.R.drawable.ic_lock_idle_lock)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setOngoing(true)
            .build()
    }

    private fun showOverlay() {
        if (overlayView != null) return

        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        overlayView = LayoutInflater.from(this).inflate(R.layout.lock_overlay, null)

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                @Suppress("DEPRECATION")
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_FULLSCREEN
                or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN
                or WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                or WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.CENTER

        overlayView?.findViewById<TextView>(R.id.prayerNameTextView)?.text = "$prayerName is happening now."
        val initialRemaining = ((lockEndTime - System.currentTimeMillis()) / 1000).toInt()
        overlayView?.findViewById<TextView>(R.id.timerTextView)?.text = formatTime(maxOf(0, initialRemaining))

        if (quoteIndices.isEmpty()) {
            quoteIndices = IntArray(quotes.size) { it }
            quoteIndices.shuffle()
        }
        val initialQuote = quotes[quoteIndices[currentQuoteIndex]]
        overlayView?.findViewById<TextView>(R.id.quoteTextView)?.text = initialQuote.first
        overlayView?.findViewById<TextView>(R.id.quoteSourceTextView)?.text = initialQuote.second

        val nextPrayerTextView = overlayView?.findViewById<TextView>(R.id.nextPrayerTextView)
        if (nextPrayerText != null) {
            nextPrayerTextView?.text = nextPrayerText
            nextPrayerTextView?.visibility = View.VISIBLE
        } else {
            nextPrayerTextView?.visibility = View.GONE
        }

        val skipButton = overlayView?.findViewById<TextView>(R.id.skipButton)
        skipButton?.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    startHold(skipButton!!)
                    true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    stopHold(skipButton!!)
                    true
                }
                else -> false
            }
        }

        isOverlayActive = true
        startCountdown()

        Log.d("LockOverlayService", "Adding view to window manager")
        windowManager?.addView(overlayView, params)
    }

    private fun startHold(button: TextView) {
        isHolding = true
        holdSeconds = 0
        holdTimer?.cancel()
        holdTimer = Timer()
        holdTimer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                holdSeconds++
                Handler(Looper.getMainLooper()).post {
                    if (holdSeconds >= 60) {
                        holdTimer?.cancel()
                        showSkipConfirmation()
                    } else {
                        button.text = "Hold (${60 - holdSeconds}s)"
                        button.setTextColor(0xFF8E4A49.toInt()) // AppColors.actionDestructive
                    }
                }
            }
        }, 1000, 1000)
    }

    private fun stopHold(button: TextView) {
        isHolding = false
        holdTimer?.cancel()
        holdTimer = null
        button.text = "Press and hold to exit"
        button.setTextColor(0xFFA0A6A9.toInt()) // AppColors.textSecondaryDark
    }

    private fun startCountdown() {
        lockTimer?.cancel()
        lockTimer = Timer()
        var ticks = 0
        
        lockTimer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                ticks++
                val remainingMillis = lockEndTime - System.currentTimeMillis()
                val remainingSecs = (remainingMillis / 1000).toInt()
                
                if (remainingSecs <= 0) {
                    Handler(Looper.getMainLooper()).post { stopLock() }
                } else {
                    // Update timer display on main thread
                    Handler(Looper.getMainLooper()).post {
                        overlayView?.findViewById<TextView>(R.id.timerTextView)?.text = formatTime(remainingSecs)
                        
                        if (ticks % 30 == 0) {
                            currentQuoteIndex++
                            if (currentQuoteIndex >= quoteIndices.size) {
                                quoteIndices.shuffle()
                                currentQuoteIndex = 0
                            }
                            val nextQuote = quotes[quoteIndices[currentQuoteIndex]]
                            overlayView?.findViewById<TextView>(R.id.quoteTextView)?.text = nextQuote.first
                            overlayView?.findViewById<TextView>(R.id.quoteSourceTextView)?.text = nextQuote.second
                        }
                    }
                }
            }
        }, 1000, 1000) // Update every second
    }

    private fun hideOverlay() {
        isOverlayActive = false
        lockTimer?.cancel()
        overlayView?.let {
            windowManager?.removeView(it)
            overlayView = null
        }
    }

    private fun stopLock() {
        hideOverlay()
        
        // Launch Flutter app to show reflection screen
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("show_reflection", true)
            putExtra("prayer_name", prayerName)
        }
        startActivity(intent)

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun showSkipConfirmation() {
        // Use ContextThemeWrapper to avoid the Theme.AppCompat crash
        val contextWrapper = ContextThemeWrapper(this, androidx.appcompat.R.style.Theme_AppCompat_Dialog)
        val builder = android.app.AlertDialog.Builder(contextWrapper)
            .setTitle("Skip this prayer lock?")
            .setMessage("Are you sure you want to skip this prayer lock?\n\nThis will mark the prayer as missed.")
            .setPositiveButton("Skip") { _, _ ->
                stopLock()
            }
            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
            }

        val dialog = builder.create()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            dialog.window?.setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY)
        } else {
            @Suppress("DEPRECATION")
            dialog.window?.setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT)
        }
        dialog.show()
    }

    private fun formatTime(seconds: Int): String {
        val minutes = seconds / 60
        val secs = seconds % 60
        return String.format("%02d:%02d", minutes, secs)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        holdTimer?.cancel()
        hideOverlay()
    }
}
