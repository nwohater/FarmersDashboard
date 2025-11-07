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
  bool _isInitialized = false;
  bool _hasServers = false;

  @override
  void initState() {
    super.initState();
    // Wait for first frame to be rendered before checking state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialState();
    });
  }

  Future<void> _checkInitialState() async {
    final db = SftpDatabase();
    final connections = await db.getConnections();

    _hasServers = connections.isNotEmpty;

    if (!_hasServers && mounted) {
      // No servers - show help screen first
      await _showHelpFirst();
    } else if (mounted) {
      // Has servers - navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashBoard()),
      );
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
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
    // Show a simple loading screen
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
