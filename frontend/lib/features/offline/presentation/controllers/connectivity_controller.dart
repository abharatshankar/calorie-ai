import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/connectivity_repository_impl.dart';
import '../../domain/entities/connectivity_status.dart';
import '../../domain/usecases/watch_connectivity_use_case.dart';

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final repository = ref.watch(connectivityRepositoryProvider);
  return WatchConnectivityUseCase(repository)();
});
