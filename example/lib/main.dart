import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  AppInfo? _appInfo;
  OsInfo? _osInfo;
  DeviceInfo? _deviceInfo;
  CpuInfo? _cpuInfo;
  MemoryInfo? _memoryInfo;
  StorageInfo? _storageInfo;
  GpuInfo? _gpuInfo;
  Map<ScoopFeature, ScoopCapabilityInfo> _capabilities = {};
  final _insideScoopPlugin = InsideScoop();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _insideScoopPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    final appResult = await _insideScoopPlugin.app.info();
    final osResult = await _insideScoopPlugin.os.info();
    final deviceResult = await _insideScoopPlugin.device.info();
    final cpuResult = await _insideScoopPlugin.cpu.info();
    final memoryResult = await _insideScoopPlugin.memory.info();
    final storageResult = await _insideScoopPlugin.storage.info();
    final gpuResult = await _insideScoopPlugin.gpu.info();
    final capabilities = await _insideScoopPlugin.capabilities.getAll();

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _appInfo = appResult.valueOrNull;
      _osInfo = osResult.valueOrNull;
      _deviceInfo = deviceResult.valueOrNull;
      _cpuInfo = cpuResult.valueOrNull;
      _memoryInfo = memoryResult.valueOrNull;
      _storageInfo = storageResult.valueOrNull;
      _gpuInfo = gpuResult.valueOrNull;
      _capabilities = capabilities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('inside_scoop Example')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Running on: $_platformVersion\n'),
              if (_appInfo != null) ...[
                const Text(
                  'Application Metadata',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Name: ${_appInfo!.appName}'),
                Text('Package: ${_appInfo!.packageName}'),
                Text('Version: ${_appInfo!.version}+${_appInfo!.buildNumber}'),
                const SizedBox(height: 12),
              ],
              if (_osInfo != null) ...[
                const Text(
                  'Operating System Metadata',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('OS: ${_osInfo!.name} ${_osInfo!.version}'),
                Text('Build: ${_osInfo!.buildNumber}'),
                Text('Architecture: ${_osInfo!.architecture}'),
                const SizedBox(height: 12),
              ],
              if (_deviceInfo != null) ...[
                const Text(
                  'Device Metadata',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Model: ${_deviceInfo!.model}'),
                Text('Manufacturer: ${_deviceInfo!.manufacturer}'),
                Text('Brand: ${_deviceInfo!.brand}'),
                Text('Category: ${_deviceInfo!.category.name}'),
                Text('Physical: ${_deviceInfo!.isPhysicalDevice}'),
                Text('ABIs: ${_deviceInfo!.supportedAbis.join(", ")}'),
                const SizedBox(height: 12),
              ],
              if (_cpuInfo != null) ...[
                const Text(
                  'Processor / CPU Metadata',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Architecture: ${_cpuInfo!.architecture}'),
                if (_cpuInfo!.modelName != null)
                  Text('Model: ${_cpuInfo!.modelName}'),
                Text('Logical Cores: ${_cpuInfo!.logicalCores}'),
                if (_cpuInfo!.physicalCores != null)
                  Text('Physical Cores: ${_cpuInfo!.physicalCores}'),
                if (_cpuInfo!.maxClockSpeedMhz != null)
                  Text('Clock Speed: ${_cpuInfo!.maxClockSpeedMhz} MHz'),
                const SizedBox(height: 12),
              ],
              if (_memoryInfo != null) ...[
                const Text(
                  'System Memory (RAM)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Total: ${_memoryInfo!.totalPhysicalMb} MB (${_memoryInfo!.totalPhysicalGb.toStringAsFixed(1)} GB)'),
                Text('Available: ${_memoryInfo!.availablePhysicalMb} MB (${_memoryInfo!.availablePhysicalGb.toStringAsFixed(1)} GB)'),
                Text('Used: ${_memoryInfo!.usedPhysicalMb} MB (${_memoryInfo!.usagePercentage.toStringAsFixed(1)}%)'),
                Text('Low Memory Warning: ${_memoryInfo!.isLowMemory}'),
                if (_memoryInfo!.processResidentBytes != null)
                  Text('App Resident: ${(_memoryInfo!.processResidentBytes! / (1024 * 1024)).toStringAsFixed(1)} MB'),
                const SizedBox(height: 12),
              ],
              if (_storageInfo != null) ...[
                const Text(
                  'Primary Storage Volume',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Total: ${_storageInfo!.totalGb.toStringAsFixed(1)} GB (${_storageInfo!.totalMb} MB)'),
                Text('Available: ${_storageInfo!.availableGb.toStringAsFixed(1)} GB (${_storageInfo!.availableMb} MB)'),
                Text('Used: ${_storageInfo!.usedGb.toStringAsFixed(1)} GB (${_storageInfo!.usagePercentage.toStringAsFixed(1)}%)'),
                Text('Removable Storage: ${_storageInfo!.isRemovable}'),
                if (_storageInfo!.appStorageBytes != null)
                  Text('App Data + Cache: ${_storageInfo!.appStorageMb?.toStringAsFixed(1)} MB'),
                const SizedBox(height: 12),
              ],
              if (_gpuInfo != null) ...[
                const Text(
                  'Graphics Processing Unit (GPU)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Vendor: ${_gpuInfo!.vendor}'),
                Text('Renderer: ${_gpuInfo!.renderer}'),
                if (_gpuInfo!.apiFamily != null)
                  Text('API Family: ${_gpuInfo!.apiFamily}'),
                if (_gpuInfo!.apiVersion != null)
                  Text('API Version: ${_gpuInfo!.apiVersion}'),
                if (_gpuInfo!.totalVramMb != null)
                  Text('VRAM: ${_gpuInfo!.totalVramMb} MB (${_gpuInfo!.totalVramGb?.toStringAsFixed(1)} GB)'),
                if (_gpuInfo!.isUnifiedMemory != null)
                  Text('Unified Memory: ${_gpuInfo!.isUnifiedMemory}'),
                const SizedBox(height: 12),
              ],
              if (_capabilities.isNotEmpty) ...[
                const Text(
                  'Feature Capabilities',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ..._capabilities.entries.map((entry) {
                  final color = switch (entry.value.state) {
                    ScoopCapabilityState.supported => Colors.green,
                    ScoopCapabilityState.unsupported => Colors.red,
                    ScoopCapabilityState.requiresPermission => Colors.orange,
                    ScoopCapabilityState.restricted => Colors.amber.shade800,
                  };
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${entry.key.name}: ',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          entry.value.state.name,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
