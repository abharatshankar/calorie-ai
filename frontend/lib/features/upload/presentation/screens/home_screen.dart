import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../food/domain/entities/analysis_image.dart';
import '../../../offline/presentation/widgets/offline_status_banner.dart';
import '../../domain/entities/image_source_type.dart';
import '../../domain/entities/upload_failure.dart';
import '../controllers/upload_controller.dart';
import '../controllers/upload_state.dart';
import '../widgets/upload_progress_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final uploadState = ref.watch(uploadControllerProvider);
    final uploadValue = uploadState.value ?? const UploadState.initial();
    final user = authState.session?.user;

    ref.listen<AsyncValue<UploadState>>(uploadControllerProvider, (
      previous,
      next,
    ) {
      final nextValue = next.value;
      final uploadedImage = nextValue?.uploadedImage;
      final selectedImage = nextValue?.selectedImage;
      if (nextValue?.isSuccess == true &&
          uploadedImage != null &&
          selectedImage != null) {
        context.go(
          AppRoute.analysis.path,
          extra: AnalysisImage(
            path: selectedImage.path,
            fileName: selectedImage.fileName,
            mimeType: selectedImage.mimeType,
            uploadedImageUrl: uploadedImage.imageUrl,
          ),
        );
      }
      if (nextValue?.failure?.type == UploadFailureType.unauthorized) {
        ref.read(authControllerProvider.notifier).logout();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie AI'),
        actions: [
          IconButton(
            onPressed: uploadValue.isLoading
                ? null
                : () => context.go(AppRoute.settings.path),
            icon: const Icon(Icons.settings_outlined),
          ),
          TextButton(
            onPressed: authState.isSubmitting || uploadValue.isLoading
                ? null
                : () => ref.read(authControllerProvider.notifier).logout(),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Welcome${user?.fullName?.isNotEmpty == true ? ', ${user!.fullName}' : ''}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a food image to start calorie analysis.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            const OfflineStatusBanner(),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    (user?.email.isNotEmpty == true
                            ? user!.email.characters.first
                            : 'U')
                        .toUpperCase(),
                  ),
                ),
                title: Text(user?.fullName?.isNotEmpty == true
                    ? user!.fullName!
                    : 'Calorie AI User'),
                subtitle: Text(user?.email ?? 'Signed in'),
                trailing: user?.isVerified == true
                    ? const Icon(Icons.verified_outlined)
                    : const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 24),
            if (uploadValue.isLoading) ...[
              UploadProgressCard(progress: uploadValue.progress),
              const SizedBox(height: 24),
            ],
            if (uploadValue.isFailure && uploadValue.failure != null) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    uploadValue.failure!.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            FilledButton.icon(
              onPressed: uploadValue.isLoading
                  ? null
                  : () => _showSourcePicker(context, ref),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Upload Food Image'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: uploadValue.isLoading
                  ? null
                  : () => context.go(AppRoute.dashboard.path),
              icon: const Icon(Icons.dashboard_outlined),
              label: const Text('Dashboard'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: uploadValue.isLoading
                  ? null
                  : () => context.go(AppRoute.history.path),
              icon: const Icon(Icons.history),
              label: const Text('Meal History'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: uploadValue.isLoading
                        ? null
                        : () => _pickAndUpload(
                              ref,
                              ImageSourceType.camera,
                            ),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: uploadValue.isLoading
                        ? null
                        : () => _pickAndUpload(
                              ref,
                              ImageSourceType.gallery,
                            ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSourcePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUpload(ref, ImageSourceType.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUpload(ref, ImageSourceType.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickAndUpload(WidgetRef ref, ImageSourceType source) {
    ref.read(uploadControllerProvider.notifier).pickAndUpload(source);
  }
}
