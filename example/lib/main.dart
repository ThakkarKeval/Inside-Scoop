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

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _appInfo = appResult.valueOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('inside_scoop Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              if (_appInfo != null) ...[
                Text('App Name: ${_appInfo!.appName}'),
                Text('Package: ${_appInfo!.packageName}'),
                Text(
                  'Version: ${_appInfo!.version} (Build ${_appInfo!.buildNumber})',
                ),
                if (_appInfo!.installerStore != null)
                  Text('Store: ${_appInfo!.installerStore}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
