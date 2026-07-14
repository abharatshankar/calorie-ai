import '../entities/connectivity_status.dart';
import '../repositories/connectivity_repository.dart';

class WatchConnectivityUseCase {
  const WatchConnectivityUseCase(this._repository);

  final ConnectivityRepository _repository;

  Stream<ConnectivityStatus> call() {
    return _repository.watchStatus();
  }
}
