import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:farmerdashboard/Models/gamedata_model.dart';

class DownloadResult {
  final bool success;
  final String message;

  DownloadResult(this.success, this.message);
}


Future<DownloadResult> downloadJsonFile(Map<String, dynamic> connection) async {
  try {
    final socket = await SSHSocket.connect(
      connection['host'],
      connection['port'],
    );

    final client = SSHClient(
      socket,
      username: connection['username'],
      onPasswordRequest: () => connection['password'],
    );

    final sftp = await client.sftp();

    final remoteFile = await sftp.open(connection['path']);
    final content = await remoteFile.readBytes();
    await remoteFile.close();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/farmersDB.json');
    await file.writeAsBytes(content);

    client.close();

    return DownloadResult(true, 'Download successful!');
  } catch (e) {
    print('❌ Error in downloadJsonFile: $e');
    return DownloadResult(false, 'Connection failed: $e');
  }
}




Future<GameData?> loadGameData() async {
  try {
    // Step 1: Get the application directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/farmersDB.json'; // Ensure this matches where the file is saved

    // Step 2: Create the File object
    final file = File(filePath);

    // Step 3: Check if the file exists
    if (!file.existsSync()) {
      print("File not found at $filePath");
      return null;
    }

    // Step 4: Read the file content
    final jsonString = await file.readAsString();

    // Step 5: Parse JSON and map to GameData
    final jsonData = jsonDecode(jsonString);
    final gameData = GameData.fromJson(jsonData);

    return gameData;
  } catch (e) {
    print("Error while loading GameData: $e");
    return null;
  }
}

