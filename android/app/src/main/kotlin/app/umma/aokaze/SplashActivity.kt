package app.umma.aokaze

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.appcompat.app.AppCompatActivity

class SplashActivity : AppCompatActivity() {

    companion object {
        private const val TAG = "SplashActivity"
        private const val SPLASH_TIMEOUT_MS = 2000L
        private const val PRAYER_CHANNEL_ID = "umma_prayer_times_v2"
        private const val PRAYER_CHANNEL_NAME = "Waktu Sholat"
    }

    private var handler: Handler? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.NormalTheme)
        super.onCreate(savedInstanceState)
        setContentView(R.layout.splash_lottie)

        // Buat notification channel dengan system alarm ringtone SEBELUM Flutter start
        createPrayerNotificationChannel()

        handler = Handler(Looper.getMainLooper())
        handler?.postDelayed({
            navigateToMain()
        }, SPLASH_TIMEOUT_MS)
    }

    override fun onDestroy() {
        handler?.removeCallbacksAndMessages(null)
        handler = null
        super.onDestroy()
    }

    private fun navigateToMain() {
        if (isFinishing || isDestroyed) return
        try {
            startActivity(Intent(this, MainActivity::class.java))
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out)
            finish()
        } catch (e: Exception) {
            Log.e(TAG, "Navigation failed: ${e.message}")
        }
    }

    private fun createPrayerNotificationChannel() {
        try {
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

            // Gunakan system alarm ringtone (ringtone yg sudah di-set user di Pengaturan)
            val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)

            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    PRAYER_CHANNEL_ID,
                    PRAYER_CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Notifikasi waktu sholat harian"
                    setSound(alarmUri, audioAttributes)
                    enableVibration(true)
                    enableLights(true)
                    setShowBadge(true)
                }

                notificationManager.createNotificationChannel(channel)
                Log.d(TAG, "Prayer notification channel created with alarm ringtone")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create prayer notification channel: ${e.message}")
        }
    }
}
