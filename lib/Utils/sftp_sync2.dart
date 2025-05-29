import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';

import '../Models/gamedata_model.dart';

class DownloadResult {
  final bool success;
  final String message;

  DownloadResult(this.success, this.message);
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

Future<DownloadResult> downloadJsonFile(Map<String, dynamic> connection) async {
  final protocol = connection['protocol'] ?? 'sftp';

  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/farmersDB.json');

    if (protocol == 'sftp') {
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
      client.close();

      await file.writeAsBytes(content);
      return DownloadResult(true, 'SFTP download successful.');
    } else if (protocol == 'ftp') {
      final ftpClient = FTPConnect(
        connection['host'],
        user: connection['username'],
        pass: connection['password'],
        port: connection['port'],
        timeout: 30,
      );

      await ftpClient.connect();
      final success = await ftpClient.downloadFile(connection['path'], file);
      await ftpClient.disconnect();

      if (success) {
        return DownloadResult(true, 'FTP download successful.');
      } else {
        return DownloadResult(false, 'FTP download failed.');
      }
    } else {
      return DownloadResult(false, 'Unsupported protocol: $protocol');
    }
  } catch (e) {
    return DownloadResult(false, 'Download error: $e');
  }
}
