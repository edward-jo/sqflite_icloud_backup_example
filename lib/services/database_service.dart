import 'package:sqflite_icloud_backup_example/models/message.dart';

abstract class DatabaseService {
  Future openDatabase();
  Future closeDatabase();
  Future<Message> createMessage(Message message);
  Future<int> deleteMesssage(int id);
  Future<Message> readMessage(int id);
  Future<List<Message>> readAllMessages();
  Future<int> updateMessage(Message message);
}
