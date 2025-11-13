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
}
