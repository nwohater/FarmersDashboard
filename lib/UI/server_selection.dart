import 'package:flutter/material.dart';
import '../Utils/sqlite.dart';

class ServerPickerScreen extends StatefulWidget {
  const ServerPickerScreen({Key? key}) : super(key: key);

  @override
  State<ServerPickerScreen> createState() => _ServerPickerScreenState();
}

class _ServerPickerScreenState extends State<ServerPickerScreen> {
  List<Map<String, dynamic>> _connections = [];

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    final db = SftpDatabase();
    final connections = await db.getConnections();
    setState(() {
      _connections = connections;
    });
  }

  void _selectConnection(Map<String, dynamic> connection) {
    Navigator.of(context).pop(connection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Server'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: _connections.length,
        itemBuilder: (context, index) {
          final conn = _connections[index];
          return ListTile(
            title: Text(conn['servername']?.toString().isNotEmpty == true
                ? conn['servername']
                : conn['host']),
            subtitle: Text('${conn['username']}@${conn['host']}:${conn['port']}'),
            onTap: () => _selectConnection(conn),
          );
        },
      ),
    );
  }
}
