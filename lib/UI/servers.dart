import 'package:flutter/material.dart';
import '/Utils/sqlite.dart';
import 'dashboard.dart';

class ServersSelectionScreen extends StatefulWidget {
  const ServersSelectionScreen({Key? key}) : super(key: key);

  @override
  _ServersSelectionScreenState createState() => _ServersSelectionScreenState();
}

class _ServersSelectionScreenState extends State<ServersSelectionScreen> {
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

  void _showAddEditDialog({Map<String, dynamic>? existing}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddEditConnectionDialog(connection: existing),
    );

    if (result != null) {
      final db = SftpDatabase();
      await db.insertConnection(result);
      _loadConnections();
    }
  }

  Future<void> _deleteConnection(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Connection'),
            content: const Text(
              'Are you sure you want to delete this connection?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final db = SftpDatabase();
      await db.deleteConnection(id);
      _loadConnections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Servers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            // Check if there are servers to determine where to go
            final db = SftpDatabase();
            final connections = await db.getConnections();

            if (connections.isNotEmpty) {
              // If servers exist, go to dashboard
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashBoard()),
                );
              }
            } else {
              // If no servers, just go back (to help screen)
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body:
          _connections.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No servers found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click the + button to add your first server',
                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
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
                      '${(conn['protocol'] ?? '').toString().toUpperCase()} | ${conn['host']}:${conn['port']}',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.teal),
                          onPressed: () {
                            _showAddEditDialog(existing: conn);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteConnection(conn['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEditConnectionDialog extends StatefulWidget {
  final Map<String, dynamic>? connection;

  const AddEditConnectionDialog({Key? key, this.connection}) : super(key: key);

  @override
  _AddEditConnectionDialogState createState() =>
      _AddEditConnectionDialogState();
}

class _AddEditConnectionDialogState extends State<AddEditConnectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _servernameController;
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _pathController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isDefault = false;
  String _protocol = 'sftp'; // default

  @override
  void initState() {
    super.initState();
    _servernameController = TextEditingController(
      text: widget.connection?['servername'] ?? '',
    );
    _hostController = TextEditingController(
      text: widget.connection?['host'] ?? '',
    );
    _portController = TextEditingController(
      text: widget.connection?['port']?.toString() ?? '2025',
    );
    _pathController = TextEditingController(
      text: widget.connection?['path'] ?? '/serverProfile/farmersDB.json',
    );
    _usernameController = TextEditingController(
      text: widget.connection?['username'] ?? '',
    );
    _passwordController = TextEditingController(
      text: widget.connection?['password'] ?? '',
    );
    _isDefault = (widget.connection?['isdefault'] ?? 0) == 1;
    _protocol = widget.connection?['protocol'] ?? 'sftp';
  }

  @override
  void dispose() {
    _servernameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _pathController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_servernameController.text.trim().isEmpty ||
        _hostController.text.trim().isEmpty ||
        _portController.text.trim().isEmpty ||
        _pathController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields before saving.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Check if host contains protocol prefix
    final hostText = _hostController.text.trim();
    if (hostText.startsWith('sftp://') || hostText.startsWith('ftp://')) {
      final cleanHost = hostText.replaceAll(RegExp(r'^(sftp|ftp)://'), '');
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Protocol Detected'),
              content: Text(
                'The host field contains a protocol prefix (${hostText.startsWith('sftp://') ? 'sftp://' : 'ftp://'}). '
                'This should be removed as the protocol is selected separately.\n\n'
                'Would you like to automatically remove it and continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Remove & Continue'),
                ),
              ],
            ),
      );

      if (shouldContinue == true) {
        setState(() {
          _hostController.text = cleanHost;
        });
      } else {
        return;
      }
    }

    // Check if path ends with farmersDB.json
    final pathText = _pathController.text.trim();
    if (!pathText.endsWith('farmersDB.json')) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Path Validation'),
              content: Text(
                'The path should end with "farmersDB.json".\n\n'
                'Current path: $pathText\n\n'
                'Would you like to automatically append "farmersDB.json" to the path?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Append & Continue'),
                ),
              ],
            ),
      );

      if (shouldContinue == true) {
        // Clean up the path to ensure proper formatting
        String cleanPath = pathText;

        // Remove trailing slash if present
        if (cleanPath.endsWith('/')) {
          cleanPath = cleanPath.substring(0, cleanPath.length - 1);
        }

        // Ensure path starts with /
        if (!cleanPath.startsWith('/')) {
          cleanPath = '/$cleanPath';
        }

        setState(() {
          _pathController.text = '$cleanPath/farmersDB.json';
        });
      } else {
        return;
      }
    }

    final conn = {
      'id': widget.connection?['id'],
      'servername': _servernameController.text.trim(),
      'host': _hostController.text.trim(),
      'port': int.tryParse(_portController.text.trim()) ?? 2025,
      'path': _pathController.text.trim(),
      'username': _usernameController.text.trim(),
      'password': _passwordController.text.trim(),
      'isdefault': _isDefault ? 1 : 0,
      'protocol': _protocol,
    };

    final db = SftpDatabase();

    if (_isDefault) {
      await db.setAsDefault(widget.connection?['id'] ?? 0);
    }

    Navigator.of(context).pop(conn);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.9; // for example: 90% of screen width

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      // optional: padding around the dialog
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.connection == null
                    ? 'Add Connection'
                    : 'Edit Connection',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _servernameController,
                      decoration: const InputDecoration(
                        labelText: 'Server Name',
                        helperText: 'Max 20 characters',
                      ),
                      maxLength: 20,
                      buildCounter:
                          (
                            context, {
                            required currentLength,
                            required isFocused,
                            maxLength,
                          }) => null,
                    ),
                    TextFormField(
                      controller: _hostController,
                      decoration: const InputDecoration(labelText: 'Host'),
                    ),
                    TextFormField(
                      controller: _portController,
                      decoration: const InputDecoration(labelText: 'Port'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _pathController,
                      decoration: const InputDecoration(
                        labelText: 'Path To farmersDB.json',
                      ),
                    ),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    DropdownButtonFormField<String>(
                      value: _protocol,
                      decoration: const InputDecoration(labelText: 'Protocol'),
                      items: const [
                        DropdownMenuItem(value: 'sftp', child: Text('SFTP')),
                        DropdownMenuItem(value: 'ftp', child: Text('FTP')),
                      ],
                      onChanged: (v) => setState(() => _protocol = v ?? 'sftp'),
                    ),
                    CheckboxListTile(
                      title: const Text('Default'),
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v ?? false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _save, child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
