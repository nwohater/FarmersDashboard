import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SftpDatabase {
  static final SftpDatabase _instance = SftpDatabase._internal();
  factory SftpDatabase() => _instance;

  static Database? _db;

  SftpDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;

    // Initialize the database
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sftp_connections.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sftp_connections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        servername TEXT NOT NULL,
        host TEXT NOT NULL,
        port INTEGER NOT NULL,
        path TEXT NOT NULL,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        isdefault INTEGER NOT NULL
      )
    ''');
  }

  // Example method to insert a connection record
  Future<void> insertConnection(Map<String, dynamic> connInfo) async {
    final db = await database;
    await db.insert(
      'sftp_connections',
      connInfo,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Example method to retrieve all connections
  Future<List<Map<String, dynamic>>> getConnections() async {
    final db = await database;
    return await db.query('sftp_connections');
  }

  Future<void> closeDb() async {
    final db = await database;
    await db.close();
    _db = null;
  }

  Future<Map<String, dynamic>?> getDefaultConnection() async {
    final db = await database;
    final res = await db.query(
      'sftp_connections',
      where: 'isdefault = ?',
      whereArgs: [1],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }


}

