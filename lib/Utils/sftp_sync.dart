import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:farmerdashboard/Models/gamedata_model.dart';

 Future<GameData?> downloadJsonFile() async {
   // Setup SSH client
   final socket = await SSHSocket.connect('viper.fragify.net', 2025);
   final client = SSHClient(
     socket,
     username: '5pdtfqox.53649089',
     onPasswordRequest: () => '73!Goats',
   );

   // Start SFTP session
   final sftp = await client.sftp();

   // Open remote file
   try {
     final remoteFile = await sftp.open(
         '/serverProfile/farmersDB.json');
     final content = await remoteFile.readBytes();
     await remoteFile.close();

     // Save it locally
     final dir = await getApplicationDocumentsDirectory();
     final file = File('${dir.path}/farmersDB.json');
     await file.writeAsBytes(content);

     // Parse JSON if needed
     //final jsonMap = jsonDecode(utf8.decode(content));

     // Clean up
     client.close();
   }
   catch(e) {
     print (e);
   }
   return null;
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

