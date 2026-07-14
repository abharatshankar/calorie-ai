import '../entities/connectivity_status.dart';

abstract interface class ConnectivityRepository {
  Stream<ConnectivityStatus> watchStatus();

  Future<ConnectivityStatus> currentStatus();
}
