import 'package:farmerdashboard/UI/server_selection.dart';
import 'package:farmerdashboard/UI/servers.dart';
import 'package:farmerdashboard/UI/help_screen.dart';
import 'package:flutter/material.dart';
import 'package:farmerdashboard/Utils/sftp_sync2.dart';
import 'package:farmerdashboard/Models/gamedata_model.dart';
import 'package:farmerdashboard/UI/Widgets/weather_widget2.dart';
import 'package:farmerdashboard/UI/Widgets/date_widget2.dart';
import '../Utils/sqlite.dart';
import 'Widgets/farm_widget.dart';
import 'Widgets/field_widget2.dart';
import 'Widgets/forecast_widget2.dart';
import 'Widgets/offers_widget2.dart';

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
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/tractor1.png'),
        ),
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
      backgroundColor: const Color(0xFF00796B),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          iconSize: 26,
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_gameData == null) {
      return Scaffold(
        appBar: appBar,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No data to display',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unable to load data from the server',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _pickServer,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Change Server'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
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
      // 🔥 Drop the background image and use a gradient background instead
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            // Teal to light teal gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _pickServer,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/switch2.png',
                                width: 28,
                                height: 28,
                              ),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/weather.png', // Your cool icon
                              width:
                                  MediaQuery.of(context).size.width < 400
                                      ? 32
                                      : 40,
                              height:
                                  MediaQuery.of(context).size.width < 400
                                      ? 32
                                      : 40,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Current Weather",
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 400
                                          ? 18
                                          : 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
                              width:
                                  MediaQuery.of(context).size.width < 400
                                      ? 32
                                      : 40,
                              height:
                                  MediaQuery.of(context).size.width < 400
                                      ? 32
                                      : 40,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Weather Forecast",
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 400
                                          ? 18
                                          : 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ForecastWidget(
                          currentWeatherData: _gameData!.weather,
                          forecastDynamicItems: _gameData!.weather.forecast,
                        ),
                        const Divider(
                          height: 30,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                      ],
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/barn1.png',
                            width:
                                MediaQuery.of(context).size.width < 400
                                    ? 32
                                    : 40,
                            height:
                                MediaQuery.of(context).size.width < 400
                                    ? 32
                                    : 40,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "The Farm Report",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width < 400
                                        ? 18
                                        : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      if (validFarms.isNotEmpty) ...[
                        ...validFarms.map((farm) {
                          final fieldsForFarm =
                              _gameData!.fields
                                  .where(
                                    (field) =>
                                        field.farmName.trim() ==
                                        farm.name.trim(),
                                  )
                                  .toList();

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FarmWidget(
                                  farmName: farm.name,
                                  money: farm.money,
                                  loanAmount: farm.loan,
                                ),
                                if (fieldsForFarm.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          fieldsForFarm.map((field) {
                                            return Center(
                                              child: FieldWidget(
                                                field: field,
                                                currentMonth:
                                                    _gameData!.date.month,
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ],
                              ],
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
                            width:
                                MediaQuery.of(context).size.width < 400
                                    ? 40
                                    : 50,
                            height:
                                MediaQuery.of(context).size.width < 400
                                    ? 40
                                    : 50,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Special Deals',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width < 400
                                        ? 18
                                        : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
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
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
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
      ),
    );
  }
}
