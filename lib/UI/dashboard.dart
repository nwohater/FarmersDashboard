import 'package:farmerdashboard/models/server_config_model.dart';
import 'package:flutter/material.dart';
import 'package:farmerdashboard/Utils/sftp_sync.dart';
import 'package:farmerdashboard/Models/gamedata_model.dart';
import 'package:farmerdashboard/UI/Widgets/weather_widget.dart';
import 'package:farmerdashboard/UI/Widgets/date_widget.dart';

// Assuming offers_widget.dart contains SpecialOfferWidget
import '../Models/server_config_model.dart' hide ServerConfig;
import '../Utils/server_config_service.dart';
import 'Widgets/farm_widget.dart';
import 'Widgets/forecast_widget.dart';
import 'Widgets/offers_widget.dart'; // Or SpecialOfferWidget if that's the file name

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  GameData? _gameData;

  @override
  void initState() {
    super.initState();
    _checkConnections();
    _loadData();
  }

  Future<void> _checkConnections() async {
    // Somewhere in your app's startup logic (e.g., in your main widget's initState or a splash screen)
    final serverConfigService = ServerConfigService();
    ServerConfig? defaultConnection = await serverConfigService.loadDefaultConfig();

    if (defaultConnection != null) {
      print('Using default connection: ${defaultConnection.profileName}');
      // Proceed to use defaultConnection.host, defaultConnection.username, etc.
      // for your SFTP operations in sftp_sync.dart
    } else {
      print('No default connection set. Please configure one.');
      // Navigate to a settings screen to allow the user to add/select a default configuration.
    }
  }

  Future<void> _loadData() async {
    // Connect to sftp server and download
    await downloadJsonFile();

    // Load the game data.
    final gameData = await loadGameData();
    if (gameData != null) {
      setState(() {
        _gameData = gameData; // Update the `_gameData` in state.
      });
    } else {
      print("Failed to load GameData.");
      if (mounted) { // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load GameData.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if _gameData is null (still loading or failed)
    if (_gameData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Farmer's Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
          ),
          backgroundColor: Colors.green, // Added for consistency
        ),
        body: Center(
          child: CircularProgressIndicator(), // Show loading indicator
        ),
      );
    }

    // Get initial values to pass to widgets
    // Use null-aware operators and provide defaults where appropriate
    final String condition = _gameData!.weather.condition; // Assuming condition is non-null from model
    final double temperatureF = _gameData!.weather.temperatureF; // Assuming temp is non-null
    final String date = _gameData!.date.monthName.isNotEmpty
        ? '${_gameData!.date.monthName} ${_gameData!.date.day}'
        : 'Date N/A';

    // Filter the farms: only include those where farmName is not null AND not empty
    final List<Farm> validFarms = _gameData!.farms.where((farm) {
      return farm.name.trim().isNotEmpty;
    }).toList();

    final List<SpecialOffer> specialOffers = _gameData!.specialOffers;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/tractor1.png'),
        ),
        centerTitle: true,
        title: Text(
          "Farmer's Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
        ),
        backgroundColor: Colors.green,
      ),
      body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background2.png',
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(0.1),
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Date and Time Section
                          Column(
                            children: [
                              DateWidget(Date: date, Time: _gameData!.time),
                              Divider(height: 20, thickness: 1),
                            ],
                          ),

                          // Weather Section
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Current Weather",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[700],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              WeatherWidget(
                                condition: condition, // No longer needs ! if handled above
                                temperature: temperatureF, // No longer needs !
                              ),
                              Divider(height: 20, thickness: 1),
                            ],
                          ),
                          if (_gameData != null && _gameData!.weather.forecast.isNotEmpty) ...[
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Weather Forecast",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 10),
                            ForecastWidget(
                              currentWeatherData: _gameData!.weather,
                              forecastDynamicItems: _gameData!.weather.forecast, // Pass the List<dynamic>
                            ),
                            Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
                          ] else if (_gameData != null) ...[
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Current Weather",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 10),
                            ForecastWidget(
                              currentWeatherData: _gameData!.weather,
                              forecastDynamicItems: [], // Pass an empty list
                            ),
                            Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
                          ],
                          SizedBox(height: 5), // Spacing after weather

                          // Farm Report Section Title (with optional tractor icon)
                          Row( // Using a Row to place icon next to text
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/farmer1.png', // Make sure this path is correct
                                width: 40, // Adjust size as needed
                                height: 40, // Adjust size as needed
                              ),
                              SizedBox(width: 5),
                              Text(
                                "The Farm Report",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[700]),
                              ),
                            ],
                          ),
                          SizedBox(height: 5), // Spacing after title

                          // Loop through farms and create FarmWidget for each
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
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text('No farms to display.'),
                              ),
                            ),
                          ],
                          SizedBox(height: 5), // Spacing after farm reports

                          // Special Offers Section
                          Divider(height: 20, thickness: 1),
                          Row( // Using a Row to place icon next to text
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Forsale.png', // Make sure this path is correct
                                width: 50, // Adjust size as needed
                                height: 50, // Adjust size as needed
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Today\'s Special Offers',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[700]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(height: 10), // Spacing after title

                          if (specialOffers.isNotEmpty) ...[
                            ...specialOffers.map((offer) {
                              // Ensure SpecialOfferWidget is imported and available
                              return SpecialOfferWidget(offer: offer);
                            }).toList(),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(
                                child: Text(
                                  'No special offers available at the moment.',
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
            )
          ]),
    );
  }
}