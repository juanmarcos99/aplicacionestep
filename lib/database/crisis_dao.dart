import '../models/crisis.dart';
import 'db_helper.dart';

class CrisisDao {
  static Future<int> insertCrisis(Crisis crisis) async {
    final db = await DBHelper.initDb();
    return await db.insert("crisis", crisis.toMap());
  }

  static Future<List<Crisis>> getAllCrisis() async {
    final db = await DBHelper.initDb();
    final res = await db.query("crisis");
    return res.map((map) => Crisis.fromMap(map)).toList();
  }
static Future<bool> existeCrisis(DateTime fecha, String horario) async {
    final db = await DBHelper.initDb();

    // convierto la fecha a string (ejemplo: yyyy-MM-dd)
    final fechaStr = fecha.toIso8601String().split("T").first;

    final res = await db.query(
      'crisis_detalle',
      where: 'fechaCrisis = ? AND horario = ?',
      whereArgs: [fechaStr, horario],
      limit: 1,
    );

    // si hay al menos un registro, devuelve true
    return res.isNotEmpty;
  }
}

}
