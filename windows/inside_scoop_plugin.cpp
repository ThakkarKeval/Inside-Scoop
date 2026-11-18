#include "inside_scoop_plugin.h"

#include <windows.h>
#include <dxgi.h>
#include <psapi.h>
#include <VersionHelpers.h>

#include <memory>
#include <sstream>
#include <vector>

namespace inside_scoop {

typedef LONG(NTAPI* RtlGetVersionPtr)(PRTL_OSVERSIONINFOW);

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

ErrorOr<PlatformOsInfo> InsideScoopPlugin::GetOsInfo() {
  std::string os_version = "Windows";
  std::string build_number = "";
  std::string kernel_version = "";

  HMODULE ntdll = GetModuleHandleW(L"ntdll.dll");
  if (ntdll) {
    auto rtl_get_version = reinterpret_cast<RtlGetVersionPtr>(
        GetProcAddress(ntdll, "RtlGetVersion"));
    if (rtl_get_version) {
      RTL_OSVERSIONINFOW osvi = { sizeof(RTL_OSVERSIONINFOW) };
      if (rtl_get_version(&osvi) == 0) {
        std::ostringstream ver_stream;
        ver_stream << osvi.dwMajorVersion << "." << osvi.dwMinorVersion;
        os_version = ver_stream.str();

        std::ostringstream build_stream;
        build_stream << osvi.dwBuildNumber;
        build_number = build_stream.str();

        std::ostringstream kernel_stream;
        kernel_stream << "NT " << osvi.dwMajorVersion << "." << osvi.dwMinorVersion << "." << osvi.dwBuildNumber;
        kernel_version = kernel_stream.str();
      }
    }
  }

  SYSTEM_INFO si;
  GetNativeSystemInfo(&si);
  std::string arch = "unknown";
  switch (si.wProcessorArchitecture) {
    case PROCESSOR_ARCHITECTURE_AMD64:
      arch = "x86_64";
      break;
    case PROCESSOR_ARCHITECTURE_ARM64:
      arch = "arm64";
      break;
    case PROCESSOR_ARCHITECTURE_INTEL:
      arch = "x86";
      break;
    case PROCESSOR_ARCHITECTURE_ARM:
      arch = "arm";
      break;
    default:
      arch = "unknown";
      break;
  }

  PlatformOsInfo os_info("Windows", os_version, build_number, arch);
  if (!kernel_version.empty()) {
    os_info.set_kernel_version(kernel_version);
  }
  return os_info;
}

ErrorOr<PlatformDeviceInfo> InsideScoopPlugin::GetDeviceInfo() {
  wchar_t computer_name[MAX_COMPUTERNAME_LENGTH + 1];
  DWORD size = sizeof(computer_name) / sizeof(computer_name[0]);
  std::string name = "WindowsDevice";
  if (GetComputerNameW(computer_name, &size)) {
    std::wstring wide_name(computer_name, size);
    name = std::string(wide_name.begin(), wide_name.end());
  }

  SYSTEM_INFO si;
  GetNativeSystemInfo(&si);
  flutter::EncodableList abis;
  if (si.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64) {
    abis.push_back(flutter::EncodableValue("x86_64"));
    abis.push_back(flutter::EncodableValue("x86"));
  } else if (si.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_ARM64) {
    abis.push_back(flutter::EncodableValue("arm64"));
  } else {
    abis.push_back(flutter::EncodableValue("x86"));
  }

  PlatformDeviceInfo device_info(
      name,
      "Microsoft",
      "Windows",
      2, // desktop
      true,
      abis);

  return device_info;
}

ErrorOr<PlatformCpuInfo> InsideScoopPlugin::GetCpuInfo() {
  SYSTEM_INFO si;
  GetNativeSystemInfo(&si);

  std::string arch = "unknown";
  switch (si.wProcessorArchitecture) {
    case PROCESSOR_ARCHITECTURE_AMD64:
      arch = "x86_64";
      break;
    case PROCESSOR_ARCHITECTURE_ARM64:
      arch = "arm64";
      break;
    case PROCESSOR_ARCHITECTURE_INTEL:
      arch = "x86";
      break;
    case PROCESSOR_ARCHITECTURE_ARM:
      arch = "arm";
      break;
    default:
      arch = "unknown";
      break;
  }

  int64_t logical_cores = si.dwNumberOfProcessors > 0 ? si.dwNumberOfProcessors : 1;
  int64_t physical_cores_count = 0;
  DWORD len = 0;
  GetLogicalProcessorInformationEx(RelationProcessorCore, nullptr, &len);
  if (len > 0) {
    std::vector<BYTE> buffer(len);
    if (GetLogicalProcessorInformationEx(
            RelationProcessorCore,
            reinterpret_cast<PSYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX>(buffer.data()),
            &len)) {
      DWORD offset = 0;
      while (offset < len) {
        auto info = reinterpret_cast<PSYSTEM_LOGICAL_PROCESSOR_INFORMATION_EX>(buffer.data() + offset);
        if (info->Relationship == RelationProcessorCore) {
          physical_cores_count++;
        }
        offset += info->Size;
      }
    }
  }

  std::string model_name;
  int64_t max_clock_mhz = 0;
  HKEY hkey;
  if (RegOpenKeyExW(
          HKEY_LOCAL_MACHINE,
          L"HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0",
          0,
          KEY_READ,
          &hkey) == ERROR_SUCCESS) {
    wchar_t brand_buf[256];
    DWORD brand_size = sizeof(brand_buf);
    if (RegQueryValueExW(
            hkey,
            L"ProcessorNameString",
            nullptr,
            nullptr,
            reinterpret_cast<LPBYTE>(brand_buf),
            &brand_size) == ERROR_SUCCESS) {
      std::wstring wide_brand(brand_buf);
      model_name = std::string(wide_brand.begin(), wide_brand.end());
      size_t first = model_name.find_first_not_of(" \t\r\n");
      if (first != std::string::npos) {
        size_t last = model_name.find_last_not_of(" \t\r\n");
        model_name = model_name.substr(first, (last - first + 1));
      }
    }
    DWORD mhz = 0;
    DWORD mhz_size = sizeof(mhz);
    if (RegQueryValueExW(
            hkey,
            L"~MHz",
            nullptr,
            nullptr,
            reinterpret_cast<LPBYTE>(&mhz),
            &mhz_size) == ERROR_SUCCESS) {
      max_clock_mhz = mhz;
    }
    RegCloseKey(hkey);
  }

  PlatformCpuInfo cpu_info(arch, logical_cores);
  if (!model_name.empty()) {
    cpu_info.set_model_name(model_name);
  }
  if (physical_cores_count > 0) {
    cpu_info.set_physical_cores(physical_cores_count);
  }
  if (max_clock_mhz > 0) {
    cpu_info.set_max_clock_speed_mhz(max_clock_mhz);
  }

  return cpu_info;
}

ErrorOr<PlatformMemoryInfo> InsideScoopPlugin::GetMemoryInfo() {
  MEMORYSTATUSEX statex;
  statex.dwLength = sizeof(statex);
  int64_t total_phys = 0;
  int64_t avail_phys = 0;
  bool is_low_mem = false;

  if (GlobalMemoryStatusEx(&statex)) {
    total_phys = static_cast<int64_t>(statex.ullTotalPhys);
    avail_phys = static_cast<int64_t>(statex.ullAvailPhys);
    is_low_mem = (statex.dwMemoryLoad >= 90);
  }

  PROCESS_MEMORY_COUNTERS pmc;
  int64_t resident_bytes = 0;
  int64_t virtual_bytes = 0;
  if (K32GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc))) {
    resident_bytes = static_cast<int64_t>(pmc.WorkingSetSize);
    virtual_bytes = static_cast<int64_t>(pmc.PagefileUsage);
  }

  PlatformMemoryInfo mem_info(total_phys, avail_phys, is_low_mem);
  if (resident_bytes > 0) {
    mem_info.set_process_resident_bytes(resident_bytes);
  }
  if (virtual_bytes > 0) {
    mem_info.set_process_virtual_bytes(virtual_bytes);
  }

  return mem_info;
}

