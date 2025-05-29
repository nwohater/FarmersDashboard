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
        title: const Text('Select Server', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: _connections.length,
        itemBuilder: (context, index) {
          final conn = _connections[index];
          return ListTile(
            title: Text(
              conn['servername']?.toString().isNotEmpty == true
                  ? conn['servername']
                  : conn['host'],
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            subtitle: Text(
              '${conn['host']}:${conn['port']}',
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            onTap: () => _selectConnection(conn),
          );

        },
      ),
    );
  }
}
