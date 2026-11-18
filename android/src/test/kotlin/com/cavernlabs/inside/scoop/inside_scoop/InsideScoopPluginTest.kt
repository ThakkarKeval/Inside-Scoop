package com.cavernlabs.inside.scoop.inside_scoop

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNotNull

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

    @Test
    fun getOsInfo_returnsExpectedOsMetadata() {
        val plugin = InsideScoopPlugin()
        val osInfo = plugin.getOsInfo()
        assertEquals("Android", osInfo.name)
        assertNotNull(osInfo.version)
        assertNotNull(osInfo.buildNumber)
        assertNotNull(osInfo.architecture)
    }

    @Test
    fun getDeviceInfo_returnsExpectedDeviceMetadata() {
        val plugin = InsideScoopPlugin()
        val deviceInfo = plugin.getDeviceInfo()
        assertEquals(android.os.Build.MODEL ?: "", deviceInfo.model)
        assertEquals(android.os.Build.MANUFACTURER ?: "", deviceInfo.manufacturer)
        assertEquals(android.os.Build.BRAND ?: "", deviceInfo.brand)
        assertNotNull(deviceInfo.supportedAbis)
    }

    @Test
    fun getCpuInfo_returnsExpectedCpuMetadata() {
        val plugin = InsideScoopPlugin()
        val cpuInfo = plugin.getCpuInfo()
        assertNotNull(cpuInfo.architecture)
        assertEquals(true, cpuInfo.logicalCores >= 1L)
    }

    @Test
    fun getMemoryInfo_returnsExpectedMemoryMetadata() {
        val plugin = InsideScoopPlugin()
        val memoryInfo = plugin.getMemoryInfo()
        assertEquals(true, memoryInfo.totalPhysicalBytes > 0L)
        assertEquals(true, memoryInfo.availablePhysicalBytes > 0L)
    }

    @Test
    fun getStorageInfo_returnsExpectedStorageMetadata() {
        val plugin = InsideScoopPlugin()
        val storageInfo = plugin.getStorageInfo()
        assertEquals(true, storageInfo.totalBytes > 0L)
        assertEquals(true, storageInfo.availableBytes > 0L)
    }

    @Test
    fun getGpuInfo_returnsExpectedGpuMetadata() {
        val plugin = InsideScoopPlugin()
        val gpuInfo = plugin.getGpuInfo()
        assertNotNull(gpuInfo.vendor)
        assertNotNull(gpuInfo.renderer)
        assertNotNull(gpuInfo.apiFamily)
    }
}
