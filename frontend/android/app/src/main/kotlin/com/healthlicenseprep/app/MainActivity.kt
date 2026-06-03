package com.healthlicenseprep.app

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.webkit.WebView
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewFeature

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Enable Payment Request API globally for WebViews (required for Google Pay)
        try {
            if (WebViewFeature.isFeatureSupported(WebViewFeature.PAYMENT_REQUEST)) {
                // This enables Payment Request API for all WebViews in the app
                val webView = WebView(this)
                WebSettingsCompat.setPaymentRequestEnabled(webView.settings, true)
                webView.destroy()
            }
        } catch (e: Exception) {
            // Silently fail if WebView doesn't support this feature
            e.printStackTrace()
        }
    }
}
