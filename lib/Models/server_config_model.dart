// lib/models/server_config.dart
import 'dart:convert';

class ServerConfig {
  String profileName;
  String host;
  String username;
  String password;
  String jsonFilePath;
  int port;
  bool isDefault; // <--- New flag

  ServerConfig({
    required this.profileName,
    required this.host,
    required this.username,
    required this.password,
    required this.jsonFilePath,
    this.port = 22, // Default to standard SFTP port
    this.isDefault = false, // Default to false
  });

  String toJsonString() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['profileName'] = profileName;
    data['host'] = host;
    data['username'] = username;
    data['password'] = password;
    data['jsonFilePath'] = jsonFilePath;
    data['port'] = port;
    data['isDefault'] = isDefault; // <--- Add to JSON
    return jsonEncode(data);
  }

  factory ServerConfig.fromJsonString(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
    return ServerConfig(
      profileName: data['profileName'] as String? ?? 'Default Profile',
      host: data['host'] as String? ?? '',
      username: data['username'] as String? ?? '',
      password: data['password'] as String? ?? '',
      jsonFilePath: data['jsonFilePath'] as String? ?? '/defaultPath/data.json',
      port: data['port'] as int? ?? 22,
      isDefault: data['isDefault'] as bool? ?? false, // <--- Read from JSON, default to false
    );
  }

  ServerConfig copyWith({
    String? profileName,
    String? host,
    String? username,
    String? password,
    String? jsonFilePath,
    int? port,
    bool? isDefault, // <--- Add to copyWith
  }) {
    return ServerConfig(
      profileName: profileName ?? this.profileName,
      host: host ?? this.host,
      username: username ?? this.username,
      password: password ?? this.password,
      jsonFilePath: jsonFilePath ?? this.jsonFilePath,
      port: port ?? this.port,
      isDefault: isDefault ?? this.isDefault, // <--- Handle in copyWith
    );
  }

  @override
  String toString() {
    return 'ServerConfig(profileName: $profileName, host: $host, port: $port, user: $username, path: $jsonFilePath, isDefault: $isDefault)';
  }
}