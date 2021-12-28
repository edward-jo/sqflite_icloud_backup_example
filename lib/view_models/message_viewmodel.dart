import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/message.dart';
import '../services/icloud_storage/icloud_storage_service.dart';
import '../services/app_database/app_database_service.dart';
import '../services/service_locator.dart';

class MessageViewModel extends ChangeNotifier {
  final AppDatabaseService _dbService = serviceLocator<AppDatabaseService>();
  final IcloudStorageService _iStorageService =
      serviceLocator<IcloudStorageService>();
  List<Message> _messages = [];

  List<Message> get messages => _messages;

  Future<bool> save(Message message) async {
    Message msg = await _dbService.createMessage(message);
    _messages.add(msg);
    notifyListeners();
    return true;
  }

  Future<bool> readAll() async {
    List<Message> all = await _dbService.readAllMessages();
    for (Message msg in all) {
      developer.log(msg.toJson().toString());
    }
    _messages = all;
    notifyListeners();
    return true;
  }

  Future<void> uploadMessages(
    void Function(Stream<double>) onProgress,
  ) async {
    final path = await _dbService.getAppDatabaseFilePath();
    await _iStorageService.uploadFile(
      path,
      appDatabaseBackupFileName,
      onProgress,
    );
  }

  Future<void> downloadMessages(
    void Function(Stream<double>) onProgress,
  ) async {
    final path = await _dbService.getAppDatabaseFilePath();

    await _dbService.closeAppDatabase();
    await _dbService.deleteAppDatabase();

    await _iStorageService.downloadFile(
      appDatabaseBackupFileName,
      path,
      onProgress,
    );

    _messages.clear();
    notifyListeners();
  }

  Future<void> deleteMessages() async {
    await _dbService.closeAppDatabase();
    await _dbService.deleteAppDatabase();
    _messages.clear();
    notifyListeners();
  }

  Future<void> reloadMessages() async {
    await _dbService.init();
    await readAll();
  }
}
