package com.cavernlabs.inside.scoop.inside_scoop

import io.flutter.embedding.engine.plugins.FlutterPlugin

class InsideScoopPlugin : FlutterPlugin, InsideScoopHostApi {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        InsideScoopHostApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        InsideScoopHostApi.setUp(binding.binaryMessenger, null)
    }

    override fun getPlatformVersion(): String {
        return "Android ${android.os.Build.VERSION.RELEASE}"
    }
}
