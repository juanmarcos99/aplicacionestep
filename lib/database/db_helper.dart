import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // Inicializo la base de datos
  static Future<Database> initDb() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "epilepsia_app.db");

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabla de usuarios
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            passwordHash TEXT NOT NULL
          )
        ''');

        // Tabla de crisis
        await db.execute('''
          CREATE TABLE crisis (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha TEXT NOT NULL,
            horario TEXT NOT NULL,
            tipo TEXT NOT NULL,
            cantidad INTEGER,
            notas TEXT
          )
        ''');

        // Inserto usuarios iniciales
        await db.insert("users", {
          "username": "paciente",
          "passwordHash": "1234", // el hash lo hará UserDao
        });
        await db.insert("users", {
          "username": "doctor",
          "passwordHash": "5678",
        });
      },
    );
    return _db!;
  }
}
