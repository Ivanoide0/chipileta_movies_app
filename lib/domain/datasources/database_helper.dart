import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chipileta_movies.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _createDB(Database  db, int version) async {
    await db.execute('''
      CREATE TABLE roles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rol TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT,
        telefono TEXT NOT NULL,
        acepto_terminos INTEGER NOT NULL,
        rol_id INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        google_id TEXT,
        foto_perfil TEXT,
        FOREIGN KEY (rol_id) REFERENCES roles(id)
      )
    ''');

    await _createOpinionsTable(db);
    await _createNotificationsTable(db);

    await db.insert('roles', {'rol': 'admin'});
    await db.insert('roles', {'rol': 'usuario'});
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if(oldVersion < 2){
      await _createOpinionsTable(db);
    }
    if(oldVersion < 3){
      await db.execute('PRAGMA foreign_keys = OFF');
      await _migrateUsersForGoogle(db);
      await db.execute('PRAGMA foreign_keys = ON');
    }
    if(oldVersion < 4){
      await _createNotificationsTable(db);
    }
    if(oldVersion < 5){
      await db.execute('ALTER TABLE users ADD COLUMN foto_perfil TEXT');
    }
  }

  Future _createOpinionsTable(Database db) async{
    await db.execute('''
      CREATE TABLE opinions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        rating REAL NOT NULL,
        comment TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future _migrateUsersForGoogle(Database db) async{
    await db.transaction((txn) async{
      await txn.execute('ALTER TABLE users ADD COLUMN google_id TEXT');

      await txn.execute('''
        CREATE TABLE users_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          apellido TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT,
          telefono TEXT NOT NULL,
          acepto_terminos INTEGER NOT NULL,
          rol_id INTEGER NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          google_id TEXT,
          FOREIGN KEY (rol_id) REFERENCES roles(id)
        )
      ''');

      await txn.execute('''
        INSERT INTO users_new(
          id, nombre, apellido, email, password, telefono, acepto_terminos, rol_id,
          is_active, created_at, google_id
        )
        SELECT 
          id, nombre, apellido, email, password, telefono, acepto_terminos, rol_id,
          is_active, created_at, google_id
        FROM users
      ''');

      await txn.execute('DROP TABLE users');
      await txn.execute('ALTER TABLE users_new RENAME TO users');
    });
  }

  Future _createNotificationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id INTEGER NOT NULL,
        movie_title TEXT NOT NULL,
        movie_poster TEXT NOT NULL,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}