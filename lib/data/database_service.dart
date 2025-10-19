import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../core/utils/constants.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    try {
      print('DatabaseService: Initializing database...');
      // Initialize FFI
      sqfliteFfiInit();

      // Get database path
      final databaseFactory = databaseFactoryFfi;
      final dbPath = join(
        await databaseFactory.getDatabasesPath(),
        Constants.dbName,
      );

      print('DatabaseService: Database path: $dbPath');

      final db = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );

      print('DatabaseService: Database initialized successfully');
      return db;
    } catch (e, stackTrace) {
      print('DatabaseService: Error initializing database: $e');
      print('DatabaseService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    try {
      print('DatabaseService: Creating database tables...');

      // Create users table
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE NOT NULL,
          password_hash TEXT NOT NULL,
          role TEXT NOT NULL DEFAULT 'user',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      print('DatabaseService: Users table created');

      // Create classes table
      await db.execute('''
        CREATE TABLE classes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          class_name TEXT NOT NULL,
          section TEXT NOT NULL,
          total_students INTEGER DEFAULT 0
        )
      ''');
      print('DatabaseService: Classes table created');

      // Create students table
      await db.execute('''
        CREATE TABLE students (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          roll_no TEXT NOT NULL UNIQUE,
          gr_no TEXT NOT NULL UNIQUE,
          student_name TEXT NOT NULL,
          father_name TEXT NOT NULL,
          caste TEXT NOT NULL,
          place_of_birth TEXT NOT NULL,
          dob_figures TEXT NOT NULL,
          dob_words TEXT NOT NULL,
          gender TEXT NOT NULL,
          religion TEXT NOT NULL,
          father_contact TEXT NOT NULL,
          mother_contact TEXT NOT NULL,
          address TEXT NOT NULL,
          admission_date TEXT NOT NULL,
          class_id INTEGER,
          class_name TEXT NOT NULL,
          section TEXT NOT NULL,
          admission_fees REAL NOT NULL,
          monthly_fees REAL NOT NULL,
          status TEXT NOT NULL DEFAULT 'Active',
          FOREIGN KEY (class_id) REFERENCES classes (id)
        )
      ''');
      print('DatabaseService: Students table created');

      // Insert default admin user
      final passwordHash = _hashPassword('admin123');
      await db.insert('users', {
        'username': 'admin',
        'password_hash': passwordHash,
        'role': 'admin',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('DatabaseService: Default admin user inserted');
    } catch (e, stackTrace) {
      print('DatabaseService: Error creating database: $e');
      print('DatabaseService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      print(
        'DatabaseService: Upgrading database from version $oldVersion to $newVersion',
      );

      if (oldVersion < 2) {
        print('DatabaseService: Creating students table for version 2');

        // Create students table if it doesn't exist
        await db.execute('''
          CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            roll_no TEXT NOT NULL UNIQUE,
            gr_no TEXT NOT NULL UNIQUE,
            student_name TEXT NOT NULL,
            father_name TEXT NOT NULL,
            caste TEXT NOT NULL,
            place_of_birth TEXT NOT NULL,
            dob_figures TEXT NOT NULL,
            dob_words TEXT NOT NULL,
            gender TEXT NOT NULL,
            religion TEXT NOT NULL,
            father_contact TEXT NOT NULL,
            mother_contact TEXT NOT NULL,
            address TEXT NOT NULL,
            admission_date TEXT NOT NULL,
            class_id INTEGER,
            class_name TEXT NOT NULL,
            section TEXT NOT NULL,
            admission_fees REAL NOT NULL,
            monthly_fees REAL NOT NULL,
            status TEXT NOT NULL DEFAULT 'Active',
            FOREIGN KEY (class_id) REFERENCES classes (id)
          )
        ''');
        print('DatabaseService: Students table created/verified');
      }

      print('DatabaseService: Database upgrade completed');
    } catch (e, stackTrace) {
      print('DatabaseService: Error during database upgrade: $e');
      print('DatabaseService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static Future<bool> authenticateUser(String username, String password) async {
    final db = await database;
    final passwordHash = _hashPassword(password);

    final result = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, passwordHash],
    );

    return result.isNotEmpty;
  }

  static Future<Map<String, dynamic>?> getUserByUsername(
    String username,
  ) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
