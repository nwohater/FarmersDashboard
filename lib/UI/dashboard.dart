import 'package:farmerdashboard/UI/server_selection.dart';
import 'package:farmerdashboard/UI/servers.dart';
import 'package:flutter/material.dart';
import 'package:farmerdashboard/Utils/sftp_sync2.dart';
import 'package:farmerdashboard/Models/gamedata_model.dart';
import 'package:farmerdashboard/UI/Widgets/weather_widget.dart';
import 'package:farmerdashboard/UI/Widgets/date_widget.dart';
import '../Utils/sqlite.dart';
import 'Widgets/farm_widget.dart';
import 'Widgets/forecast_widget.dart';
import 'Widgets/offers_widget.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  GameData? _gameData;
  Map<String, dynamic>? _defaultConnection;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
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
      // No default, but at least one connection – pick first
      _defaultConnection = connections.first;
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
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/images/tractor1.png'),
      ),
      centerTitle: true,
      title: const Text(
        "Farmer's Dashboard",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      backgroundColor: Colors.green,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          iconSize: 26,
          tooltip: 'Manage Connections',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ServersSelectionScreen(),
              ),
            );
          },
        ),
      ],
    );

    if (_loading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_gameData == null) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: Text('No data to display.')),
      );
    }

    final String condition = _gameData!.weather.condition;
    final double temperatureF = _gameData!.weather.temperatureF;
    final String date = _gameData!.date.monthName.isNotEmpty
        ? '${_gameData!.date.monthName} ${_gameData!.date.day}'
        : 'Date N/A';
    final List<Farm> validFarms = _gameData!.farms.where((farm) {
      return farm.name.trim().isNotEmpty;
    }).toList();
    final List<SpecialOffer> specialOffers = _gameData!.specialOffers;

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background2.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 2.0,
                child: ListView(
                  children: [
                    if (_defaultConnection != null &&
                        (_defaultConnection!['servername']
                            ?.toString()
                            .isNotEmpty ??
                            false))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_defaultConnection!['servername']}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _pickServer,
                              child: Image.asset(
                                'assets/images/switch.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DateWidget(Date: date, Time: _gameData!.time),
                        const Divider(height: 20, thickness: 1),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Current Weather",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        WeatherWidget(
                          condition: condition,
                          temperature: temperatureF,
                        ),
                        const Divider(height: 20, thickness: 1),
                        if (_gameData!.weather.forecast.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/forecast.png',
                                width: 40,
                                height: 40,
                              ),
                              const Text(
                                "Weather Forecast",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ForecastWidget(
                            currentWeatherData: _gameData!.weather,
                            forecastDynamicItems: _gameData!.weather.forecast,
                          ),
                          const Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
                        ],
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/farmer1.png',
                              width: 40,
                              height: 40,
                            ),
                            const Text(
                              "The Farm Report",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        if (validFarms.isNotEmpty) ...[
                          ...validFarms.map((farm) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: FarmWidget(
                                farmName: farm.name,
                                money: farm.money,
                              ),
                            );
                          }).toList(),
                        ] else ...[
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('No farms to display.')),
                          ),
                        ],
                        const SizedBox(height: 5),
                        const Divider(height: 20, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Forsale.png',
                              width: 50,
                              height: 50,
                            ),
                            const Text(
                              'Special Deals',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (specialOffers.isNotEmpty) ...[
                          ...specialOffers.map((offer) {
                            return SpecialOfferWidget(offer: offer);
                          }).toList(),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text(
                                'No deals available at the moment.',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
