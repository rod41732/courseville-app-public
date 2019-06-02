import 'package:mcv_app/src/bloc/application/settings_manager.dart';
import "package:path/path.dart";
import "dart:async";
import "package:sqflite/sqflite.dart";
class ApplicationDB {

  static ApplicationDB instance = ApplicationDB();
  Database db; 
  ApplicationDB() {
    open();
  }

  Future<Null> open() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, "user.db");
    db = await openDatabase(path, version: 3, onCreate: (Database db, int version) {
      db.execute("""
      CREATE TABLE data (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL 
      ) 
      """);
    });
  }

  Future<String> get(String key) async {
      await prepareDB();
      var rows = await db.query("data",
      where: "key = ?",
      whereArgs: [key]);
      if (rows.length == 0) return null;
      return rows[0]["value"];
  }

  Future<int> getInt(String key) async {
    try {
     return int.parse(await get(key));
    }
    catch (e) {
      return null;
    }
    
  }


  Future<void> set(String key, String val) async {
    await prepareDB();
    await db.insert("data", {"key": key, "value": val}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Null> prepareDB() async {
    if (db == null || !db.isOpen) await open();
  }

}