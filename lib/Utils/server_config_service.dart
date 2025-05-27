
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For jsonEncode/Decode if not already imported
import '../models/server_config_model.dart'; // Adjust path as necessary

class ServerConfigService {
  static const String _allConfigsKey = 'all_server_configs';

  // Load all server configurations from SharedPreferences
  Future<List<ServerConfig>> getAllConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? configsJsonList = prefs.getStringList(_allConfigsKey);
    if (configsJsonList == null) {
      return []; // No configs saved yet
    }
    return configsJsonList.map((jsonString) => ServerConfig.fromJsonString(jsonString)).toList();
  }

  // Save all server configurations to SharedPreferences
  Future<void> _saveAllConfigs(List<ServerConfig> configs) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> configsJsonList = configs.map((config) => config.toJsonString()).toList();
    await prefs.setStringList(_allConfigsKey, configsJsonList);
  }

  // Add a new server configuration
  // If `isDefault` is true, it will ensure other configs are not default.
  Future<void> addConfig(ServerConfig newConfig) async {
    List<ServerConfig> configs = await getAllConfigs();

    // Ensure profileName is unique if you want that constraint
    // if (configs.any((c) => c.profileName == newConfig.profileName)) {
    //   throw Exception('A configuration with this profile name already exists.');
    // }

    if (newConfig.isDefault) {
      // If the new config is set as default, unset others
      for (int i = 0; i < configs.length; i++) {
        if (configs[i].isDefault) {
          configs[i] = configs[i].copyWith(isDefault: false);
        }
      }
    }
    configs.add(newConfig);
    await _saveAllConfigs(configs);
    print("Configuration added: ${newConfig.profileName}");
  }

  // Update an existing configuration (identified by its original profileName or a unique ID)
  // For simplicity, using profileName as ID here. Consider using a real unique ID if profile names can change.
  Future<void> updateConfig(String originalProfileName, ServerConfig updatedConfig) async {
    List<ServerConfig> configs = await getAllConfigs();
    int configIndex = configs.indexWhere((c) => c.profileName == originalProfileName);

    if (configIndex == -1) {
      throw Exception('Configuration with profile name "$originalProfileName" not found.');
    }

    if (updatedConfig.isDefault) {
      // If the updated config is set as default, unset others
      for (int i = 0; i < configs.length; i++) {
        if (configs[i].isDefault && i != configIndex) { // Don't unset itself if it's already the one being updated
          configs[i] = configs[i].copyWith(isDefault: false);
        }
      }
    }
    configs[configIndex] = updatedConfig;
    await _saveAllConfigs(configs);
    print("Configuration updated: ${updatedConfig.profileName}");
  }

  // Set a specific configuration as the default
  Future<void> setDefaultConfig(String profileNameToSetAsDefault) async {
    List<ServerConfig> configs = await getAllConfigs();
    bool found = false;
    for (int i = 0; i < configs.length; i++) {
      if (configs[i].profileName == profileNameToSetAsDefault) {
        configs[i] = configs[i].copyWith(isDefault: true);
        found = true;
      } else if (configs[i].isDefault) {
        // Unset any other config that was default
        configs[i] = configs[i].copyWith(isDefault: false);
      }
    }
    if (!found) {
      throw Exception('Configuration with profile name "$profileNameToSetAsDefault" not found to set as default.');
    }
    await _saveAllConfigs(configs);
    print('Configuration "$profileNameToSetAsDefault" set as default.');
  }


  // Load the default server configuration
  Future<ServerConfig?> loadDefaultConfig() async {
    final List<ServerConfig> configs = await getAllConfigs();
    try {
      return configs.firstWhere((config) => config.isDefault);
    } catch (e) {
      // No default config found, optionally return the first one or null
      if (configs.isNotEmpty) {
        // print("No default config found, returning the first available config.");
        // return configs.first; // Or handle as an error / prompt user
      }
      return null;
    }
  }

  // Remove a configuration
  Future<void> deleteConfig(String profileNameToDelete) async {
    List<ServerConfig> configs = await getAllConfigs();
    configs.removeWhere((config) => config.profileName == profileNameToDelete);
    await _saveAllConfigs(configs);
    print('Configuration "$profileNameToDelete" deleted.');
  }

  // For migration from the old single "active" config:
  Future<void> migrateFromOldActiveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final String? oldConfigString = prefs.getString('server_config_active'); // Your old key

    if (oldConfigString != null && oldConfigString.isNotEmpty) {
      try {
        ServerConfig oldConfig = ServerConfig.fromJsonString(oldConfigString);
        // Mark it as default since it was the only one
        oldConfig = oldConfig.copyWith(isDefault: true);

        List<ServerConfig> currentConfigs = await getAllConfigs();
        // Add only if a config with the same profile name doesn't already exist
        // or if you want to overwrite.
        if (!currentConfigs.any((c) => c.profileName == oldConfig.profileName)) {
          await addConfig(oldConfig); // This will handle setting it as default
          print("Migrated old active configuration to new system: ${oldConfig.profileName}");
        }
        // Remove the old key after successful migration
        await prefs.remove('server_config_active');
        print("Old active configuration key removed.");

      } catch (e) {
        print("Error migrating old server config: $e");
        // Optionally, delete the corrupted old config
        // await prefs.remove('server_config_active');
      }
    }
  }
}