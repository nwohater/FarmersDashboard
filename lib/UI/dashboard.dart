import 'package:farmerdashboard/UI/server_selection.dart';
import 'package:farmerdashboard/UI/servers.dart';
import 'package:farmerdashboard/UI/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:farmerdashboard/Utils/sftp_sync2.dart';
import 'package:farmerdashboard/Models/gamedata_model.dart';
import '../Utils/sqlite.dart';
import 'Widgets/farm_widget2.dart';
import 'Widgets/field_widget2.dart';
import 'Widgets/forecast_widget_new.dart';
import 'Widgets/offers_widget3.dart';
import 'Widgets/dateweather_widget.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin {
  GameData? _gameData;
  Map<String, dynamic>? _defaultConnection;
  bool _loading = true;
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeInOut,
    );
    _initializeDashboard();
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    super.dispose();
  }

  Future<void> _initializeDashboard() async {
    await _checkDefaultServer();
    if (_defaultConnection != null) {
      await _loadData();
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
      _fadeController?.forward();
    }
  }

  Future<void> _pickServer() async {
    final selected = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const ServerPickerScreen()),
    );

    if (selected != null) {
      setState(() {
        _defaultConnection = selected;
        _loading = true;
      });
      await _loadData();
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _checkDefaultServer() async {
    final db = SftpDatabase();
    final connections = await db.getConnections();

    if (connections.isEmpty) {
      if (!mounted) return;
      // No connections at all – let user create one
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServersSelectionScreen()),
      );
      // Re-run full initialization after returning
      await _initializeDashboard();
      return;
    }

    // Try to find default connection
    final defaultConn = connections.firstWhere(
      (conn) => conn['isdefault'] == 1,
      orElse: () => {},
    );

    if (defaultConn.isNotEmpty) {
      _defaultConnection = defaultConn;
    } else {
      // No default, but at least one connection – set first as default
      _defaultConnection = connections.first;
      // Set the first connection as default in the database
      await db.setAsDefault(_defaultConnection!['id']);
    }
  }

  Future<void> _loadData() async {
    if (_defaultConnection == null) return;

    final result = await downloadJsonFile(_defaultConnection!);

    if (!result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final gameData = await loadGameData();
    if (gameData != null) {
      setState(() {
        _gameData = gameData;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load GameData.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.help_outline, color: Colors.white70),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpScreen()),
          );
        },
      ),
      centerTitle: true,
      title: const Text(
        "Farmers Dashboard",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w300,
          fontSize: 20,
          letterSpacing: 1.5,
        ),
      ),
      backgroundColor: const Color(0xFF1a1a2e),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white70),
          tooltip: 'Manage Connections',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServersSelectionScreen()),
            );
          },
        ),
      ],
    );

    if (_loading) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: const Color(0xFF0f0f1e),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade300),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Loading farm data...',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_gameData == null) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: const Color(0xFF0f0f1e),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 80,
                color: Colors.grey.shade700,
              ),
              const SizedBox(height: 24),
              Text(
                'No data available',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load data from the server',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      setState(() {
                        _loading = true;
                      });
                      await _loadData();
                      setState(() {
                        _loading = false;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _pickServer,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Change Server'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal.shade300,
                      side: BorderSide(color: Colors.teal.shade700),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final String condition = _gameData!.weather.condition;
    final double temperatureF = _gameData!.weather.temperatureF;
    final String date =
        _gameData!.date.monthName.isNotEmpty
            ? '${_gameData!.date.monthName} ${_gameData!.date.day}'
            : 'Date N/A';
    final List<Farm> validFarms =
        _gameData!.farms.where((farm) {
          return farm.name.trim().isNotEmpty;
        }).toList();
    final List<SpecialOffer> specialOffers = _gameData!.specialOffers;

    return Scaffold(
      appBar: appBar,
      backgroundColor: const Color(0xFF0f0f1e),
      body:
          _fadeAnimation != null
              ? FadeTransition(
                opacity: _fadeAnimation!,
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: Colors.teal.shade300,
                  backgroundColor: const Color(0xFF1a1a2e),
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (_defaultConnection != null &&
                          (_defaultConnection!['servername']
                                  ?.toString()
                                  .isNotEmpty ??
                              false))
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1a1a2e),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.teal.shade900.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.dns_outlined,
                                    color: Colors.teal.shade300,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_defaultConnection!['servername']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade300,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.swap_horiz,
                                  color: Colors.teal.shade300,
                                  size: 20,
                                ),
                                onPressed: _pickServer,
                                tooltip: 'Switch Server',
                              ),
                            ],
                          ),
                        ),
                      DateWeatherWidget(
                        date: date,
                        time: _gameData!.time,
                        condition: condition,
                        temperature: temperatureF,
                      ),
                      if (_gameData!.weather.forecast.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ForecastWidget(
                          currentWeatherData: _gameData!.weather,
                          forecastDynamicItems: _gameData!.weather.forecast,
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (validFarms.isNotEmpty) ...[
                        ...validFarms.asMap().entries.map((entry) {
                          final index = entry.key;
                          final farm = entry.value;
                          final fieldsForFarm =
                              _gameData!.fields
                                  .where(
                                    (field) =>
                                        field.farmName.trim() ==
                                        farm.name.trim(),
                                  )
                                  .toList();

                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: 400 + (index * 100),
                            ),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FarmWidget(
                                    farmName: farm.name,
                                    money: farm.money,
                                    loanAmount: farm.loan,
                                  ),
                                  if (fieldsForFarm.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    ...fieldsForFarm.map((field) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                        ),
                                        child: FieldWidget(
                                          field: field,
                                          currentMonth:
                                              _gameData!.date.month - 1,
                                        ),
                                      );
                                    }),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Text(
                              'No farms to display',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (specialOffers.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...specialOffers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final offer = entry.value;
                          return TweenAnimationBuilder<double>(
                            duration: Duration(
                              milliseconds: 600 + (index * 100),
                            ),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: SpecialOfferWidget(offer: offer),
                          );
                        }),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(
                            child: Text(
                              'No deals available at the moment',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadData,
                color: Colors.teal.shade300,
                backgroundColor: const Color(0xFF1a1a2e),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        color: Colors.teal.shade300,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
