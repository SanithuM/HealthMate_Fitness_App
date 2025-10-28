import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  // --- Singleton Setup ---
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // --- Database Initialization ---
  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fitness_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // --- OnCreate: Table Creation ---
  Future _onCreate(Database db, int version) async {
    // 1. Create the table with the correct name and column types
    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER,
        calories INTEGER,
        water INTEGER 
      )
    ''');
  }

  

  // --- CRUD OPERATIONS ---

  // C - Create (Insert)
  Future<int> insertRecord(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('health_records', row);
  }

  // R - Read (Query All)
  Future<List<Map<String, dynamic>>> queryAllRecords() async {
    Database db = await instance.database;
    return await db.query('health_records', orderBy: 'date DESC');
  }

  // R - Read (Query Single Record by ID)
  Future<Map<String, dynamic>?> queryRecord(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // U - Update
  Future<int> updateRecord(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update(
      'health_records',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // D - Delete
  Future<int> deleteRecord(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}