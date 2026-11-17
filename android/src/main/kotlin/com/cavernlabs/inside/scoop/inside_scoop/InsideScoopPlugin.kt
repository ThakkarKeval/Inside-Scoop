package com.cavernlabs.inside.scoop.inside_scoop

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
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
