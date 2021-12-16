import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String tableMessages = 'messages';

class MessageFields {
  static const String id = '_id';
  static const String message = 'message';
  static const String time = 'time';
}

class SampleDatabase {
  static const String _databaseFileName = 'sammple.db';
  static const int _databaseVersion = 1;
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase(_databaseFileName);
    return _database!;
  }

  Future<Database> _openDatabase(String fileName) async {
    final databasePath = await getDatabasesPath();
    final databaseFilePath = join(databasePath, fileName);

    return await openDatabase(
      databaseFilePath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE message $tableMessages (
  ${MessageFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${MessageFields.message} TEXT NOT NULL,
  ${MessageFields.time} TEXT NOT NULL
)
''');
  }
}
