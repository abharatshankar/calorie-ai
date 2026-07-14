import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/environment_config.dart';
import 'features/offline/data/datasources/offline_database.dart';
import 'core/services/global_error_handler.dart';

void main() {
  GlobalErrorHandler.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await OfflineDatabase.initialize();
    GlobalErrorHandler.initialize();
    EnvironmentConfig.fromDartDefines().logStartupSelection();
    runApp(const ProviderScope(child: CalorieAiApp()));
  });
}
