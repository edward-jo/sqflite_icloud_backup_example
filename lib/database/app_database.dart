import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants.dart';

class AppDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openAppDatabase(appDatabaseFileName);
    return _database!;
  }

  Future<Database> _openAppDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    final databaseFilePath = join(databasePath, fileName);

    return await openDatabase(
      databaseFilePath,
      version: appDatabaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE $messagesTableName (
  ${MessagesDbCols.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${MessagesDbCols.message} TEXT NOT NULL,
  ${MessagesDbCols.createdTime} TEXT NOT NULL
)
''');
  }

  Future<void> deleteAppDatabase() async {
    final databasePath = await getDatabasesPath();
    final databaseFilePath = join(databasePath, appDatabaseFileName);

    await deleteDatabase(databaseFilePath);
    _database = null;
    return;
  }
}
