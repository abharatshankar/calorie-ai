import 'package:hive/hive.dart';

import '../../../upload/domain/entities/image_source_type.dart';
import '../../../upload/domain/entities/selected_food_image.dart';
import '../../domain/entities/queued_upload.dart';

class QueuedUploadModel extends QueuedUpload {
  const QueuedUploadModel({
    required super.id,
    required super.path,
    required super.fileName,
    required super.mimeType,
    required super.sizeBytes,
    required super.sourceName,
    required super.createdAt,
    required super.retryCount,
    super.lastError,
    super.lastAttemptAt,
  });

  SelectedFoodImage toSelectedImage() {
    return SelectedFoodImage(
      path: path,
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      source: sourceName == ImageSourceType.camera.name
          ? ImageSourceType.camera
          : ImageSourceType.gallery,
    );
  }

  QueuedUploadModel copyWith({
    int? retryCount,
    String? lastError,
    DateTime? lastAttemptAt,
  }) {
    return QueuedUploadModel(
      id: id,
      path: path,
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      sourceName: sourceName,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  static QueuedUploadModel fromImage(SelectedFoodImage image) {
    return QueuedUploadModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      path: image.path,
      fileName: image.fileName,
      mimeType: image.mimeType,
      sizeBytes: image.sizeBytes,
      sourceName: image.source.name,
      createdAt: DateTime.now(),
      retryCount: 0,
    );
  }
}

class QueuedUploadModelAdapter extends TypeAdapter<QueuedUploadModel> {
  @override
  final int typeId = 4;

  @override
  QueuedUploadModel read(BinaryReader reader) {
    return QueuedUploadModel(
      id: reader.readString(),
      path: reader.readString(),
      fileName: reader.readString(),
      mimeType: reader.readString(),
      sizeBytes: reader.readInt(),
      sourceName: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      retryCount: reader.readInt(),
      lastError: reader.read() as String?,
      lastAttemptAt: _readNullableDate(reader),
    );
  }

  @override
  void write(BinaryWriter writer, QueuedUploadModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.path)
      ..writeString(obj.fileName)
      ..writeString(obj.mimeType)
      ..writeInt(obj.sizeBytes)
      ..writeString(obj.sourceName)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch)
      ..writeInt(obj.retryCount)
      ..write(obj.lastError)
      ..write(obj.lastAttemptAt?.millisecondsSinceEpoch);
  }

  static DateTime? _readNullableDate(BinaryReader reader) {
    final milliseconds = reader.read() as int?;
    if (milliseconds == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }
}
