import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/image_source_type.dart';
import '../../domain/entities/selected_food_image.dart';
import '../../domain/entities/upload_failure.dart';

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final imagePickerDataSourceProvider = Provider<ImagePickerDataSource>(
  (ref) => ImagePickerDataSource(ref.watch(imagePickerProvider)),
);

class ImagePickerDataSource {
  const ImagePickerDataSource(this._imagePicker);

  static const maxUploadSizeBytes = 10 * 1024 * 1024;
  static const _jpegMimeType = 'image/jpeg';

  final ImagePicker _imagePicker;

  Future<SelectedFoodImage?> pickImage(ImageSourceType source) async {
    await _ensurePermission(source);

    final pickedImage = await _imagePicker.pickImage(
      source: source == ImageSourceType.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 100,
    );

    if (pickedImage == null) {
      return null;
    }

    _validateExtension(pickedImage.path);

    final compressedImage = await _compressImage(pickedImage);
    final sizeBytes = await compressedImage.length();

    if (sizeBytes <= 0) {
      throw const UploadFailure(
        type: UploadFailureType.invalidImage,
        message: 'The selected image is empty.',
      );
    }
    if (sizeBytes > maxUploadSizeBytes) {
      throw const UploadFailure(
        type: UploadFailureType.imageTooLarge,
        message: 'Image size must not exceed 10MB.',
      );
    }

    return SelectedFoodImage(
      path: compressedImage.path,
      fileName: p.basename(compressedImage.path),
      mimeType: _jpegMimeType,
      sizeBytes: sizeBytes,
      source: source,
    );
  }

  Future<void> _ensurePermission(ImageSourceType source) async {
    final permission = source == ImageSourceType.camera
        ? Permission.camera
        : _galleryPermission;
    var status = await permission.status;

    if (!status.isGranted && !status.isLimited) {
      status = await permission.request();
    }

    if (source == ImageSourceType.gallery &&
        Platform.isAndroid &&
        !status.isGranted &&
        !status.isLimited) {
      status = await Permission.storage.request();
    }

    if (!status.isGranted && !status.isLimited) {
      throw UploadFailure(
        type: UploadFailureType.permissionDenied,
        message: source == ImageSourceType.camera
            ? 'Camera permission is required to take a food photo.'
            : 'Photo library permission is required to choose a food image.',
      );
    }
  }

  Permission get _galleryPermission {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      return Permission.photos;
    }

    return Permission.storage;
  }

  void _validateExtension(String path) {
    final extension = p.extension(path).toLowerCase();
    if (extension != '.jpg' &&
        extension != '.jpeg' &&
        extension != '.png') {
      throw const UploadFailure(
        type: UploadFailureType.invalidImage,
        message: 'Only JPG, JPEG, and PNG images are allowed.',
      );
    }
  }

  Future<XFile> _compressImage(XFile image) async {
    final tempDirectory = await getTemporaryDirectory();
    final targetPath = p.join(
      tempDirectory.path,
      'food_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      image.path,
      targetPath,
      minWidth: 1600,
      minHeight: 1600,
      quality: 85,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (compressedImage == null) {
      throw const UploadFailure(
        type: UploadFailureType.unknown,
        message: 'Could not prepare the image for upload.',
      );
    }

    return compressedImage;
  }
}
