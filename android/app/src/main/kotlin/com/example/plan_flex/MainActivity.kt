package com.example.plan_flex

import android.app.AppOpsManager
import android.app.usage.NetworkStatsManager
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.DecimalFormat
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val channelName = "data_usage_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getTodayUsage" -> result.success(getUsage(true))
                "getMonthUsage" -> result.success(getUsage(false))
                "hasUsagePermission" -> result.success(hasUsagePermission())
                "openUsageSettings" -> {
                    openUsageSettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getUsage(isToday: Boolean): HashMap<String, String> {
        val startTime = if (isToday) getStartOfToday() else getStartOfMonth()
        val endTime = System.currentTimeMillis()

        val wifiBytes = getNetworkUsage(
            ConnectivityManager.TYPE_WIFI,
            startTime,
            endTime
        )

        val mobileBytes = getNetworkUsage(
            ConnectivityManager.TYPE_MOBILE,
            startTime,
            endTime
        )

        return hashMapOf(
            "wifi" to formatBytes(wifiBytes),
            "mobile" to formatBytes(mobileBytes)
        )
    }

    private fun getNetworkUsage(
        networkType: Int,
        startTime: Long,
        endTime: Long
    ): Long {
        return try {
            val manager =
                getSystemService(Context.NETWORK_STATS_SERVICE) as NetworkStatsManager

            val bucket = manager.querySummaryForDevice(
                networkType,
                null,
                startTime,
                endTime
            )

            bucket.rxBytes + bucket.txBytes
        } catch (e: Exception) {
            0L
        }
    }

    private fun getStartOfToday(): Long {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        return calendar.timeInMillis
    }

    private fun getStartOfMonth(): Long {
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.DAY_OF_MONTH, 1)
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        return calendar.timeInMillis
    }

    private fun formatBytes(bytes: Long): String {
        val kb = bytes / 1024.0
        val mb = kb / 1024.0
        val gb = mb / 1024.0
        val df = DecimalFormat("#.##")

        return when {
            gb >= 1 -> "${df.format(gb)} GB"
            mb >= 1 -> "${df.format(mb)} MB"
            kb >= 1 -> "${df.format(kb)} KB"
            else -> "$bytes B"
        }
    }

    private fun hasUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager

        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }

        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }
}