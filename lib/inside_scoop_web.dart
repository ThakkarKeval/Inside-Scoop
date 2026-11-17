// ignore: avoid_web_libraries_in_flutter
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

import 'inside_scoop_platform_interface.dart';

class InsideScoopWeb extends InsideScoopPlatform {
  InsideScoopWeb();

  static void registerWith(Registrar registrar) {
    InsideScoopPlatform.instance = InsideScoopWeb();
  }

  @override
  Future<String?> getPlatformVersion() async {
    return web.window.navigator.userAgent;
  }
}
