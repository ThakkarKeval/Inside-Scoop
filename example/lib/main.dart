import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  runApp(const InsideScoopCyberdeckApp());
}

class InsideScoopCyberdeckApp extends StatelessWidget {
  const InsideScoopCyberdeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INSIDE SCOOP // CYBERDECK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        cardColor: const Color(0xFF121826),
        primaryColor: const Color(0xFF00F0FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F0FF),
          secondary: Color(0xFFFF0055),
          tertiary: Color(0xFF00FF66),
          surface: Color(0xFF121826),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E1320),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF00F0FF),
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
      ),
      home: const CyberdeckHomeScreen(),
    );
  }
}

class CyberdeckHomeScreen extends StatefulWidget {
  const CyberdeckHomeScreen({super.key});

  @override
  State<CyberdeckHomeScreen> createState() => _CyberdeckHomeScreenState();
}

class _CyberdeckHomeScreenState extends State<CyberdeckHomeScreen> {
  final _scoop = InsideScoop.instance;

  String _platformVersion = 'Scanning...';
  AppInfo? _appInfo;
  OsInfo? _osInfo;
  DeviceInfo? _deviceInfo;
  CpuInfo? _cpuInfo;
  MemoryInfo? _memoryInfo;
  StorageInfo? _storageInfo;
  GpuInfo? _gpuInfo;
  BatteryInfo? _batteryInfo;
  NetworkInfo? _networkInfo;
  Map<ScoopFeature, ScoopCapabilityInfo> _capabilities = {};

  StreamSubscription<NetworkInfo>? _netSub;
  StreamSubscription<SystemMetricsSnapshot>? _monSub;
  Timer? _batteryTimer;
  bool _isMonitoring = false;
  int _monitoringTicks = 0;
  SystemMetricsSnapshot? _latestSnapshot;

  @override
  void initState() {
    super.initState();
    _loadAllSpecs();
    _subscribeNetwork();
  }

