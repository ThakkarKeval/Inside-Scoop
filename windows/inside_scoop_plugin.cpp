#include "inside_scoop_plugin.h"

#include <windows.h>
#include <VersionHelpers.h>

#include <memory>
#include <sstream>
#include <vector>

namespace inside_scoop {

void InsideScoopPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<InsideScoopPlugin>();
  InsideScoopHostApi::SetUp(registrar->messenger(), plugin.get());
  registrar->AddPlugin(std::move(plugin));
}

InsideScoopPlugin::InsideScoopPlugin() {}
InsideScoopPlugin::~InsideScoopPlugin() {}

ErrorOr<std::optional<std::string>> InsideScoopPlugin::GetPlatformVersion() {
  std::ostringstream version_stream;
  version_stream << "Windows ";
  if (IsWindows10OrGreater()) {
    version_stream << "10+";
  } else if (IsWindows8OrGreater()) {
    version_stream << "8";
  } else if (IsWindows7OrGreater()) {
    version_stream << "7";
  }
  return version_stream.str();
}

ErrorOr<PlatformAppInfo> InsideScoopPlugin::GetAppInfo() {
  wchar_t path[MAX_PATH];
  DWORD length = GetModuleFileNameW(nullptr, path, MAX_PATH);
  std::string exe_name = "WindowsApp";
  std::string version = "1.0.0";
  std::string build_number = "1";

  if (length > 0) {
    std::wstring wide_path(path, length);
    size_t last_slash = wide_path.find_last_of(L"\\/");
    if (last_slash != std::wstring::npos) {
      std::wstring name_part = wide_path.substr(last_slash + 1);
      size_t dot = name_part.find_last_of(L'.');
      if (dot != std::wstring::npos) {
        name_part = name_part.substr(0, dot);
      }
      exe_name = std::string(name_part.begin(), name_part.end());
    }

    DWORD handle = 0;
    DWORD size = GetFileVersionInfoSizeW(path, &handle);
    if (size > 0) {
      std::vector<BYTE> data(size);
      if (GetFileVersionInfoW(path, handle, size, data.data())) {
        VS_FIXEDFILEINFO* file_info = nullptr;
        UINT file_info_size = 0;
        if (VerQueryValueW(data.data(), L"\\", reinterpret_cast<void**>(&file_info), &file_info_size) && file_info_size > 0) {
          std::ostringstream ver_stream;
          ver_stream << HIWORD(file_info->dwFileVersionMS) << "."
                     << LOWORD(file_info->dwFileVersionMS) << "."
                     << HIWORD(file_info->dwFileVersionLS);
          version = ver_stream.str();

          std::ostringstream build_stream;
          build_stream << LOWORD(file_info->dwFileVersionLS);
          build_number = build_stream.str();
        }
      }
    }
  }

  PlatformAppInfo app_info(exe_name, exe_name, version, build_number);
  std::string installer = "Windows";
  app_info.set_installer_store(installer);
  return app_info;
}

}  // namespace inside_scoop
