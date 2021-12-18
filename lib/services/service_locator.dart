import 'package:get_it/get_it.dart';

import 'app_database_service.dart';
import 'app_database_service_impl.dart';
import '../view_models/message_viewmodel.dart';

GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  serviceLocator.registerLazySingleton<AppDatabaseService>(
    () => AppDatabaseServiceImpl(),
  );
  serviceLocator.registerLazySingleton<MessageViewModel>(
    () => MessageViewModel(),
  );
}
