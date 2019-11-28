import 'dart:async';
import 'dart:io';
import 'package:notodo_app/model/nodo_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

   // allow us to cache all of the states of the database helper
  factory DatabaseHelper() => _instance;

  static Database _db;

  /// table name
  final String tableName = "nodoTbl";

  /// table columns
  final String columnId = "id";
  final String columnItemName = "itemName";
  final String columnDateCreated = "dateCreated";

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();

    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "notodo_db.db");

    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  /*
      id | itemName | dataCreated
      ------------------------
      1  | cook  | 12/05/18
      2  | candy    | 14/06/16
    */

  // method to create table and columns
  void _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY,$columnItemName TEXT, $columnDateCreated TEXT)");
  }

  // CRUD - CREATE,READ,UPDATE,DELETE
  Future<int> saveItem(NoDoItem item) async {
    // creating an instance of db
    // and inserting data
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", item.toMap());
    return res;
  }

  // Get All Users
  Future<List> getItems() async{
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName ORDER BY $columnItemName ASC"); // Ascending order
    return result.toList();
  }

  // Count All Users in db
  Future<int> getCount() async{
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery(
            "SELECT COUNT(*) FROM $tableName"
        )
    );
  }

  // Get A Specific User
  Future<NoDoItem> getItem(int id) async{
    var dbClient = await db;
    var result  = await dbClient.rawQuery("SELECT * FROM $tableName WHERE $columnId = $id");
    if(result.length == 0) return null;
    return new NoDoItem.fromMap(result.first);
  }

  // Delete a user
  Future<int> deleteItem(int id) async{
    var dbClient = await db;
    return await dbClient.delete(tableName,where: "$columnId = ?",whereArgs: [id]);
  }

  // Update user
  Future<int> updateItem(NoDoItem item) async{
    var dbClient = await db;
    return await dbClient.update(tableName, item.toMap(),where: "$columnId = ?", whereArgs: [item.id]);
  }

  // close database
  Future close() async{
    var dbClient = await db;
    return dbClient.close();
  }

}
