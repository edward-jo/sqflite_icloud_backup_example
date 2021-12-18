import 'package:sqflite_icloud_backup_example/database/app_database.dart';
import 'package:sqflite_icloud_backup_example/models/message.dart';
import 'app_database_service.dart';
import '../constants.dart';

final AppDatabase _appDb = AppDatabase();

class AppDatabaseServiceImpl extends AppDatabaseService {
  @override
  Future openAppDatabase() {
    // TODO: implement openDatabase
    throw UnimplementedError();
  }

  @override
  Future closeAppDatabase() async {
    final db = await _appDb.database;
    db.close();
  }

  @override
  Future deleteAppDatabase() async {
    await _appDb.deleteAppDatabase();
  }

  @override
  Future<Message> createMessage(Message message) async {
    final db = await _appDb.database;
    Map<String, dynamic> messageJson = message.toJson();
    final id = await db.insert(messagesTableName, messageJson);
    messageJson[MessagesDbCols.id] = id;

    return Message.fromJson(messageJson);
  }

  @override
  Future<int> deleteMesssage(int id) async {
    final db = await _appDb.database;

    return await db.delete(
      messagesTableName,
      where: '${MessagesDbCols.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Message> readMessage(int id) async {
    final db = await _appDb.database;
    final messages = await db.query(
      messagesTableName,
      columns: [
        MessagesDbCols.id,
        MessagesDbCols.message,
        MessagesDbCols.createdTime,
      ],
      where: '${MessagesDbCols.id} = ?',
      whereArgs: [id],
    );

    if (messages.isEmpty) throw Exception('Failed to find id( $id )');

    return Message.fromJson(messages.first);
  }

  @override
  Future<List<Message>> readAllMessages() async {
    final db = await _appDb.database;
    final messages = await db.query(
      messagesTableName,
      orderBy: '${MessagesDbCols.createdTime} ASC',
    );

    return messages.map((e) {
      return Message.fromJson(e);
    }).toList();
  }

  @override
  Future<int> updateMessage(Message message) async {
    final db = await _appDb.database;

    return await db.update(
      messagesTableName,
      message.toJson(),
      where: '${MessagesDbCols.id} = ?',
      whereArgs: [message.id],
    );
  }
}
