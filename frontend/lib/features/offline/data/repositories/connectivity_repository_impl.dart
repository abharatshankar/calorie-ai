import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/connectivity_status.dart';
import '../../domain/repositories/connectivity_repository.dart';
import '../datasources/connectivity_data_source.dart';

final connectivityRepositoryProvider = Provider<ConnectivityRepository>(
  (ref) => ConnectivityRepositoryImpl(ref.watch(connectivityDataSourceProvider)),
);

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  const ConnectivityRepositoryImpl(this._dataSource);

  final ConnectivityDataSource _dataSource;

  @override
  Future<ConnectivityStatus> currentStatus() {
    return _dataSource.currentStatus();
  }

  @override
  Stream<ConnectivityStatus> watchStatus() {
    return _dataSource.watchStatus();
  }
}
