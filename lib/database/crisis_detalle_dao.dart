import '../models/crisis_detalle.dart';
import 'db_helper.dart';

class CrisisDetalleDao {
  static Future<int> insertDetalle(CrisisDetalle detalle) async {
    final db = await DBHelper.initDb();
    return await db.insert("crisis_horaria", detalle.toMap());
  }

  static Future<List<CrisisDetalle>> getDetallesByCrisis(int crisisId) async {
    final db = await DBHelper.initDb();
    final res = await db.query(
      "crisis_horaria",
      where: "crisis_id = ?",
      whereArgs: [crisisId],
    );
    return res.map((map) => CrisisDetalle.fromMap(map)).toList();
  }
}
