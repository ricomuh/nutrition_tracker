package com.nutrifit.ai.nutrition_tracker

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.nutrifit.ai/widget_actions"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkWidgetClick" -> {
                    val shouldOpenCamera = intent.getBooleanExtra("open_quick_camera", false)
                    result.success(shouldOpenCamera)
                    // Clear the intent extra after checking
                    intent.removeExtra("open_quick_camera")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleWidgetClick()
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleWidgetClick()
    }
    
    private fun handleWidgetClick() {
        val shouldOpenCamera = intent.getBooleanExtra("open_quick_camera", false)
        if (shouldOpenCamera) {
            // Send message to Flutter to open quick camera
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("openQuickCamera", null)
            }
            // Clear the intent extra after handling
            intent.removeExtra("open_quick_camera")
        }
    }
}