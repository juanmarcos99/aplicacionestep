import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import 'db_helper.dart';

class UserDao {
  // 🔒 Hash de contraseña con SHA256
  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // ➕ Insertar un nuevo usuario
  static Future<int> insertUser(User user) async {
    final db = await DBHelper.initDb();
    return await db.insert("users", {
      "username": user.username.trim().toLowerCase(),
      "passwordHash": _hashPassword(user.passwordHash),
    });
  }

  // 🔑 Validar login
  static Future<bool> validateLogin(String username, String password) async {
    final db = await DBHelper.initDb();
    final hashed = _hashPassword(password);

    final res = await db.query(
      "users",
      where: "LOWER(username) = ? AND passwordHash = ?",
      whereArgs: [username.trim().toLowerCase(), hashed],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  // 🔄 Cambiar contraseña
  static Future<int> changePassword(String username, String newPassword) async {
    final db = await DBHelper.initDb();
    return await db.update(
      "users",
      {"passwordHash": _hashPassword(newPassword)},
      where: "LOWER(username) = ?",
      whereArgs: [username.trim().toLowerCase()],
    );
  }

  // 📋 Obtener usuario por nombre
  static Future<User?> getUserByUsername(String username) async {
    final db = await DBHelper.initDb();
    final res = await db.query(
      "users",
      where: "LOWER(username) = ?",
      whereArgs: [username.trim().toLowerCase()],
      limit: 1,
    );

    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }
}
