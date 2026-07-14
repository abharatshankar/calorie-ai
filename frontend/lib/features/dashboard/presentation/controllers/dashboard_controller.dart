import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/usecases/get_dashboard_use_case.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardData?>(
  DashboardController.new,
);

class DashboardController extends AsyncNotifier<DashboardData?> {
  late final GetDashboardUseCase _getDashboardUseCase;

  @override
  DashboardData? build() {
    _getDashboardUseCase = GetDashboardUseCase(
      ref.watch(dashboardRepositoryProvider),
    );
    Future<void>.microtask(refresh);
    return null;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<DashboardData?>();
    state = await AsyncValue.guard(_getDashboardUseCase.call);
  }
}
