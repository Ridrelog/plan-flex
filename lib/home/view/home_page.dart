import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test_pro/flutter_internet_speed_test_pro.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/data_usage_service.dart';
import '../widgets/speedometer_gauge.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static double savedDownloadSpeed = 0.0;
  static double savedUploadSpeed = 0.0;
  static double savedCurrentSpeed = 0.0;

  final FlutterInternetSpeedTest _speedTest = FlutterInternetSpeedTest();
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectionSub;

  double downloadSpeed = 0.0;
  double uploadSpeed = 0.0;
  double currentSpeed = 0.0;

  bool isTesting = false;
  bool loadingUsage = false;
  bool sudahBukaSettings = false;

  String simTodayUsage = '0 MB';
  String simMonthUsage = '0 MB';
  String wifiTodayUsage = '0 MB';
  String wifiMonthUsage = '0 MB';

  String connectionType = 'Mengecek...';

  String testStatus = 'Tap START TEST';
  IconData statusIcon = Icons.speed;

  @override
  void initState() {
    super.initState();

    downloadSpeed = savedDownloadSpeed;
    uploadSpeed = savedUploadSpeed;
    currentSpeed = savedCurrentSpeed;

    cekPermissionDanLoad();
    checkConnection();
    listenConnection();
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    super.dispose();
  }

  void simpanSpeedSementara() {
    savedDownloadSpeed = downloadSpeed;
    savedUploadSpeed = uploadSpeed;
    savedCurrentSpeed = currentSpeed;
  }

  void resetSpeedSementara() {
    savedDownloadSpeed = 0.0;
    savedUploadSpeed = 0.0;
    savedCurrentSpeed = 0.0;
  }

  Future<void> cekPermissionDanLoad() async {
    if (!mounted) return;

    setState(() => loadingUsage = true);

    try {
      final aktif = await DataUsageService.hasUsagePermission();

      if (!mounted) return;

      if (!aktif) {
        setState(() {
          simTodayUsage = 'Butuh izin';
          simMonthUsage = 'Butuh izin';
          wifiTodayUsage = 'Butuh izin';
          wifiMonthUsage = 'Butuh izin';
          loadingUsage = false;
        });

        if (!sudahBukaSettings) {
          sudahBukaSettings = true;
          await DataUsageService.openUsageSettings();
        }

        return;
      }

      sudahBukaSettings = false;
      await loadUsage();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        simTodayUsage = 'Gagal';
        simMonthUsage = 'Gagal';
        wifiTodayUsage = 'Gagal';
        wifiMonthUsage = 'Gagal';
        loadingUsage = false;
      });
    }
  }

  Future<void> loadUsage() async {
    try {
      final todayData = await DataUsageService.getTodayUsage();
      final monthData = await DataUsageService.getMonthUsage();

      if (!mounted) return;

      setState(() {
        simTodayUsage = todayData['mobile'].toString();
        wifiTodayUsage = todayData['wifi'].toString();

        simMonthUsage = monthData['mobile'].toString();
        wifiMonthUsage = monthData['wifi'].toString();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        simTodayUsage = 'Gagal';
        simMonthUsage = 'Gagal';
        wifiTodayUsage = 'Gagal';
        wifiMonthUsage = 'Gagal';
      });
    } finally {
      if (mounted) {
        setState(() => loadingUsage = false);
      }
    }
  }

  Future<void> checkConnection() async {
    final result = await _connectivity.checkConnectivity();

    if (!mounted) return;

    updateConnection(result);
  }

  void listenConnection() {
    _connectionSub = _connectivity.onConnectivityChanged.listen((result) {
      if (!mounted) return;
      updateConnection(result);
    });
  }

  void updateConnection(List<ConnectivityResult> result) {
    String type = 'Tidak ada koneksi';

    if (result.contains(ConnectivityResult.wifi)) {
      type = 'WiFi aktif';
    } else if (result.contains(ConnectivityResult.mobile)) {
      type = 'Kuota aktif';
    } else if (result.contains(ConnectivityResult.ethernet)) {
      type = 'Ethernet aktif';
    }

    if (!mounted) return;

    setState(() {
      connectionType = type;
    });
  }

  Future<void> refreshData() async {
    if (loadingUsage || isTesting) return;

    setState(() {
      downloadSpeed = 0.0;
      uploadSpeed = 0.0;
      currentSpeed = 0.0;
      testStatus = 'Tap START TEST';
      statusIcon = Icons.speed;
    });

    resetSpeedSementara();

    await cekPermissionDanLoad();
    await checkConnection();
  }

  void startSpeedTest() async {
    if (isTesting) return;

    setState(() {
      isTesting = true;
      downloadSpeed = 0.0;
      uploadSpeed = 0.0;
      currentSpeed = 0.0;
      testStatus = 'Menyiapkan test...';
      statusIcon = Icons.speed;
    });

    resetSpeedSementara();

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      testStatus = 'Testing download...';
      statusIcon = Icons.arrow_downward;
    });

    _speedTest.startTesting(
      useFastApi: true,
      onStarted: () {
        if (!mounted) return;

        setState(() {
          testStatus = 'Testing download...';
          statusIcon = Icons.arrow_downward;
        });
      },
      onProgress: (percent, data) {
        if (!mounted) return;

        setState(() {
          currentSpeed = data.transferRate;

          if (data.type == TestType.download) {
            downloadSpeed = data.transferRate;
            testStatus = 'Testing download...';
            statusIcon = Icons.arrow_downward;
          } else {
            uploadSpeed = data.transferRate;
            testStatus = 'Testing upload...';
            statusIcon = Icons.arrow_upward;
          }
        });

        simpanSpeedSementara();
      },
      onDownloadComplete: (data) {
        if (!mounted) return;

        setState(() {
          downloadSpeed = data.transferRate;
          currentSpeed = data.transferRate;
          testStatus = 'Testing upload...';
          statusIcon = Icons.arrow_upward;
        });

        simpanSpeedSementara();
      },
      onUploadComplete: (data) {
        if (!mounted) return;

        setState(() {
          uploadSpeed = data.transferRate;
          currentSpeed = data.transferRate;
        });

        simpanSpeedSementara();
      },
      onCompleted: (download, upload) async {
        if (!mounted) return;

        setState(() {
          downloadSpeed = download.transferRate;
          uploadSpeed = upload.transferRate;
          currentSpeed = upload.transferRate;
          isTesting = false;
          testStatus = 'Selesai';
          statusIcon = Icons.check_circle;
        });

        simpanSpeedSementara();

        await cekPermissionDanLoad();
      },
      onError: (_, __) {
        if (!mounted) return;

        setState(() {
          isTesting = false;
          currentSpeed = 0.0;
          downloadSpeed = 0.0;
          uploadSpeed = 0.0;
          testStatus = 'Gagal';
          statusIcon = Icons.error;
        });

        resetSpeedSementara();
      },
    );
  }

  Future<void> bukaUrl(String url) async {
    final uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Widget usageSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _UsageMiniCard(
                title: 'SIM',
                icon: Icons.sim_card_rounded,
                today: simTodayUsage,
                month: simMonthUsage,
                loading: loadingUsage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _UsageMiniCard(
                title: 'WiFi',
                icon: Icons.wifi_rounded,
                today: wifiTodayUsage,
                month: wifiMonthUsage,
                loading: loadingUsage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4FBF6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD7E8DC)),
          ),
          child: Row(
            children: [
              const Icon(Icons.router_rounded, color: Color(0xFF235347), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Status: $connectionType',
                  style: const TextStyle(
                    color: Color(0xFF051F20),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = [
      {
        'nama': 'GitHub',
        'icon': Icons.code_rounded,
        'url': 'https://github.com',
      },
      {
        'nama': 'Google',
        'icon': Icons.search_rounded,
        'url': 'https://google.com',
      },
      {
        'nama': 'Facebook',
        'icon': Icons.facebook_rounded,
        'url': 'https://facebook.com',
      },
      {
        'nama': 'YouTube',
        'icon': Icons.play_circle_rounded,
        'url': 'https://youtube.com',
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4FBF6), Color(0xFFEAF6EE)],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: refreshData,
        color: const Color(0xFF235347),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF235347), Color(0xFF8EB69B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF235347).withOpacity(0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(statusIcon, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Speed Test',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              testStatus,
                              style: const TextStyle(
                                color: Color(0xFFE9F6EE),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          color: Colors.white,
                          onPressed: loadingUsage || isTesting ? null : refreshData,
                          icon: loadingUsage
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      children: [
                        SpeedometerGauge(speed: currentSpeed, isTesting: isTesting),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _SpeedInfoCard(
                                title: 'Download',
                                value: downloadSpeed.toStringAsFixed(2),
                                icon: Icons.arrow_downward_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SpeedInfoCard(
                                title: 'Upload',
                                value: uploadSpeed.toStringAsFixed(2),
                                icon: Icons.arrow_upward_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isTesting ? null : startSpeedTest,
                            icon: Icon(isTesting ? Icons.hourglass_top_rounded : Icons.play_arrow_rounded),
                            label: Text(isTesting ? 'TESTING...' : 'START TEST'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Pemakaian Data',
              subtitle: 'Pantau pemakaian SIM dan WiFi',
              icon: Icons.data_usage_rounded,
              child: usageSection(),
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                'Shortcut Website',
                style: TextStyle(
                  color: Color(0xFF051F20),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menu.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.22,
              ),
              itemBuilder: (context, index) {
                final item = menu[index];
                return InkWell(
                  onTap: () => bukaUrl(item['url'] as String),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD7E8DC)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF235347).withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5F2E9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 26,
                            color: const Color(0xFF235347),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['nama'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF051F20),
                                ),
                              ),
                            ),
                            const Icon(Icons.open_in_new_rounded, size: 18, color: Color(0xFF8EB69B)),
                          ],
                        ),
                      ],
                    ),
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

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFD7E8DC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF235347).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F2E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF235347), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF051F20),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF56746B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SpeedInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SpeedInfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E8DC)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF235347), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF051F20),
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'Mbps $title',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF56746B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageMiniCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String today;
  final String month;
  final bool loading;

  const _UsageMiniCard({
    required this.title,
    required this.icon,
    required this.today,
    required this.month,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7E8DC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF235347), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF051F20),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _UsageLine(label: 'Hari ini', value: today, loading: loading),
          const SizedBox(height: 8),
          _UsageLine(label: '1 bulan', value: month, loading: loading),
        ],
      ),
    );
  }
}

class _UsageLine extends StatelessWidget {
  final String label;
  final String value;
  final bool loading;

  const _UsageLine({
    required this.label,
    required this.value,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF56746B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: loading
              ? const _LoadingTextBar(key: ValueKey('loading'))
              : Text(
                  value,
                  key: ValueKey(value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF051F20),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ],
    );
  }
}

class _LoadingTextBar extends StatefulWidget {
  const _LoadingTextBar({super.key});

  @override
  State<_LoadingTextBar> createState() => _LoadingTextBarState();
}

class _LoadingTextBarState extends State<_LoadingTextBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.38, end: 1).animate(_controller),
      child: Container(
        width: 74,
        height: 15,
        decoration: BoxDecoration(
          color: const Color(0xFFD7E8DC),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
