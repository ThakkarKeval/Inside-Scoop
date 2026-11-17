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
