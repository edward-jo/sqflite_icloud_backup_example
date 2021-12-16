import 'package:sqflite_icloud_backup_example/database/sample_database.dart';
import 'package:sqflite_icloud_backup_example/models/message.dart';
import 'package:sqflite_icloud_backup_example/services/database_service.dart';

final SampleDatabase _sampleDb = SampleDatabase();

class DatabaseServiceImpl extends DatabaseService {
  @override
  Future openDatabase() {
    // TODO: implement openDatabase
    throw UnimplementedError();
  }

  @override
  Future closeDatabase() async {
    final db = await _sampleDb.database;
    db.close();
  }

  @override
  Future<Message> createMessage(Message message) async {
    final db = await _sampleDb.database;
    Map<String, dynamic> messageJson = message.toJson();
    final id = await db.insert(tableMessages, messageJson);
    messageJson[MessageFields.id] = id;

    return Message.fromJson(messageJson);
  }

  @override
  Future<int> deleteMesssage(int id) async {
    final db = await _sampleDb.database;

    return db.delete(
      tableMessages,
      where: '${MessageFields.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Message> readMessage(int id) async {
    final db = await _sampleDb.database;
    final messages = await db.query(
      tableMessages,
      columns: [
        MessageFields.id,
        MessageFields.message,
        MessageFields.time,
      ],
      where: '${MessageFields.id} = ?',
      whereArgs: [id],
    );

    if (messages.isEmpty) throw Exception('Failed to find id( $id )');

    return Message.fromJson(messages.first);
  }

  @override
  Future<List<Message>> readAllMessages() async {
    final db = await _sampleDb.database;
    final messages = await db.query(
      tableMessages,
      orderBy: '${MessageFields.time} ASC',
    );

    return messages.map((e) {
      return Message.fromJson(e);
    }).toList();
  }

  @override
  Future<int> updateMessage(Message message) async {
    final db = await _sampleDb.database;

    return db.update(
      tableMessages,
      message.toJson(),
      where: '${MessageFields.id} = ?',
      whereArgs: [message.id],
    );
  }
}
