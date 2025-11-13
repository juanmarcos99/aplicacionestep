import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DBHelper {
  static Database? _db;

  // 🔒 Función privada para hashear contraseñas con SHA256
  // Esto asegura que las contraseñas no se guarden en texto plano
  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // 📌 Inicializo la base de datos
  static Future<Database> initDb() async {
    // Si ya existe una instancia abierta, la reutilizo
    if (_db != null) return _db!;

    // Obtengo la ruta donde se guardan las bases de datos en el dispositivo
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "epilepsia_app.db");

    // Abro o creo la base de datos
    _db = await openDatabase(
      path,
      version: 1, //  versión inicial
      onCreate: (db, version) async {
        // ---------------- Tabla de usuarios ----------------
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            passwordHash TEXT NOT NULL
          )
        ''');

        // Inserto usuarios iniciales con contraseñas hasheadas
        await db.insert("users", {
          "username": "paciente",
          "passwordHash": _hashPassword("1234"),
        });
        await db.insert("users", {
          "username": "doctor",
          "passwordHash": _hashPassword("5678"),
        });

        // ---------------- Tabla de crisis ----------------
        await db.execute('''
          CREATE TABLE crisis (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha_crisis TEXT NOT NULL,     -- fecha seleccionada en el calendario
            fecha_registro TEXT NOT NULL    -- fecha en que se guardó el registro
          )
        ''');

        // ---------------- Tabla de crisis horaria ----------------
        await db.execute('''
          CREATE TABLE crisis_horaria (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            crisis_id INTEGER NOT NULL,     -- referencia al episodio principal
            horario TEXT NOT NULL,          -- franja horaria
            tipo TEXT NOT NULL,             -- tipo de crisis
            cantidad INTEGER NOT NULL,      -- número de crisis
            notas TEXT,                     -- opcional, para descripciones largas
            FOREIGN KEY (crisis_id) REFERENCES crisis(id) ON DELETE CASCADE
          )
        ''');
      },
    );

    return _db!;
  }
}