ErrorOr<PlatformStorageInfo> InsideScoopPlugin::GetStorageInfo() {
  ULARGE_INTEGER free_bytes_available;
  ULARGE_INTEGER total_bytes;
  ULARGE_INTEGER total_free_bytes;

  int64_t total = 0;
  int64_t available = 0;

  if (GetDiskFreeSpaceExW(nullptr, &free_bytes_available, &total_bytes, &total_free_bytes)) {
    total = static_cast<int64_t>(total_bytes.QuadPart);
    available = static_cast<int64_t>(free_bytes_available.QuadPart);
  }

  PlatformStorageInfo storage_info(total, available, false);
  return storage_info;
}

ErrorOr<PlatformGpuInfo> InsideScoopPlugin::GetGpuInfo() {
  std::string renderer = "Windows Display Adapter";
  std::string vendor = "Unknown";
  int64_t vram_bytes = 0;
  bool is_unified = false;

  HMODULE dxgi_lib = LoadLibraryW(L"dxgi.dll");
  if (dxgi_lib) {
    typedef HRESULT (WINAPI *CreateDXGIFactoryFn)(REFIID, void**);
    auto create_factory = reinterpret_cast<CreateDXGIFactoryFn>(
        GetProcAddress(dxgi_lib, "CreateDXGIFactory"));
    if (create_factory) {
      IDXGIFactory* factory = nullptr;
      if (SUCCEEDED(create_factory(__uuidof(IDXGIFactory), reinterpret_cast<void**>(&factory))) && factory) {
        IDXGIAdapter* adapter = nullptr;
        if (SUCCEEDED(factory->EnumAdapters(0, &adapter)) && adapter) {
          DXGI_ADAPTER_DESC desc;
          if (SUCCEEDED(adapter->GetDesc(&desc))) {
            std::wstring desc_w(desc.Description);
            renderer = std::string(desc_w.begin(), desc_w.end());
            vram_bytes = static_cast<int64_t>(desc.DedicatedVideoMemory);

            switch (desc.VendorId) {
              case 0x10DE:
                vendor = "NVIDIA";
                break;
              case 0x1002:
              case 0x1022:
                vendor = "AMD";
                break;
              case 0x8086:
                vendor = "Intel";
                break;
              case 0x1414:
                vendor = "Microsoft";
                break;
              case 0x5143:
                vendor = "Qualcomm";
                break;
              default:
                vendor = "Unknown";
                break;
            }

            if (vram_bytes == 0) {
              is_unified = true;
            }
          }
          adapter->Release();
        }
        factory->Release();
      }
    }
    FreeLibrary(dxgi_lib);
  }

  if (renderer == "Windows Display Adapter") {
    DISPLAY_DEVICEW dd;
    dd.cb = sizeof(dd);
    if (EnumDisplayDevicesW(nullptr, 0, &dd, 0)) {
      std::wstring dev_str(dd.DeviceString);
      if (!dev_str.empty()) {
        renderer = std::string(dev_str.begin(), dev_str.end());
      }
    }
  }

  PlatformGpuInfo gpu_info(vendor, renderer);
  std::string api_family = "DirectX";
  std::string api_version = "12";
  gpu_info.set_api_family(api_family);
  gpu_info.set_api_version(api_version);
  if (vram_bytes > 0) {
    gpu_info.set_total_vram_bytes(vram_bytes);
  }
  gpu_info.set_is_unified_memory(is_unified);

  return gpu_info;
}

}  // namespace inside_scoop
