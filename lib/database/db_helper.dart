// lib/database/db_helper.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
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
        // Creo la tabla mínima: usuario + contraseña
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            passwordHash TEXT NOT NULL
          )
        ''');

        // Inserto usuarios iniciales: Paciente (1234) y Doctor (5678)
        await db.insert("users", {
          "username": "Paciente",
          "passwordHash": _hashPassword("1234"),
        });
        await db.insert("users", {
          "username": "Doctor",
          "passwordHash": _hashPassword("5678"),
        });
      },
    );
    return _db!;
  }

  // Hash de contraseña con SHA256
  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

   // Validar login
  static Future<bool> validateLogin(String username, String password) async {
    final db = await initDb();
    final hashed = _hashPassword(password);

    final res = await db.query(
      "users",
      where: "username = ? AND passwordHash = ?",
      whereArgs: [username.trim(), hashed],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  // Cambiar contraseña
  static Future<int> changePassword(String username, String newPassword) async {
    final db = await initDb();
    return await db.update(
      "users",
      {"passwordHash": _hashPassword(newPassword)},
      where: "username = ?",
      whereArgs: [username.trim()],
    );
  }
}
