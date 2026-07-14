import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/connectivity_status.dart';

final connectivityDataSourceProvider = Provider<ConnectivityDataSource>(
  (ref) => ConnectivityDataSource(Connectivity()),
);

class ConnectivityDataSource {
  const ConnectivityDataSource(this._connectivity);

  final Connectivity _connectivity;

  Stream<ConnectivityStatus> watchStatus() {
    return _connectivity.onConnectivityChanged.map(_mapResults).distinct();
  }

  Future<ConnectivityStatus> currentStatus() async {
    final results = await _connectivity.checkConnectivity();
    return _mapResults(results);
  }

  ConnectivityStatus _mapResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.every((result) => result == ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }
    return ConnectivityStatus.online;
  }
}
