import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';
import 'package:inside_scoop/inside_scoop_method_channel.dart';
import 'package:inside_scoop/src/messages.g.dart';

class FakeInsideScoopHostApi extends InsideScoopHostApi {
  @override
  Future<String?> getPlatformVersion() async => '42';

  @override
  Future<PlatformAppInfo> getAppInfo() async => PlatformAppInfo(
    appName: 'TestApp',
    packageName: 'com.test.pkg',
    version: '1.2.3',
    buildNumber: '99',
    buildSignature: 'sig123',
    installerStore: 'Store',
  );

  @override
  Future<PlatformOsInfo> getOsInfo() async => PlatformOsInfo(
    name: 'Linux',
    version: '6.5',
    buildNumber: '6.5.0-generic',
    architecture: 'x86_64',
    kernelVersion: '6.5.0',
  );

  @override
  Future<PlatformDeviceInfo> getDeviceInfo() async => PlatformDeviceInfo(
    model: 'UbuntuStation',
    manufacturer: 'Dell',
    brand: 'XPS',
    categoryIndex: 3, // laptop
    isPhysicalDevice: true,
    supportedAbis: ['x86_64'],
  );

  @override
  Future<PlatformCpuInfo> getCpuInfo() async => PlatformCpuInfo(
    architecture: 'x86_64',
    modelName: 'Intel Core i7-1185G7',
    physicalCores: 4,
    logicalCores: 8,
    maxClockSpeedMhz: 3000,
    systemUtilization: 25.0,
    processUtilization: 5.0,
  );

  @override
  Future<PlatformMemoryInfo> getMemoryInfo() async => PlatformMemoryInfo(
    totalPhysicalBytes: 17179869184,
    availablePhysicalBytes: 8589934592,
    processResidentBytes: 104857600,
    processVirtualBytes: 209715200,
    isLowMemory: false,
    totalPssBytes: 78643200,
    jvmHeapAllocatedBytes: 52428800,
    jvmHeapUsedBytes: 31457280,
  );

  @override
  Future<PlatformStorageInfo> getStorageInfo() async => PlatformStorageInfo(
    totalBytes: 512 * 1024 * 1024 * 1024,
    availableBytes: 256 * 1024 * 1024 * 1024,
    appStorageBytes: 1048576000,
    isRemovable: false,
  );

  @override
  Future<PlatformGpuInfo> getGpuInfo() async => PlatformGpuInfo(
    vendor: 'NVIDIA',
    renderer: 'GeForce RTX 4080',
    apiFamily: 'DirectX',
    apiVersion: '12',
    totalVramBytes: 17179869184,
    isUnifiedMemory: false,
  );

  @override
  Future<PlatformBatteryInfo> getBatteryInfo() async => PlatformBatteryInfo(
    batteryLevel: 75,
    batteryStateIndex: 1, // discharging
    powerSourceIndex: 0, // battery
    isLowPowerMode: false,
    temperatureCelsius: 27.5,
  );

