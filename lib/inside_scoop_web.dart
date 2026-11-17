// ignore: avoid_web_libraries_in_flutter
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'inside_scoop_platform_interface.dart';
import 'src/core/models/app_info.dart';

class InsideScoopWeb extends InsideScoopPlatform {
  InsideScoopWeb();

  static void registerWith(Registrar registrar) {
    InsideScoopPlatform.instance = InsideScoopWeb();
  }

  @override
  Future<String?> getPlatformVersion() async {
    return web.window.navigator.userAgent;
  }

  @override
  Future<AppInfo> getAppInfo() async {
    final title = web.document.title;
    final host = web.window.location.host;
    return AppInfo(
      appName: title.isNotEmpty ? title : 'Web Application',
      packageName: host.isNotEmpty ? host : 'web.local',
      version: '1.0.0',
      buildNumber: '1',
      installerStore: 'web',
    );
  }
}
