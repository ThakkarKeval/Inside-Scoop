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

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _appInfo = appResult.valueOrNull;
      _osInfo = osResult.valueOrNull;
      _deviceInfo = deviceResult.valueOrNull;
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
