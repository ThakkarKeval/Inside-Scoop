package com.cavernlabs.inside.scoop.inside_scoop

import android.app.UiModeManager
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.security.MessageDigest

class InsideScoopPlugin(private var context: Context? = null) : FlutterPlugin, InsideScoopHostApi {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        InsideScoopHostApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        InsideScoopHostApi.setUp(binding.binaryMessenger, null)
        context = null
    }

    override fun getPlatformVersion(): String {
        return "Android ${Build.VERSION.RELEASE}"
    }

    override fun getAppInfo(): PlatformAppInfo {
        val currentContext = context
            ?: throw RuntimeException("Android Context is not available")
        val pm = currentContext.packageManager
        val pkgName = currentContext.packageName

        val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getApplicationInfo(pkgName, PackageManager.ApplicationInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.getApplicationInfo(pkgName, 0)
        }
        val appName = pm.getApplicationLabel(appInfo).toString()

        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getPackageInfo(
                pkgName,
                PackageManager.PackageInfoFlags.of(PackageManager.GET_SIGNING_CERTIFICATES.toLong())
            )
        } else {
            @Suppress("DEPRECATION")
            pm.getPackageInfo(pkgName, PackageManager.GET_SIGNATURES)
        }

        val versionName = packageInfo.versionName ?: ""
        val buildNumber = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.longVersionCode.toString()
        } else {
            @Suppress("DEPRECATION")
            packageInfo.versionCode.toString()
        }

        val installerStore = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                pm.getInstallSourceInfo(pkgName).installingPackageName
            } catch (e: Exception) {
                null
            }
        } else {
            @Suppress("DEPRECATION")
            try {
                pm.getInstallerPackageName(pkgName)
            } catch (e: Exception) {
                null
            }
        }

        val signature = getCertificateSignature(packageInfo)

        return PlatformAppInfo(
            appName = appName,
            packageName = pkgName,
            version = versionName,
            buildNumber = buildNumber,
            buildSignature = signature,
            installerStore = installerStore
        )
    }

    override fun getOsInfo(): PlatformOsInfo {
        val osName = "Android"
        val osVersion = Build.VERSION.RELEASE ?: ""
        val buildNumber = Build.DISPLAY?.takeIf { it.isNotBlank() } ?: Build.ID ?: ""
        val arch = System.getProperty("os.arch") ?: (Build.SUPPORTED_ABIS?.firstOrNull() ?: "")
        val kernelVersion = System.getProperty("os.version")

        return PlatformOsInfo(
            name = osName,
            version = osVersion,
            buildNumber = buildNumber,
            architecture = arch,
            kernelVersion = kernelVersion
        )
    }

    override fun getDeviceInfo(): PlatformDeviceInfo {
        val model = Build.MODEL ?: ""
        val manufacturer = Build.MANUFACTURER ?: ""
        val brand = Build.BRAND ?: ""
        val fingerprint = Build.FINGERPRINT ?: ""
        val device = Build.DEVICE ?: ""
        val hardware = Build.HARDWARE ?: ""
        val product = Build.PRODUCT ?: ""

        val currentContext = context
        val categoryIndex: Long = currentContext?.let { ctx ->
            val uiModeManager = ctx.getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
            val uiType = uiModeManager?.currentModeType ?: Configuration.UI_MODE_TYPE_NORMAL
            when (uiType) {
                Configuration.UI_MODE_TYPE_TELEVISION -> 5L // tv
                Configuration.UI_MODE_TYPE_WATCH -> 4L // wearable
                Configuration.UI_MODE_TYPE_DESK -> 2L // desktop
                else -> {
                    val sw = ctx.resources?.configuration?.smallestScreenWidthDp ?: 0
                    if (sw >= 600) 1L else 0L // tablet or phone
                }
            }
        } ?: 0L

        val isPhysicalDevice = !(
            fingerprint.startsWith("generic") ||
            fingerprint.startsWith("unknown") ||
            model.contains("google_sdk") ||
            model.contains("Emulator") ||
            model.contains("Android SDK built for x86") ||
            manufacturer.contains("Genymotion") ||
            (brand.startsWith("generic") && device.startsWith("generic")) ||
            hardware.contains("goldfish") ||
            hardware.contains("ranchu") ||
            product.contains("sdk") ||
            product.contains("google_sdk") ||
            product.contains("sdk_x86") ||
            product.contains("vbox86p") ||
            product.contains("emulator")
        )

        val supportedAbis = Build.SUPPORTED_ABIS?.toList() ?: emptyList<String>()

        return PlatformDeviceInfo(
            model = model,
            manufacturer = manufacturer,
            brand = brand,
            categoryIndex = categoryIndex,
            isPhysicalDevice = isPhysicalDevice,
            supportedAbis = supportedAbis
        )
    }

    override fun getCpuInfo(): PlatformCpuInfo {
        val arch = (Build.SUPPORTED_ABIS?.firstOrNull()) ?: System.getProperty("os.arch") ?: "unknown"
        val logicalCores = java.lang.Runtime.getRuntime().availableProcessors().toLong()
        val physicalCores = getPhysicalCores()

        val socModel = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Build.SOC_MODEL?.takeIf { it.isNotBlank() }
        } else null
        val rawHardware: String? = Build.HARDWARE
        val modelName = socModel ?: readCpuModelName() ?: rawHardware?.takeIf { it.isNotBlank() }
        val maxClockSpeed = getMaxClockSpeedMhz()

        return PlatformCpuInfo(
            architecture = arch,
            modelName = modelName,
            physicalCores = physicalCores,
            logicalCores = if (logicalCores > 0L) logicalCores else 1L,
            maxClockSpeedMhz = maxClockSpeed,
            systemUtilization = null,
            processUtilization = null
        )
    }

    override fun getMemoryInfo(): PlatformMemoryInfo {
        val currentContext = context
        val mi = android.app.ActivityManager.MemoryInfo()
        val activityManager = currentContext?.getSystemService(Context.ACTIVITY_SERVICE) as? android.app.ActivityManager
        activityManager?.getMemoryInfo(mi)

        val totalMem = if (mi.totalMem > 0L) mi.totalMem else {
            readMemTotalFromProc() ?: (1024L * 1024L * 1024L * 4L)
        }
        val availMem = if (mi.availMem > 0L) mi.availMem else (totalMem / 2L)
        val isLowMem = mi.lowMemory

        val runtime = java.lang.Runtime.getRuntime()
        val residentBytes = runtime.totalMemory() - runtime.freeMemory()

        return PlatformMemoryInfo(
            totalPhysicalBytes = totalMem,
            availablePhysicalBytes = availMem,
            processResidentBytes = if (residentBytes > 0L) residentBytes else null,
            processVirtualBytes = null,
            isLowMemory = isLowMem
        )
    }

    private fun readMemTotalFromProc(): Long? {
        return try {
            val file = java.io.File("/proc/meminfo")
            if (!file.exists() || !file.canRead()) return null
            val reader = file.bufferedReader()
            var result: Long? = null
            reader.useLines { lines ->
                for (line in lines) {
                    if (line.startsWith("MemTotal:")) {
                        val colonParts = line.split(":")
                        if (colonParts.size >= 2) {
                            val trimmed = colonParts[1].trim()
                            val numStr = trimmed.split(" ")[0].trim()
                            val kb = numStr.toLongOrNull()
                            if (kb != null) {
                                result = kb * 1024L
                                break
                            }
                        }
                    }
                }
            }
            result
        } catch (e: Exception) {
            null
        }
    }

    private fun getPhysicalCores(): Long? {
        return try {
            val coreIds = java.util.HashSet<String>()
            val cpuDir = java.io.File("/sys/devices/system/cpu")
            val cpuFiles = cpuDir.listFiles(java.io.FileFilter { f ->
                f.isDirectory && f.name.startsWith("cpu") && f.name.substring(3).all { it.isDigit() }
            })
            if (cpuFiles != null && cpuFiles.isNotEmpty()) {
                for (dir in cpuFiles) {
                    val coreIdFile = java.io.File(dir, "topology/core_id")
                    if (coreIdFile.exists() && coreIdFile.canRead()) {
                        val id = coreIdFile.readText().trim()
                        if (id.isNotBlank()) {
                            coreIds.add(id)
                        }
                    }
                }
                if (coreIds.isNotEmpty()) {
                    return coreIds.size.toLong()
                }
            }
            null
        } catch (e: Exception) {
            null
        }
    }

    private fun readCpuModelName(): String? {
        return try {
            val file = java.io.File("/proc/cpuinfo")
            if (!file.exists() || !file.canRead()) return null
            val reader = file.bufferedReader()
            var result: String? = null
            reader.useLines { lines ->
                for (line in lines) {
                    val lower = line.lowercase()
                    if (lower.startsWith("hardware") || lower.startsWith("model name") || lower.startsWith("processor")) {
                        val parts = line.split(":")
                        if (parts.size > 1) {
                            val value = parts[1].trim()
                            if (value.isNotBlank() && !value.all { it.isDigit() }) {
                                result = value
                                break
                            }
                        }
                    }
                }
            }
            result
        } catch (e: Exception) {
            null
        }
    }

    private fun getMaxClockSpeedMhz(): Long? {
        return try {
            val freqFile = java.io.File("/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq")
            if (freqFile.exists() && freqFile.canRead()) {
                val text = freqFile.readText().trim()
                val khz = text.toLongOrNull()
                if (khz != null && khz > 0L) {
                    return khz / 1000L
                }
            }
            null
        } catch (e: Exception) {
            null
        }
    }

    private fun getCertificateSignature(packageInfo: PackageInfo): String? {
        return try {
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                packageInfo.signatures
            }
            if (signatures == null || signatures.isEmpty()) return null
            val md = MessageDigest.getInstance("SHA-256")
            val digest = md.digest(signatures[0].toByteArray())
            val hexString = StringBuilder()
            for (b in digest) {
                val hex = Integer.toHexString(0xFF and b.toInt())
                if (hex.length == 1) {
                    hexString.append('0')
                }
                hexString.append(hex)
            }
            hexString.toString()
        } catch (e: Exception) {
            null
        }
    }
}
