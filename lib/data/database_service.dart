import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
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

      // Set the database factory for sqflite_common_ffi
      databaseFactory = databaseFactoryFfi;

      // Get the Documents directory of Windows user
      final documentsDir = Directory(
        '${Platform.environment['USERPROFILE']}\\Documents\\bms_app',
      );

      // Create directory if not exists
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
        print('DatabaseService: Created bms_app directory in Documents');
      }

      // Build full database path
      final dbPath = join(documentsDir.path, Constants.dbName);

      print('DatabaseService: Database path: $dbPath');

      final db = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 9,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onOpen: _onOpen,
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
            is_monthly_fee_synced INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (class_id) REFERENCES classes (id)
          )
        ''');
        print('DatabaseService: Students table created/verified');
      }

      if (oldVersion < 3) {
        print('DatabaseService: Creating admission_fees table for version 3');

        // Create admission_fees table
        await db.execute('''
          CREATE TABLE admission_fees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            amount_due REAL NOT NULL DEFAULT 0.00,
            amount_paid REAL NOT NULL DEFAULT 0.00,
            status TEXT NOT NULL DEFAULT 'Pending',
            due_date TEXT,
            payment_date TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
          )
        ''');
        print('DatabaseService: Admission fees table created');
      }

      if (oldVersion < 4) {
        print(
          'DatabaseService: Creating paid_admission_fees table for version 4',
        );

        // Create paid_admission_fees table for tracking individual payments
        await db.execute('''
          CREATE TABLE paid_admission_fees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            amount_paid REAL NOT NULL,
            payment_date TEXT NOT NULL,
            mode_of_payment TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
          )
        ''');
        print('DatabaseService: Paid admission fees table created');
      }

      if (oldVersion < 5) {
        print(
          'DatabaseService: Adding due_date and payment_date columns to admission_fees table for version 5',
        );

        // Add due_date and payment_date columns to admission_fees table
        await db.execute('ALTER TABLE admission_fees ADD COLUMN due_date TEXT');
        await db.execute(
          'ALTER TABLE admission_fees ADD COLUMN payment_date TEXT',
        );

        print(
          'DatabaseService: Added due_date and payment_date columns to admission_fees table',
        );
      }

      if (oldVersion < 6) {
        print('DatabaseService: Creating monthly_fees table for version 6');

        // Create monthly_fees table
        await db.execute('''
          CREATE TABLE monthly_fees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            month TEXT NOT NULL,
            amount REAL NOT NULL DEFAULT 0.00,
            paid_amount REAL NOT NULL DEFAULT 0.00,
            status TEXT NOT NULL DEFAULT 'Pending',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
          )
        ''');
        print('DatabaseService: Monthly fees table created');

        // Create monthly_payment_history table
        await db.execute('''
          CREATE TABLE monthly_payment_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            monthly_fee_id INTEGER NOT NULL,
            paid_amount REAL NOT NULL,
            payment_date TEXT NOT NULL,
            payment_mode TEXT NOT NULL,
            remarks TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (monthly_fee_id) REFERENCES monthly_fees (id) ON DELETE CASCADE
          )
        ''');
        print('DatabaseService: Monthly payment history table created');
      }

      if (oldVersion < 7) {
        print(
          'DatabaseService: Adding is_monthly_fee_synced column to students table for version 7',
        );

        // Add is_monthly_fee_synced column to students table
        await db.execute(
          'ALTER TABLE students ADD COLUMN is_monthly_fee_synced INTEGER NOT NULL DEFAULT 0',
        );

        print(
          'DatabaseService: Added is_monthly_fee_synced column to students table',
        );
      }

      if (oldVersion < 8) {
        print(
          'DatabaseService: Creating exam_fees_pending and exam_fees_paid tables for version 8',
        );

        // Create exam_fees_pending table
        await db.execute('''
          CREATE TABLE exam_fees_pending (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            class_id INTEGER NOT NULL,
            exam_name TEXT NOT NULL,
            exam_month TEXT NOT NULL,
            total_fee REAL NOT NULL DEFAULT 0.00,
            paid_amount REAL NOT NULL DEFAULT 0.00,
            status TEXT NOT NULL DEFAULT 'Pending',
            due_date TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
            FOREIGN KEY (class_id) REFERENCES classes (id) ON DELETE CASCADE
          )
        ''');

        // Create exam_fees_paid table
        await db.execute('''
          CREATE TABLE exam_fees_paid (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pending_exam_fee_id INTEGER,
            student_id INTEGER NOT NULL,
            class_id INTEGER NOT NULL,
            exam_name TEXT NOT NULL,
            paid_amount REAL NOT NULL,
            payment_date TEXT NOT NULL,
            payment_mode TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (pending_exam_fee_id) REFERENCES exam_fees_pending (id) ON DELETE CASCADE,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
            FOREIGN KEY (class_id) REFERENCES classes (id) ON DELETE CASCADE
          )
        ''');

        print(
          'DatabaseService: Created exam_fees_pending and exam_fees_paid tables',
        );
      }

      if (oldVersion < 9) {
        print(
          'DatabaseService: Creating misc_fees_pending and misc_fees_paid tables for version 9',
        );

        // Create misc_fees_pending table
        await db.execute('''
          CREATE TABLE misc_fees_pending (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            class_id INTEGER NOT NULL,
            misc_fee_type TEXT NOT NULL,
            month TEXT NOT NULL,
            total_fee REAL NOT NULL DEFAULT 0.00,
            paid_amount REAL NOT NULL DEFAULT 0.00,
            status TEXT NOT NULL DEFAULT 'Pending',
            due_date TEXT,
            description TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
            FOREIGN KEY (class_id) REFERENCES classes (id) ON DELETE CASCADE
          )
        ''');

        // Create misc_fees_paid table
        await db.execute('''
          CREATE TABLE misc_fees_paid (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pending_misc_fee_id INTEGER,
            student_id INTEGER NOT NULL,
            class_id INTEGER NOT NULL,
            misc_fee_type TEXT NOT NULL,
            paid_amount REAL NOT NULL,
            payment_date TEXT NOT NULL,
            payment_mode TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (pending_misc_fee_id) REFERENCES misc_fees_pending (id) ON DELETE CASCADE,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
            FOREIGN KEY (class_id) REFERENCES classes (id) ON DELETE CASCADE
          )
        ''');

        print(
          'DatabaseService: Created misc_fees_pending and misc_fees_paid tables',
        );
      }

      print('DatabaseService: Database upgrade completed');
    } catch (e, stackTrace) {
      print('DatabaseService: Error during database upgrade: $e');
      print('DatabaseService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> _onOpen(Database db) async {
    try {
      print('DatabaseService: Database opened, checking for missing tables...');

      // Check if admission_fees table exists, create if not
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='admission_fees'",
      );

      if (tables.isEmpty) {
        print('DatabaseService: Creating admission_fees table...');
        await db.execute('''
          CREATE TABLE admission_fees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            amount_due REAL NOT NULL DEFAULT 0.00,
            amount_paid REAL NOT NULL DEFAULT 0.00,
            status TEXT NOT NULL DEFAULT 'Pending',
            due_date TEXT,
            payment_date TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
          )
        ''');
        print('DatabaseService: Admission fees table created');
      }

      // Check if paid_admission_fees table exists, create if not
      final paidTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='paid_admission_fees'",
      );

      if (paidTables.isEmpty) {
        print('DatabaseService: Creating paid_admission_fees table...');
        await db.execute('''
          CREATE TABLE paid_admission_fees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            amount_paid REAL NOT NULL,
            payment_date TEXT NOT NULL,
            mode_of_payment TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
          )
        ''');
        print('DatabaseService: Paid admission fees table created');
      }

      // Check if monthly_fees table exists, create if not
      final monthlyTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='monthly_fees'",
      );

      if (monthlyTables.isEmpty) {
        print('DatabaseService: Creating monthly_fees table...');
        await db.execute('''
          CREATE TABLE monthly_fees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            month TEXT NOT NULL,
            amount REAL NOT NULL DEFAULT 0.00,
            paid_amount REAL NOT NULL DEFAULT 0.00,
            status TEXT NOT NULL DEFAULT 'Pending',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
          )
        ''');
        print('DatabaseService: Monthly fees table created');
      }

      // Check if monthly_payment_history table exists, create if not
      final monthlyPaymentTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='monthly_payment_history'",
      );

      if (monthlyPaymentTables.isEmpty) {
        print('DatabaseService: Creating monthly_payment_history table...');
        await db.execute('''
          CREATE TABLE monthly_payment_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            monthly_fee_id INTEGER NOT NULL,
            paid_amount REAL NOT NULL,
            payment_date TEXT NOT NULL,
            payment_mode TEXT NOT NULL,
            remarks TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (monthly_fee_id) REFERENCES monthly_fees (id) ON DELETE CASCADE
          )
        ''');
        print('DatabaseService: Monthly payment history table created');
      }

      // Check if misc_fees_pending table exists, create if not
      final miscPendingTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='misc_fees_pending'",
      );

      if (miscPendingTables.isEmpty) {
        print('DatabaseService: Creating misc_fees_pending table...');
        await db.execute('''
          CREATE TABLE misc_fees_pending (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id INTEGER NOT NULL,
            class_id INTEGER NOT NULL,
            misc_fee_type TEXT NOT NULL,
            month TEXT NOT NULL,
            total_fee REAL NOT NULL DEFAULT 0.00,
            paid_amount REAL NOT NULL DEFAULT 0.00,
            status TEXT NOT NULL DEFAULT 'Pending',
            due_date TEXT,
            description TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
            FOREIGN KEY (class_id) REFERENCES classes (id) ON DELETE CASCADE
          )
        ''');
        print('DatabaseService: Misc fees pending table created');
      }

      // Check if misc_fees_paid table exists, create if not
      final miscPaidTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='misc_fees_paid'",
      );

      if (miscPaidTables.isEmpty) {
        print('DatabaseService: Creating misc_fees_paid table...');
        await db.execute('''
          CREATE TABLE misc_fees_paid (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pending_misc_fee_id INTEGER,
            student_id INTEGER NOT NULL,
            class_id INTEGER NOT NULL,
            misc_fee_type TEXT NOT NULL,
            paid_amount REAL NOT NULL,
            payment_date TEXT NOT NULL,
            payment_mode TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (pending_misc_fee_id) REFERENCES misc_fees_pending (id) ON DELETE CASCADE,
            FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
            FOREIGN KEY (class_id) REFERENCES classes (id) ON DELETE CASCADE
          )
        ''');
        print('DatabaseService: Misc fees paid table created');
      }
    } catch (e, stackTrace) {
      print('DatabaseService: Error during database open: $e');
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