  @override
  Future<PlatformNetworkInfo> getNetworkInfo() async => PlatformNetworkInfo(
    statusIndex: 0, // connected
    primaryTypeIndex: 0, // wifi
    availableTypeIndices: [0, 1], // wifi, cellular
    isMetered: false,
    isVpnActive: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getPlatformVersion', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    expect(await platform.getPlatformVersion(), '42');
  });

  test('getAppInfo converts PlatformAppInfo to AppInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final appInfo = await platform.getAppInfo();
    expect(appInfo.appName, equals('TestApp'));
    expect(appInfo.packageName, equals('com.test.pkg'));
    expect(appInfo.version, equals('1.2.3'));
    expect(appInfo.buildNumber, equals('99'));
    expect(appInfo.buildSignature, equals('sig123'));
    expect(appInfo.installerStore, equals('Store'));
  });

  test('getOsInfo converts PlatformOsInfo to OsInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final osInfo = await platform.getOsInfo();
    expect(osInfo.name, equals('Linux'));
    expect(osInfo.version, equals('6.5'));
    expect(osInfo.buildNumber, equals('6.5.0-generic'));
    expect(osInfo.architecture, equals('x86_64'));
    expect(osInfo.kernelVersion, equals('6.5.0'));
  });

  test('getDeviceInfo converts PlatformDeviceInfo to DeviceInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final deviceInfo = await platform.getDeviceInfo();
    expect(deviceInfo.model, equals('UbuntuStation'));
    expect(deviceInfo.manufacturer, equals('Dell'));
    expect(deviceInfo.brand, equals('XPS'));
    expect(deviceInfo.category, equals(DeviceCategory.laptop));
    expect(deviceInfo.isPhysicalDevice, isTrue);
    expect(deviceInfo.supportedAbis, contains('x86_64'));
  });

  test('getCpuInfo converts PlatformCpuInfo to CpuInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final cpuInfo = await platform.getCpuInfo();
    expect(cpuInfo.architecture, equals('x86_64'));
    expect(cpuInfo.modelName, equals('Intel Core i7-1185G7'));
    expect(cpuInfo.physicalCores, equals(4));
    expect(cpuInfo.logicalCores, equals(8));
    expect(cpuInfo.maxClockSpeedMhz, equals(3000));
    expect(cpuInfo.systemUtilization, equals(25.0));
    expect(cpuInfo.processUtilization, equals(5.0));
  });

  test('getMemoryInfo converts PlatformMemoryInfo to MemoryInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final memInfo = await platform.getMemoryInfo();
    expect(memInfo.totalPhysicalBytes, equals(17179869184));
    expect(memInfo.availablePhysicalBytes, equals(8589934592));
    expect(memInfo.usedPhysicalBytes, equals(8589934592));
    expect(memInfo.processResidentBytes, equals(104857600));
    expect(memInfo.processVirtualBytes, equals(209715200));
    expect(memInfo.totalPssBytes, equals(78643200));
    expect(memInfo.jvmHeapAllocatedBytes, equals(52428800));
    expect(memInfo.jvmHeapUsedBytes, equals(31457280));
    expect(memInfo.isLowMemory, isFalse);

    // Verify detailed ProcessMemoryInfo breakdown
    expect(memInfo.process, isNotNull);
    expect(memInfo.process!.residentSetBytes, equals(104857600));
    expect(memInfo.process!.virtualBytes, equals(209715200));
    expect(memInfo.process!.totalPssBytes, equals(78643200));
    expect(memInfo.process!.javaHeapAllocatedBytes, equals(52428800));
    expect(memInfo.process!.javaHeapUsedBytes, equals(31457280));
  });

  test('getStorageInfo converts PlatformStorageInfo to StorageInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final storageInfo = await platform.getStorageInfo();
    expect(storageInfo.totalBytes, equals(512 * 1024 * 1024 * 1024));
    expect(storageInfo.availableBytes, equals(256 * 1024 * 1024 * 1024));
    expect(storageInfo.usedBytes, equals(256 * 1024 * 1024 * 1024));
    expect(storageInfo.appStorageBytes, equals(1048576000));
    expect(storageInfo.isRemovable, isFalse);
  });

  test('getGpuInfo converts PlatformGpuInfo to GpuInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final gpuInfo = await platform.getGpuInfo();
    expect(gpuInfo.vendor, equals('NVIDIA'));
    expect(gpuInfo.renderer, equals('GeForce RTX 4080'));
    expect(gpuInfo.apiFamily, equals('DirectX'));
    expect(gpuInfo.apiVersion, equals('12'));
    expect(gpuInfo.totalVramBytes, equals(17179869184));
    expect(gpuInfo.isUnifiedMemory, isFalse);
  });

  test('getBatteryInfo converts PlatformBatteryInfo to BatteryInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final batteryInfo = await platform.getBatteryInfo();
    expect(batteryInfo.batteryLevel, equals(75));
    expect(batteryInfo.batteryState, equals(BatteryState.discharging));
    expect(batteryInfo.powerSource, equals(PowerSource.battery));
    expect(batteryInfo.isLowPowerMode, isFalse);
    expect(batteryInfo.temperatureCelsius, equals(27.5));
  });

  test('getNetworkInfo converts PlatformNetworkInfo to NetworkInfo', () async {
    final platform = MethodChannelInsideScoop(
      hostApi: FakeInsideScoopHostApi(),
    );
    final netInfo = await platform.getNetworkInfo();
    expect(netInfo.status, equals(NetworkStatus.connected));
    expect(netInfo.primaryType, equals(NetworkConnectionType.wifi));
    expect(netInfo.availableTypes.length, equals(2));
    expect(netInfo.isMetered, isFalse);
    expect(netInfo.isVpnActive, isFalse);
    expect(netInfo.isConnected, isTrue);
  });
}