  @override
  void dispose() {
    _netSub?.cancel();
    _monSub?.cancel();
    _batteryTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllSpecs() async {
    String pv;
    try {
      pv = await _scoop.getPlatformVersion() ?? 'Unknown OS';
    } catch (_) {
      pv = 'Platform Engine Ready';
    }

    final app = await _scoop.app.info();
    final os = await _scoop.os.info();
    final dev = await _scoop.device.info();
    final cpu = await _scoop.cpu.info();
    final mem = await _scoop.memory.info();
    final stor = await _scoop.storage.info();
    final gpu = await _scoop.gpu.info();
    final bat = await _scoop.battery.info();
    final net = await _scoop.network.info();
    final caps = await _scoop.capabilities.getAll();

    if (!mounted) return;
    setState(() {
      _platformVersion = pv;
      _appInfo = app.valueOrNull;
      _osInfo = os.valueOrNull;
      _deviceInfo = dev.valueOrNull;
      _cpuInfo = cpu.valueOrNull;
      _memoryInfo = mem.valueOrNull;
      _storageInfo = stor.valueOrNull;
      _gpuInfo = gpu.valueOrNull;
      _batteryInfo = bat.valueOrNull;
      _networkInfo = net.valueOrNull ?? _networkInfo;
      _capabilities = caps;
    });
  }

  void _subscribeNetwork() {
    _netSub = _scoop.network.watch().listen((update) {
      if (mounted) {
        setState(() {
          _networkInfo = update;
        });
      }
    });

    // Also poll active battery & power state periodically so charging updates in real-time
    _batteryTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final batResult = await _scoop.battery.info();
      if (mounted && batResult.valueOrNull != null) {
        setState(() {
          _batteryInfo = batResult.valueOrNull;
        });
      }
    });
  }

  void _toggleTelemetry() {
    if (_isMonitoring) {
      _monSub?.cancel();
      _monSub = null;
      setState(() => _isMonitoring = false);
    } else {
      _monSub = _scoop.monitoring
          .startMonitoring(
            config: const MonitoringConfig(interval: Duration(seconds: 1)),
          )
          .listen((s) {
            if (mounted) {
              setState(() {
                _latestSnapshot = s;
                _monitoringTicks++;
                if (s.memory != null) _memoryInfo = s.memory;
                if (s.battery != null) _batteryInfo = s.battery;
              });
            }
          });
      setState(() => _isMonitoring = true);
    }
  }

  Future<void> _openDiagnosticDialog() async {
    final report = await _scoop.diagnostics.generateReport(
      options: const DiagnosticOptions(maskSignatures: true),
    );
    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E1320),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '⚡ FULL SYSTEM AUDIT REPORT',
                        style: TextStyle(
                          color: Color(0xFF00F0FF),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Color(0xFF00FF66)),
                        tooltip: 'Copy Markdown',
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: report.toMarkdown()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report copied to clipboard!'),
                              backgroundColor: Color(0xFF00FF66),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF1F293D)),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollCtrl,
                      child: SelectableText(
                        report.toMarkdown(),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Color(0xFFC9D1D9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToDetail({
    required String title,
    required IconData icon,
    required Color color,
    required String subtitle,
    required List<DetailRowItem> items,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CyberDetailScreen(
          title: title,
          icon: icon,
          accentColor: color,
          subtitle: subtitle,
          items: items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _networkInfo?.isConnected ?? false;
    final ramUsed = _memoryInfo?.usagePercentage ?? 0.0;
    final batLevel = _batteryInfo?.batteryLevel ?? 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('INSIDE SCOOP // CYBERDECK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00F0FF)),
            tooltip: 'Refresh Specs',
            onPressed: _loadAllSpecs,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00F0FF),
        foregroundColor: const Color(0xFF0A0E17),
        icon: const Icon(Icons.terminal, fontWeight: FontWeight.bold),
        label: const Text(
          'DIAGNOSTIC AUDIT',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        onPressed: _openDiagnosticDialog,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top HUD Status Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF151C2C), Color(0xFF0E1320)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOnline ? const Color(0xFF00FF66) : const Color(0xFFFF0055),
                              boxShadow: [
                                BoxShadow(
                                  color: (isOnline ? const Color(0xFF00FF66) : const Color(0xFFFF0055)).withValues(alpha: 0.8),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isOnline ? 'SYSTEM ONLINE' : 'SYSTEM AIR-GAPPED',
                            style: TextStyle(
                              color: isOnline ? const Color(0xFF00FF66) : const Color(0xFFFF0055),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          _deviceInfo?.category.name.toUpperCase() ?? 'RIG',
                          style: const TextStyle(
                            color: Color(0xFF00F0FF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _deviceInfo != null
                        ? '${_deviceInfo!.manufacturer} ${_deviceInfo!.model}'
                        : 'HARDWARE PLATFORM INITIALIZING',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'OS: ${_osInfo?.name ?? "..."} ${_osInfo?.version ?? ""} • Engine: $_platformVersion',
                    style: const TextStyle(
                      color: Color(0xFF8B949E),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // HUD Gauge Bars
                  _buildStatBar(
                    label: 'RAM CONSUMPTION',
                    valueStr: '${ramUsed.toStringAsFixed(1)}%',
                    fraction: (ramUsed / 100.0).clamp(0.0, 1.0),
                    color: ramUsed > 80 ? const Color(0xFFFF0055) : const Color(0xFF00F0FF),
                  ),
                  const SizedBox(height: 8),
                  _buildStatBar(
                    label: 'POWER CELL',
                    valueStr: _batteryInfo?.chargeWatts != null
                        ? '${_batteryInfo!.chargeWatts!.toStringAsFixed(1)}W • $batLevel% (CHARGING)'
                        : (_batteryInfo?.batteryLevel != null
                            ? '$batLevel%${_batteryInfo?.isCharging == true ? " (CHARGING)" : ""}'
                            : 'AC MAINS'),
                    fraction: (batLevel / 100.0).clamp(0.0, 1.0),
                    color: _batteryInfo?.isCharging == true
                        ? const Color(0xFFFFB800)
                        : (batLevel < 20 ? const Color(0xFFFF0055) : const Color(0xFF00FF66)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Live Telemetry Banner
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isMonitoring ? const Color(0xFF00FF66) : const Color(0xFF30363D),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isMonitoring ? Icons.sensors : Icons.sensors_off,
                    color: _isMonitoring ? const Color(0xFF00FF66) : const Color(0xFF8B949E),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isMonitoring
                              ? 'LIVE SENSOR TELEMETRY (TICK: $_monitoringTicks)'
                              : 'MONITORING ENGINE IDLE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: _isMonitoring ? const Color(0xFF00FF66) : Colors.white70,
                          ),
                        ),
                        Text(
                          _isMonitoring && _latestSnapshot?.memory != null
                              ? 'Live RAM free: ${_latestSnapshot!.memory!.availablePhysicalMb} MB'
                              : 'Tap button to stream active background metrics',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _toggleTelemetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isMonitoring ? const Color(0xFFFF0055) : const Color(0xFF00FF66),
                      foregroundColor: const Color(0xFF0A0E17),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: Text(
                      _isMonitoring ? 'HALT' : 'ENGAGE',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '// SUBSYSTEM PORTALS',
              style: TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),

            // Gamified Grid of Subsystem Portals
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildCyberTile(
                  title: 'APP CORE',
                  subtitle: _appInfo?.appName ?? 'Metadata',
                  badge: 'v${_appInfo?.version ?? "?"}',
                  icon: Icons.code,
                  accentColor: const Color(0xFF00F0FF),
                  onTap: () => _navigateToDetail(
                    title: 'APPLICATION CORE',
                    icon: Icons.code,
                    color: const Color(0xFF00F0FF),
                    subtitle: 'Binary specifications and signing identity',
                    items: [
                      DetailRowItem('App Name', _appInfo?.appName ?? 'Unknown'),
                      DetailRowItem('Package Identifier', _appInfo?.packageName ?? 'Unknown'),
                      DetailRowItem('Version Name', _appInfo?.version ?? 'Unknown'),
                      DetailRowItem('Build Number', _appInfo?.buildNumber ?? 'Unknown'),
                      DetailRowItem('Installer Store', _appInfo?.installerStore ?? 'Direct/Side-load'),
                      DetailRowItem('SHA-256 Signature', _appInfo?.buildSignature ?? 'Not provisioned'),
                    ],
                  ),
                ),
                _buildCyberTile(
                  title: 'OS KERNEL',
                  subtitle: _osInfo?.name ?? 'Operating Sys',
                  badge: _osInfo?.architecture ?? 'SYS',
                  icon: Icons.memory,
                  accentColor: const Color(0xFFFF0055),
                  onTap: () => _navigateToDetail(
                    title: 'OPERATING SYSTEM KERNEL',
                    icon: Icons.memory,
                    color: const Color(0xFFFF0055),
                    subtitle: 'Kernel architecture and system platform details',
                    items: [
                      DetailRowItem('OS Name', _osInfo?.name ?? 'Unknown'),
                      DetailRowItem('OS Version', _osInfo?.version ?? 'Unknown'),
                      DetailRowItem('Build Number', _osInfo?.buildNumber ?? 'Unknown'),
                      DetailRowItem('Architecture', _osInfo?.architecture ?? 'Unknown'),
                      DetailRowItem('Kernel Version', _osInfo?.kernelVersion ?? 'Standard kernel'),
                    ],
                  ),
                ),
                _buildCyberTile(
                  title: 'CYBERDECK',
                  subtitle: _deviceInfo?.model ?? 'Hardware',
                  badge: _deviceInfo?.isPhysicalDevice == true ? 'PHYSICAL' : 'EMULATOR',
                  icon: Icons.developer_board,
                  accentColor: const Color(0xFFFFB800),
                  onTap: () => _navigateToDetail(
                    title: 'DEVICE HARDWARE',
                    icon: Icons.developer_board,
                    color: const Color(0xFFFFB800),
                    subtitle: 'Chassis, manufacturer specs, and target topology',
                    items: [
                      DetailRowItem('Device Model', _deviceInfo?.model ?? 'Unknown'),
                      DetailRowItem('Manufacturer', _deviceInfo?.manufacturer ?? 'Unknown'),
                      DetailRowItem('Product Brand', _deviceInfo?.brand ?? 'Unknown'),
                      DetailRowItem('Form Factor', _deviceInfo?.category.name.toUpperCase() ?? 'DEVICE'),
                      DetailRowItem('Physical Device', '${_deviceInfo?.isPhysicalDevice ?? false}'),
                      DetailRowItem('Supported ABIs', _deviceInfo?.supportedAbis.join(', ') ?? 'Unknown'),
                    ],
                  ),
                ),
                _buildCyberTile(
                  title: 'NEURAL CPU',
                  subtitle: '${_cpuInfo?.logicalCores ?? "?"} Logical Cores',
                  badge: _cpuInfo?.architecture ?? 'CPU',
                  icon: Icons.developer_mode,
                  accentColor: const Color(0xFF00FF66),
                  onTap: () => _navigateToDetail(
                    title: 'CENTRAL PROCESSING UNIT',
                    icon: Icons.developer_mode,
                    color: const Color(0xFF00FF66),
                    subtitle: 'Silicon processor architecture and core hierarchy',
                    items: [
                      DetailRowItem('Processor Model', _cpuInfo?.modelName ?? 'Standard Processor'),
                      DetailRowItem('Architecture', _cpuInfo?.architecture ?? 'Unknown'),
                      DetailRowItem('Logical Cores', '${_cpuInfo?.logicalCores ?? "?"} cores'),
                      DetailRowItem('Physical Cores', '${_cpuInfo?.physicalCores ?? "Dynamic"}'),
                      DetailRowItem('Max Clock Frequency', _cpuInfo?.maxClockSpeedMhz != null ? '${_cpuInfo!.maxClockSpeedMhz} MHz' : 'System Controlled'),
                    ],
                  ),
                ),
                _buildCyberTile(
                  title: 'MEMORY RAM',
                  subtitle: '${_memoryInfo?.availablePhysicalGb.toStringAsFixed(1) ?? "?"} GB Free',
                  badge: '${ramUsed.toStringAsFixed(0)}% USED',
                  icon: Icons.pie_chart_outline,
                  accentColor: const Color(0xFFBD00FF),
                  onTap: () => _navigateToDetail(
                    title: 'RANDOM ACCESS MEMORY',
                    icon: Icons.pie_chart_outline,
                    color: const Color(0xFFBD00FF),
                    subtitle: 'System buffers and resident application consumption',
                    items: [
                      DetailRowItem('Total RAM Capacity', '${_memoryInfo?.totalPhysicalMb ?? 0} MB (${_memoryInfo?.totalPhysicalGb.toStringAsFixed(2)} GB)'),
                      DetailRowItem('Available Buffer', '${_memoryInfo?.availablePhysicalMb ?? 0} MB (${_memoryInfo?.availablePhysicalGb.toStringAsFixed(2)} GB)'),
                      DetailRowItem('Occupied RAM', '${_memoryInfo?.usedPhysicalMb ?? 0} MB (${_memoryInfo?.usagePercentage.toStringAsFixed(1)}%)'),
                      DetailRowItem('Memory Pressure Warning', '${_memoryInfo?.isLowMemory ?? false}'),
                      DetailRowItem('App Resident Bytes', _memoryInfo?.processResidentBytes != null ? '${(_memoryInfo!.processResidentBytes! / (1024 * 1024)).toStringAsFixed(1)} MB' : 'Not queried'),
                    ],
                  ),
                ),
                _buildCyberTile(
                  title: 'DATA VAULT',
                  subtitle: '${_storageInfo?.availableGb.toStringAsFixed(0) ?? "?"} GB Free',
                  badge: '${_storageInfo?.usagePercentage.toStringAsFixed(0) ?? 0}% FULL',
                  icon: Icons.sd_storage,
                  accentColor: const Color(0xFF00F0FF),
                  onTap: () => _navigateToDetail(
                    title: 'PRIMARY STORAGE VAULT',
                    icon: Icons.sd_storage,
                    color: const Color(0xFF00F0FF),
                    subtitle: 'Filesystem storage volume and application disk caching',
                    items: [
                      DetailRowItem('Total Capacity', '${_storageInfo?.totalGb.toStringAsFixed(1) ?? 0} GB (${_storageInfo?.totalMb ?? 0} MB)'),
                      DetailRowItem('Available Free Space', '${_storageInfo?.availableGb.toStringAsFixed(1) ?? 0} GB (${_storageInfo?.availableMb ?? 0} MB)'),
                      DetailRowItem('Used Blocks', '${_storageInfo?.usedGb.toStringAsFixed(1) ?? 0} GB (${_storageInfo?.usagePercentage.toStringAsFixed(1)}%)'),
                      DetailRowItem('Removable Media', '${_storageInfo?.isRemovable ?? false}'),
                      DetailRowItem('App Cache + Storage', _storageInfo?.appStorageMb != null ? '${_storageInfo!.appStorageMb!.toStringAsFixed(1)} MB' : 'Protected sandbox'),
                    ],
                  ),
                ),
                _buildCyberTile(
                  title: 'GPU VISUAL',
                  subtitle: _gpuInfo?.renderer ?? 'Graphics Engine',
                  badge: _gpuInfo?.apiFamily ?? 'GPU',
                  icon: Icons.videogame_asset,
                  accentColor: const Color(0xFFFF0055),
                  onTap: () => _navigateToDetail(
                    title: 'GRAPHICS PROCESSING UNIT',
                    icon: Icons.videogame_asset,
                    color: const Color(0xFFFF0055),
                    subtitle: 'Hardware acceleration, renderer, and graphics pipelines',
                    items: [
                      DetailRowItem('Graphics Renderer', _gpuInfo?.renderer ?? 'Unknown'),
                      DetailRowItem('Silicon Vendor', _gpuInfo?.vendor ?? 'Unknown'),
                      DetailRowItem('API Family', _gpuInfo?.apiFamily ?? 'Unknown'),
                      DetailRowItem('API Driver Version', _gpuInfo?.apiVersion ?? 'Hardware Standard'),
                      DetailRowItem('Video Memory (VRAM)', _gpuInfo?.totalVramMb != null ? '${_gpuInfo!.totalVramMb} MB' : 'Dynamically Shared'),
                      DetailRowItem('Unified Architecture', '${_gpuInfo?.isUnifiedMemory ?? false}'),
                    ],
                  ),
                ),
                _buildCyberTile(
                  title: 'POWER CELL',
                  subtitle: _batteryInfo?.chargeWatts != null
                      ? '${_batteryInfo!.chargeWatts!.toStringAsFixed(1)}W • ${_batteryInfo?.batteryLevel}%'
                      : (_batteryInfo?.batteryLevel != null ? '$batLevel%' : 'AC Powered'),
                  badge: _batteryInfo?.isCharging == true
                      ? '${_batteryInfo?.chargeWatts != null ? "${_batteryInfo!.chargeWatts}W " : ""}CHARGING'
                      : (_batteryInfo?.batteryState.name.toUpperCase() ?? 'POWER'),
                  icon: _batteryInfo?.isCharging == true ? Icons.bolt : Icons.battery_charging_full,
                  accentColor: _batteryInfo?.isCharging == true ? const Color(0xFFFFB800) : const Color(0xFF00FF66),
                  onTap: () => _navigateToDetail(
                    title: 'POWER MANAGEMENT & CELL',
                    icon: Icons.battery_charging_full,
                    color: const Color(0xFF00FF66),
                    subtitle: 'Thermal sensors, power source, and charging topology',
                    items: [
                      DetailRowItem('Battery Charge', _batteryInfo?.batteryLevel != null ? '${_batteryInfo!.batteryLevel}%' : 'Direct AC Power (No Battery)'),
                      DetailRowItem('Charging State', _batteryInfo?.batteryState.name.toUpperCase() ?? 'UNKNOWN'),
                      DetailRowItem('Power Source', _batteryInfo?.powerSource.name.toUpperCase() ?? 'MAINS'),
                      DetailRowItem('Charging Rate (Watts)', _batteryInfo?.chargeWatts != null ? '${_batteryInfo!.chargeWatts!.toStringAsFixed(2)} Watts' : 'Not Charging / Sensor Inactive'),
                      DetailRowItem('Low Power Throttling', '${_batteryInfo?.isLowPowerMode ?? false}'),
                      DetailRowItem('Thermal Reading', _batteryInfo?.temperatureCelsius != null ? '${_batteryInfo!.temperatureCelsius!.toStringAsFixed(1)} °C (${_batteryInfo!.temperatureFahrenheit!.toStringAsFixed(1)} °F)' : 'Sensor Unavailable'),
                    ],
                  ),
                ),
                _buildCyberTile(
                  title: 'UPLINK NET',
                  subtitle: _networkInfo?.primaryType.name.toUpperCase() ?? 'INTERFACES',
                  badge: isOnline ? 'ONLINE' : 'OFFLINE',
                  icon: Icons.wifi,
                  accentColor: isOnline ? const Color(0xFF00F0FF) : const Color(0xFFFF0055),
                  onTap: () => _navigateToDetail(
                    title: 'NETWORK & SUBSPACE UPLINK',
                    icon: Icons.wifi,
                    color: const Color(0xFF00F0FF),
                    subtitle: 'Real-time telemetry, routing tunnels, and interface types',
                    items: [
                      DetailRowItem('Connection Status', _networkInfo?.status.name.toUpperCase() ?? 'DISCONNECTED'),
                      DetailRowItem('Active Transport', _networkInfo?.primaryType.name.toUpperCase() ?? 'NONE'),
                      DetailRowItem('Available Interfaces', _networkInfo?.availableTypes.map((e) => e.name.toUpperCase()).join(', ') ?? 'None'),
                      DetailRowItem('Metered Connection', '${_networkInfo?.isMetered ?? false}'),
                      DetailRowItem('Encrypted VPN Shield', '${_networkInfo?.isVpnActive ?? false}'),
                    ],
                  ),
                ),
                _buildCyberTile(
                  title: 'CAPABILITIES',
                  subtitle: '${_capabilities.length} Features',
                  badge: 'MATRIX',
                  icon: Icons.security,
                  accentColor: const Color(0xFFFFB800),
                  onTap: () => _navigateToDetail(
                    title: 'CAPABILITY MATRIX',
                    icon: Icons.security,
                    color: const Color(0xFFFFB800),
                    subtitle: 'Runtime sandbox security rules and feature permissions',
                    items: _capabilities.entries
                        .map(
                          (e) => DetailRowItem(
                            e.key.name,
                            e.value.state.name.toUpperCase(),
                            detailNote: e.value.description,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Padding for FloatingActionButton
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar({
    required String label,
    required String valueStr,
    required double fraction,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              valueStr,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: const Color(0xFF1F293D),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCyberTile({
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: const Color(0xFF121826),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: accentColor, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DetailRowItem {
  DetailRowItem(this.label, this.value, {this.detailNote});
  final String label;
  final String value;
  final String? detailNote;
}

class CyberDetailScreen extends StatelessWidget {
  const CyberDetailScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.subtitle,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final String subtitle;
  final List<DetailRowItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          color: accentColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: const Color(0xFF121826),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF8B949E),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '// TELEMETRY REGISTERS',
              style: TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final item = items[idx];
                return Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151C2C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF212B3D)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        item.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.detailNote != null && item.detailNote!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.detailNote!,
                          style: TextStyle(
                            color: accentColor.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
