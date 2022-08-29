import 'package:photo_tracker/classes/cacheCleaner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBManager {
  static final _databaseName = "tracker.db";
  static final _dbVersion = 1;

  Future<Database> _startDB() async {
    final Future<Database> database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE IF NOT EXISTS userInfo ("
            "Id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "userName TEXT,"
            "userEmail TEXT,"
            "userID TEXT,"
            "profileImageLocation TEXT"
            ")");
      },

      version: _dbVersion,
    );

    Database finalDB = await database;
    _test(finalDB);
    return finalDB;
  }

  createDB() async {
    await _startDB();
  }

  /// Fase 2 ############

  updateUserTable() async {
    Database db = await _startDB();

    db.rawQuery('UPDATE userInfo SET ');
  }

  insertIntoUserInfo(String? userName, String? email, String? imgPath, String userID) async {
    Database db = await _startDB();

    Map<String, dynamic> _newUser = {
      "userName": userName,
      "userEmail": email,
      "profileImageLocation": imgPath,
      "userID": userID,
    };

    await db.insert('userInfo', _newUser,
        conflictAlgorithm: ConflictAlgorithm.replace);

    return true;
  }

  readUserInfo() async {
    Database db = await _startDB();

    List<Map> result = await db.rawQuery('SELECT * FROM userInfo');

    return result;
  }

  _test(Database db) async {
    /*await db.execute("ALTER TABLE userInfo ADD COLUMN userID INTEGER DEFAULT 0");
    await db.execute("CREATE TABLE IF NOT EXISTS userInfo ("
        "Id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "userName TEXT,"
        "userEmail TEXT,"
        "profileImageLocation TEXT"
        ")");*/
  }
}
