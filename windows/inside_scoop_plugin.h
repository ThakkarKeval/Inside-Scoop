#ifndef FLUTTER_PLUGIN_INSIDE_SCOOP_PLUGIN_H_
#define FLUTTER_PLUGIN_INSIDE_SCOOP_PLUGIN_H_

#include <flutter/plugin_registrar_windows.h>
#include "messages.g.h"

#include <memory>
#include <optional>
#include <string>

namespace inside_scoop {

class InsideScoopPlugin : public flutter::Plugin, public InsideScoopHostApi {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  InsideScoopPlugin();
  virtual ~InsideScoopPlugin();

  InsideScoopPlugin(const InsideScoopPlugin&) = delete;
  InsideScoopPlugin& operator=(const InsideScoopPlugin&) = delete;

  ErrorOr<std::optional<std::string>> GetPlatformVersion() override;
  ErrorOr<PlatformAppInfo> GetAppInfo() override;
  ErrorOr<PlatformOsInfo> GetOsInfo() override;
  ErrorOr<PlatformDeviceInfo> GetDeviceInfo() override;
  ErrorOr<PlatformCpuInfo> GetCpuInfo() override;
  ErrorOr<PlatformMemoryInfo> GetMemoryInfo() override;
  ErrorOr<PlatformStorageInfo> GetStorageInfo() override;
};

}  // namespace inside_scoop

#endif  // FLUTTER_PLUGIN_INSIDE_SCOOP_PLUGIN_H_
