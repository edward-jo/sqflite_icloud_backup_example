import 'dart:developer' as developer;
import 'package:sqflite_icloud_backup_example/services/app_database_service.dart';
import '../models/message.dart';
import '../services/app_database_service.dart';
import '../services/service_locator.dart';

class MessageViewModel {
  final AppDatabaseService _dbService = serviceLocator<AppDatabaseService>();
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  Future<bool> save(Message message) async {
    Message msg = await _dbService.createMessage(message);
    _messages.add(msg);
    return true;
  }

  Future<bool> readAll() async {
    List<Message> all = await _dbService.readAllMessages();
    for (Message msg in all) {
      developer.log(msg.toJson().toString());
    }
    _messages = all;
    return true;
  }
}
