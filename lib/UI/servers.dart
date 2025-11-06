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
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Delete Connection',
          style: TextStyle(color: Colors.grey.shade200),
        ),
        content: Text(
          'Are you sure you want to delete this connection?',
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade900,
              foregroundColor: Colors.white,
            ),
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
          'Manage Servers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
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
      backgroundColor: const Color(0xFF0f0f1e),
      body: _connections.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dns_outlined,
                    size: 64,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No servers found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click the + button to add your first server',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _connections.length,
              itemBuilder: (context, index) {
                final conn = _connections[index];
                final serverName = conn['servername']?.toString().isNotEmpty == true
                    ? conn['servername']
                    : conn['host'];
                final isDefault = (conn['isdefault'] ?? 0) == 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1a1a2e),
                        const Color(0xFF16213e).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDefault
                          ? Colors.teal.shade700.withOpacity(0.5)
                          : Colors.teal.shade800.withOpacity(0.3),
                      width: isDefault ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade900.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.dns_outlined,
                            color: Colors.teal.shade300,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      serverName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade200,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade900.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.teal.shade700.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Text(
                                        'DEFAULT',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade300,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (conn['protocol'] ?? '').toString().toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.language,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      '${conn['host']}:${conn['port']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: Colors.teal.shade400),
                          onPressed: () {
                            _showAddEditDialog(existing: conn);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                          onPressed: () => _deleteConnection(conn['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.teal.shade700,
        child: const Icon(Icons.add, color: Colors.white),
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
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          title: Text(
            'Protocol Detected',
            style: TextStyle(color: Colors.grey.shade200),
          ),
          content: Text(
            'The host field contains a protocol prefix (${hostText.startsWith('sftp://') ? 'sftp://' : 'ftp://'}). '
            'This should be removed as the protocol is selected separately.\n\n'
            'Would you like to automatically remove it and continue?',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
              ),
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
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          title: Text(
            'Path Validation',
            style: TextStyle(color: Colors.grey.shade200),
          ),
          content: Text(
            'The path should end with "farmersDB.json".\n\n'
            'Current path: $pathText\n\n'
            'Would you like to automatically append "farmersDB.json" to the path?',
            style: TextStyle(color: Colors.grey.shade400),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade400)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
              ),
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
    final dialogWidth = screenWidth * 0.9;

    return Dialog(
      backgroundColor: const Color(0xFF1a1a2e),
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.teal.shade800.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade900.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.connection == null ? Icons.add : Icons.edit,
                      color: Colors.teal.shade300,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.connection == null ? 'Add Server' : 'Edit Server',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _servernameController,
                      style: TextStyle(color: Colors.grey.shade200),
                      decoration: InputDecoration(
                        labelText: 'Server Name',
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        helperText: 'Max 20 characters',
                        helperStyle: TextStyle(color: Colors.grey.shade600),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0f0f1e),
                      ),
                      maxLength: 20,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hostController,
                      style: TextStyle(color: Colors.grey.shade200),
                      decoration: InputDecoration(
                        labelText: 'Host',
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0f0f1e),
                      ),
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _portController,
                      style: TextStyle(color: Colors.grey.shade200),
                      decoration: InputDecoration(
                        labelText: 'Port',
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0f0f1e),
                      ),
                      keyboardType: TextInputType.number,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pathController,
                      style: TextStyle(color: Colors.grey.shade200),
                      decoration: InputDecoration(
                        labelText: 'Path To farmersDB.json',
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0f0f1e),
                      ),
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: Colors.grey.shade200),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0f0f1e),
                      ),
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      style: TextStyle(color: Colors.grey.shade200),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0f0f1e),
                      ),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _protocol,
                      style: TextStyle(color: Colors.grey.shade200),
                      dropdownColor: const Color(0xFF1a1a2e),
                      decoration: InputDecoration(
                        labelText: 'Protocol',
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0f0f1e),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'sftp', child: Text('SFTP')),
                        DropdownMenuItem(value: 'ftp', child: Text('FTP')),
                      ],
                      onChanged: (v) => setState(() => _protocol = v ?? 'sftp'),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0f0f1e),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade700),
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          'Set as Default Server',
                          style: TextStyle(color: Colors.grey.shade300),
                        ),
                        value: _isDefault,
                        activeColor: Colors.teal.shade600,
                        checkColor: Colors.white,
                        onChanged: (v) => setState(() => _isDefault = v ?? false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
