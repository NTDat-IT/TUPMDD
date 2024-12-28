package com.example.dart_pin_tumpdd

import android.os.BatteryManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.power/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryStats") {
                val batteryStats = getBatteryStats()
                if (batteryStats != null) {
                    result.success(batteryStats)
                } else {
                    result.error("UNAVAILABLE", "Battery stats not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryStats(): Map<String, Any>? {
        val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
        val currentNow = batteryManager.getLongProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
        val currentNowInMilliAmps = currentNow / 1000.0

        return mapOf(
            "currentNow" to currentNowInMilliAmps
        )
    }
}
