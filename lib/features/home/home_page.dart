import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test_pro/flutter_internet_speed_test_pro.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:plan_flex/core/services/data_usage_service.dart';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'SIM',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hari ini',
                    style: TextStyle(color: Colors.brown.shade700),
                  ),
                  Text(
                    simTodayUsage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '1 bulan',
                    style: TextStyle(color: Colors.brown.shade700),
                  ),
                  Text(
                    simMonthUsage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 90,
              color: Colors.brown.shade200,
            ),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'WiFi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hari ini',
                    style: TextStyle(color: Colors.brown.shade700),
                  ),
                  Text(
                    wifiTodayUsage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '1 bulan',
                    style: TextStyle(color: Colors.brown.shade700),
                  ),
                  Text(
                    wifiMonthUsage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Status: $connectionType',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5D4037),
              fontWeight: FontWeight.w500,
            ),
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
        'icon': Icons.code,
        'url': 'https://github.com',
      },
      {
        'nama': 'Google',
        'icon': Icons.search,
        'url': 'https://google.com',
      },
      {
        'nama': 'Facebook',
        'icon': Icons.facebook,
        'url': 'https://facebook.com',
      },
      {
        'nama': 'YouTube',
        'icon': Icons.play_circle,
        'url': 'https://youtube.com',
      },
    ];

    return Container(
      color: const Color(0xFFDDB892),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            color: const Color(0xFFF5E6CC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SpeedometerGauge(
                    speed: currentSpeed,
                    isTesting: isTesting,
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    statusIcon,
                    size: 36,
                    color: const Color(0xFF5D4037),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    testStatus,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              downloadSpeed.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                            const Text("Mbps download"),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.brown.shade200,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              uploadSpeed.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                            const Text("Mbps upload"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  usageSection(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDDB892),
                            foregroundColor: const Color(0xFF5D4037),
                          ),
                          onPressed: isTesting ? null : startSpeedTest,
                          child: Text(
                            isTesting ? "TESTING..." : "START TEST",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed:
                            loadingUsage || isTesting ? null : refreshData,
                        icon: loadingUsage
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menu.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final item = menu[index];

              return InkWell(
                onTap: () => bukaUrl(item['url'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Card(
                  elevation: 3,
                  color: const Color(0xFFF5E6CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 42,
                        color: const Color(0xFF5D4037),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['nama'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SpeedometerGauge extends StatelessWidget {
  final double speed;
  final bool isTesting;

  const SpeedometerGauge({
    super.key,
    required this.speed,
    required this.isTesting,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: speed,
      ),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, animatedSpeed, child) {
        return SizedBox(
          width: 300,
          height: 230,
          child: CustomPaint(
            painter: SpeedometerPainter(
              speed: animatedSpeed,
              isTesting: isTesting,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 45),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      animatedSpeed.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Megabits per second",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double speed;
  final bool isTesting;

  SpeedometerPainter({
    required this.speed,
    required this.isTesting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height * 0.78,
    );

    final radius = size.width * 0.39;

    const double startAngle = 2.55;
    const double sweepAngle = 4.32;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    final backgroundPaint = Paint()
      ..color = Colors.brown.shade200
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = isTesting
          ? const Color(0xFFDDB892)
          : Colors.transparent
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    final percent = (speed / 100).clamp(0.0, 1.0);

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * percent,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SpeedometerPainter oldDelegate) {
    return oldDelegate.speed != speed ||
        oldDelegate.isTesting != isTesting;
  }
}