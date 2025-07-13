import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'haushaltsbuch.db');

    // Temporäre Lösung für die Entwicklung: Löscht die Datenbank bei jedem Start
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        includeInForecast INTEGER NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        defaultAccountId INTEGER,
        FOREIGN KEY (defaultAccountId) REFERENCES accounts(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        accountId INTEGER NOT NULL,
        categoryId INTEGER NOT NULL,
        type INTEGER NOT NULL DEFAULT 0,
        targetAccountId INTEGER,
        FOREIGN KEY (accountId) REFERENCES accounts(id),
        FOREIGN KEY (categoryId) REFERENCES categories(id),
        FOREIGN KEY (targetAccountId) REFERENCES accounts(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_templates(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        accountId INTEGER,
        categoryId INTEGER,
        FOREIGN KEY (accountId) REFERENCES accounts(id),
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE accounts ADD COLUMN balance REAL NOT NULL DEFAULT 0.0');
      await db.execute('ALTER TABLE accounts ADD COLUMN includeInForecast INTEGER NOT NULL DEFAULT 1');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE accounts ADD COLUMN isDefault INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE categories ADD COLUMN type INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE categories ADD COLUMN defaultAccountId INTEGER');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE transaction_templates(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          amount REAL NOT NULL,
          type INTEGER NOT NULL,
          accountId INTEGER,
          categoryId INTEGER,
          FOREIGN KEY (accountId) REFERENCES accounts(id),
          FOREIGN KEY (categoryId) REFERENCES categories(id)
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE transactions ADD COLUMN type INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE transactions ADD COLUMN targetAccountId INTEGER');
    }
  }
}
