import 'package:flutter/material.dart';
import 'package:farmerdashboard/UI/help_screen.dart';
import 'package:farmerdashboard/UI/servers.dart';
import 'package:farmerdashboard/UI/dashboard.dart';
import '../Utils/sqlite.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _hasServers = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final db = SftpDatabase();
    final connections = await db.getConnections();

    setState(() {
      _hasServers = connections.isNotEmpty;
      _isLoading = false;
    });

    // If no servers exist, show help screen first
    if (!_hasServers && mounted) {
      await _showHelpFirst();
    }
  }

  Future<void> _showHelpFirst() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HelpScreen(),
        fullscreenDialog: true,
      ),
    );

    // After help screen, check if servers were added
    final db = SftpDatabase();
    final connections = await db.getConnections();

    if (mounted) {
      if (connections.isEmpty) {
        // Still no servers, show server setup
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ServersSelectionScreen()),
        );
      } else {
        // Servers were added, go to dashboard
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashBoard()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If servers exist, go directly to dashboard
    if (_hasServers) {
      return const DashBoard();
    }

    // If no servers, show help screen
    return const HelpScreen();
  }
}
