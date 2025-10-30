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
    // 1. Create the health_records table
    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        steps INTEGER,
        calories INTEGER,
        water INTEGER
      )
    ''');

    // 2. Create the users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        profile_photo TEXT
      )
    ''');
    // Dummy data insertion is commented out/removed as requested
  }

  // --- CRUD OPERATIONS for health_records ---

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

  // R - Read (Query Single Record by ID - Corrected)
  // Was mistakenly searching by date before
  Future<Map<String, dynamic>?> queryRecord(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'health_records',
      where: 'id = ?', // Corrected: Search by 'id'
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // --- ADDED THIS FUNCTION ---
  // R - Read (Query Single Record by DATE)
  Future<Map<String, dynamic>?> queryRecordByDate(String date) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'health_records',
      where: 'date = ?', // Search by the date column
      whereArgs: [date],
    );
    if (maps.isNotEmpty) {
      return maps.first; // Return the first record found
    }
    return null; // Return null if no record exists for that date
  }
  // -------------------------

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

  // ---------------------------------------------
  // --- CRUD OPERATIONS for users table ---
  // (These remain unchanged)
  // ---------------------------------------------

  // C - Create (Register a new user)
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('users', row);
  }

  // R - Read (Check if email already exists)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // R - Read (For Login)
  Future<Map<String, dynamic>?> getUserForLogin(String email, String password) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // U - Update (Update user profile info)
  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update(
      'users',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // D - Delete (Delete a user)
  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}