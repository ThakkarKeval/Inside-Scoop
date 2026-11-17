#include "include/inside_scoop/inside_scoop_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "inside_scoop_plugin.h"

void InsideScoopPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  inside_scoop::InsideScoopPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
