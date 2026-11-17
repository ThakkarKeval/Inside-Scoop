#ifndef FLUTTER_PLUGIN_INSIDE_SCOOP_PLUGIN_H_
#define FLUTTER_PLUGIN_INSIDE_SCOOP_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace inside_scoop {

class InsideScoopPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  InsideScoopPlugin();

  virtual ~InsideScoopPlugin();

  // Disallow copy and assign.
  InsideScoopPlugin(const InsideScoopPlugin&) = delete;
  InsideScoopPlugin& operator=(const InsideScoopPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace inside_scoop

#endif  // FLUTTER_PLUGIN_INSIDE_SCOOP_PLUGIN_H_
