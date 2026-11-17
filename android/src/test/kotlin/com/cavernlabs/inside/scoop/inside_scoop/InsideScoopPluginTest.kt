package com.cavernlabs.inside.scoop.inside_scoop

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

internal class InsideScoopPluginTest {
    @Test
    fun getPlatformVersion_returnsExpectedValue() {
        val plugin = InsideScoopPlugin()
        val version = plugin.getPlatformVersion()
        assertEquals("Android ${android.os.Build.VERSION.RELEASE}", version)
    }

    @Test
    fun getAppInfo_withoutContext_throwsException() {
        val plugin = InsideScoopPlugin()
        assertFailsWith<RuntimeException> {
            plugin.getAppInfo()
        }
    }
}
