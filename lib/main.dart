import 'package:flutter/material.dart';
import 'package:farmerdashboard/UI/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import '/Utils/server_config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configService = ServerConfigService();
  await configService.migrateFromOldActiveConfig();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQueryData.copyWith(
          textScaler: TextScaler.linear(1.0),),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: GoogleFonts.amarante().fontFamily,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false,
        home: const DashBoard(), // Removed misplaced semicolon
      ),
    );
  }
}


