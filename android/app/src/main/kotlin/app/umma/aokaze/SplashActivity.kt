package app.umma.aokaze

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.appcompat.app.AppCompatActivity

class SplashActivity : AppCompatActivity() {

    companion object {
        private const val TAG = "SplashActivity"
        private const val SPLASH_TIMEOUT_MS = 2000L
    }

    private var handler: Handler? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.NormalTheme)
        super.onCreate(savedInstanceState)
        setContentView(R.layout.splash_lottie)

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
}
