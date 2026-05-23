package com.sajda.sajda_app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class LockAccessibilityService : AccessibilityService() {

    companion object {
        var isServiceRunning = false
        private set
        
        fun shouldBlockApp(packageName: String): Boolean {
            // Don't block system apps, emergency apps, or the sajda app itself
            val allowedPackages = setOf(
                "com.android.systemui",
                "com.android.dialer",
                "com.android.emergency",
                "com.android.phone",
                "com.sajda.sajda_app"
            )
            
            // Allow emergency calls and system UI
            return !allowedPackages.contains(packageName) && 
                   !packageName.startsWith("com.android.settings") &&
                   !packageName.contains("emergency")
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        isServiceRunning = true
        
        val info = AccessibilityServiceInfo().apply {
            // We want to receive events when windows change
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            notificationTimeout = 100
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            if (it.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                val packageName = it.packageName?.toString()
                
                if (packageName != null && shouldBlockApp(packageName)) {
                    // Check if lock overlay is active
                    if (LockOverlayService.isOverlayActive) {
                        // Go back to home screen or sajda app
                        performGlobalAction(GLOBAL_ACTION_HOME)
                        
                        // Optional: bring sajda app to front
                        // This would require a more complex implementation
                    }
                }
            }
        }
    }

    override fun onInterrupt() {
        // Service interrupted
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceRunning = false
    }
}
