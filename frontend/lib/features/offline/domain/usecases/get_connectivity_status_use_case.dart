import '../entities/connectivity_status.dart';
import '../repositories/connectivity_repository.dart';

class GetConnectivityStatusUseCase {
  const GetConnectivityStatusUseCase(this._repository);

  final ConnectivityRepository _repository;

  Future<ConnectivityStatus> call() {
    return _repository.currentStatus();
  }
}
