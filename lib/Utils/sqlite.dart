import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SftpDatabase {
  static final SftpDatabase _instance = SftpDatabase._internal();
  factory SftpDatabase() => _instance;

  static Database? _db;

  SftpDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sftp_connections.db');

    return await openDatabase(
      path,
      version: 3, // bumped for protocol column
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        isdefault INTEGER NOT NULL,
        protocol TEXT NOT NULL DEFAULT 'sftp'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      final columns =
      await db.rawQuery("PRAGMA table_info(sftp_connections);");

      final hasServername =
      columns.any((c) => c['name'] == 'servername');
      if (!hasServername) {
        await db.execute(
            "ALTER TABLE sftp_connections ADD COLUMN servername TEXT DEFAULT '';");
      }

      final hasProtocol = columns.any((c) => c['name'] == 'protocol');
      if (!hasProtocol) {
        await db.execute(
            "ALTER TABLE sftp_connections ADD COLUMN protocol TEXT DEFAULT 'sftp';");
      }
    }
  }

  Future<void> insertConnection(Map<String, dynamic> connInfo) async {
    final db = await database;
    await db.insert(
      'sftp_connections',
      connInfo,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getConnections() async {
    final db = await database;
    return await db.query('sftp_connections');
  }

  Future<void> deleteConnection(int id) async {
    final db = await database;
    await db.delete('sftp_connections', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDb() async {
    final db = await database;
    await db.close();
    _db = null;
  }

  Future<void> setAsDefault(int id) async {
    final db = await database;
    // Unset default for all connections
    await db.update(
      'sftp_connections',
      {'isdefault': 0},
    );
    // Set default for the specified connection
    await db.update(
      'sftp_connections',
      {'isdefault': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
