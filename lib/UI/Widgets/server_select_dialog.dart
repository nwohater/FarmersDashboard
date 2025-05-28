import 'package:flutter/material.dart';

class AddEditConnectionDialog extends StatefulWidget {
  final Map<String, dynamic>? connection;

  const AddEditConnectionDialog({Key? key, this.connection}) : super(key: key);

  @override
  _AddEditConnectionDialogState createState() => _AddEditConnectionDialogState();
}

class _AddEditConnectionDialogState extends State<AddEditConnectionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _pathController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: widget.connection?['host'] ?? '');
    _portController = TextEditingController(text: widget.connection?['port']?.toString() ?? '22');
    _pathController = TextEditingController(text: widget.connection?['path'] ?? '/');
    _usernameController = TextEditingController(text: widget.connection?['username'] ?? '');
    _passwordController = TextEditingController(text: widget.connection?['password'] ?? '');
    _isDefault = (widget.connection?['isdefault'] ?? 0) == 1;
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _pathController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final conn = {
        'id': widget.connection?['id'],
        'host': _hostController.text.trim(),
        'port': int.tryParse(_portController.text.trim()) ?? 22,
        'path': _pathController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        'isdefault': _isDefault ? 1 : 0,
      };

      Navigator.of(context).pop(conn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.connection == null ? 'Add Connection' : 'Edit Connection'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(labelText: 'Host'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _pathController,
                decoration: const InputDecoration(labelText: 'Path'),
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
              CheckboxListTile(
                title: const Text('Default'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
