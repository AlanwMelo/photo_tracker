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
        await db.execute("CREATE TABLE IF NOT EXISTS mainList ("
            "ID INTEGER PRIMARY KEY AUTOINCREMENT,"
            "mainListName TEXT,"
            "created INTEGER"
            ")");
        await db.execute("CREATE TABLE IF NOT EXISTS imageItem ("
            "ID INTEGER PRIMARY KEY AUTOINCREMENT,"
            "mainListName TEXT,"
            "imgPath TEXT,"
            "latitude TEXT,"
            "longitude TEXT,"
            "timestamp TEXT,"
            "locationError TEXT,"
            "timeError TEXT"
            ")");

        await db.execute("CREATE TABLE IF NOT EXISTS userInfo ("
            "Id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "userName TEXT,"
            "userEmail TEXT,"
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

  createNewList(String listName, String created) async {
    Database db = await _startDB();

    Map<String, dynamic> _newList = {
      "mainListName": listName,
      "created": created,
    };

    await db.insert('mainList', _newList,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  createNewImageItem(
      String mainListName,
      String imgPath,
      double latitude,
      double longitude,
      double timestamp,
      bool locationError,
      bool timeError) async {
    Database db = await _startDB();

    Map<String, dynamic> _newItem = {
      "mainListName": mainListName,
      "imgPath": imgPath,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "timestamp": timestamp.toString(),
      "locationError": locationError.toString(),
      "timeError": timeError.toString(),
    };

    await db.insert('imageItem', _newItem,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  deleteList(String listName) async {
    Database db = await _startDB();

    await db
        .rawQuery('DELETE FROM mainList WHERE mainListName=?', ['$listName']);
    await db
        .rawQuery('DELETE FROM imageItem WHERE mainListName=?', ['$listName']);

    CacheCleaner().cleanUnusedImgs();
  }

  deleteImageItem(String imgPath) async {
    Database db = await _startDB();

    await db.rawQuery('DELETE FROM imageItem WHERE imgPath=?', ['$imgPath']);

    CacheCleaner().cleanUnusedImgs();
  }

  getMainListItems() async {
    Database db = await _startDB();

    List<Map> result = await db.rawQuery('SELECT * FROM mainList');

    return result;
  }

  getFirstItemOfList(String listName) async {
    Database db = await _startDB();

    List<Map> result = await db.rawQuery(
        'SELECT * FROM imageItem WHERE mainListName=? ORDER BY timestamp ASC LIMIT 1',
        [listName]);

    return result;
  }

  getListItemCount(String listName) async {
    Database db = await _startDB();
    int resultCount = 0;

    List<Map> result = await db.rawQuery(
        'SELECT COUNT(*) FROM imageItem WHERE mainListName=?', [listName]);

    for (var element in result) {
      resultCount = element['COUNT(*)'];
    }

    return resultCount;
  }

  getListItems(String listName) async {
    Database db = await _startDB();

    List<Map> result = await db
        .rawQuery('SELECT * FROM imageItem WHERE mainListName=?', [listName]);

    return result;
  }

  getListItem(String listName) async {
    Database db = await _startDB();

    List<Map> result = await db
        .rawQuery('SELECT * FROM mainList WHERE mainListName=?', [listName]);

    return result;
  }

  getOrphanFileNames() async {
    Database db = await _startDB();

    List<Map> result = await db.rawQuery(
        'SELECT imgPath,mainListName FROM imageItem WHERE mainListName NOT IN (SELECT mainListName FROM mainList)');

    return result;
  }

  /// Fase 2 ############

  updateUserTable() async {
    Database db = await _startDB();

    db.rawQuery('UPDATE userInfo SET ');
  }

  insertIntoUserInfo(String? userName, String? email, String? imgPath) async {
    Database db = await _startDB();
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> _newUser = {
      "userName": userName,
      "userEmail": email,
      "profileImageLocation": imgPath,
    };

    await db.insert('userInfo', _newUser,
        conflictAlgorithm: ConflictAlgorithm.replace);

    prefs.setString('name', userName!);
    prefs.setString('email', email!);
    prefs.setString('imgPath', imgPath!);

    return true;
  }

  readUserInfo() async {
    Database db = await _startDB();

    List<Map> result = await db.rawQuery('SELECT * FROM userInfo');

    return result;
  }

  _test(Database db) async {
    await db.execute("CREATE TABLE IF NOT EXISTS userInfo ("
        "Id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "userName TEXT,"
        "userEmail TEXT,"
        "profileImageLocation TEXT"
        ")");
  }
}
