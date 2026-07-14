import 'package:hive_flutter/hive_flutter.dart';

import '../models/cached_dashboard_model.dart';
import '../models/cached_meal_history_item_model.dart';
import '../models/queued_upload_model.dart';

class OfflineDatabase {
  OfflineDatabase._();

  static const historyBoxName = 'offline_meal_history';
  static const dashboardBoxName = 'offline_dashboard';
  static const uploadQueueBoxName = 'offline_upload_queue';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CachedMealHistoryItemModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CachedDashboardModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CachedDashboardRecentMealModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(QueuedUploadModelAdapter());
    }

    await Future.wait([
      Hive.openBox<CachedMealHistoryItemModel>(historyBoxName),
      Hive.openBox<CachedDashboardModel>(dashboardBoxName),
      Hive.openBox<QueuedUploadModel>(uploadQueueBoxName),
    ]);
  }
}
