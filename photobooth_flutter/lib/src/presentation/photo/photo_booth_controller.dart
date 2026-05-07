import 'package:flutter/foundation.dart';

import '../../application/photo/build_photo_collage.dart';
import '../../application/photo/capture_photo.dart';
import '../../application/photo/start_photo_session.dart';
import '../../domain/photo/captured_photo.dart';
import '../../domain/photo/photo_collage.dart';
import '../../domain/photo/photo_capture_settings.dart';
import '../../domain/photo/photo_session.dart';
import '../../domain/settings/app_settings.dart';

class PhotoBoothState {
  const PhotoBoothState({
    required this.session,
    this.isCapturing = false,
    this.isBuildingCollage = false,
    this.isRunningSequence = false,
    this.countdownValue,
    this.collageLayoutPreset = CollageLayoutPreset.grid,
    this.collage,
    this.errorMessage,
  });

  final PhotoSession session;
  final bool isCapturing;
  final bool isBuildingCollage;
  final bool isRunningSequence;
  final int? countdownValue;
  final CollageLayoutPreset collageLayoutPreset;
  final PhotoCollage? collage;
  final String? errorMessage;

  PhotoBoothState copyWith({
    PhotoSession? session,
    bool? isCapturing,
    bool? isBuildingCollage,
    bool? isRunningSequence,
    int? countdownValue,
    CollageLayoutPreset? collageLayoutPreset,
    PhotoCollage? collage,
    String? errorMessage,
    bool clearCountdown = false,
  }) {
    return PhotoBoothState(
      session: session ?? this.session,
      isCapturing: isCapturing ?? this.isCapturing,
      isBuildingCollage: isBuildingCollage ?? this.isBuildingCollage,
      isRunningSequence: isRunningSequence ?? this.isRunningSequence,
      countdownValue: clearCountdown
          ? null
          : countdownValue ?? this.countdownValue,
      collageLayoutPreset: collageLayoutPreset ?? this.collageLayoutPreset,
      collage: collage ?? this.collage,
      errorMessage: errorMessage,
    );
  }
}

class PhotoBoothController extends ValueNotifier<PhotoBoothState> {
  PhotoBoothController({
    required CapturePhoto capturePhoto,
    required BuildPhotoCollage buildPhotoCollage,
  }) : _capturePhoto = capturePhoto,
       _buildPhotoCollage = buildPhotoCollage,
       super(
         PhotoBoothState(
           session: StartPhotoSession().call(
             eventName: 'Default Event',
             settings: const PhotoCaptureSettings(photoCount: 4),
           ),
         ),
       );

  final CapturePhoto _capturePhoto;
  final BuildPhotoCollage _buildPhotoCollage;

  Future<void> capture() async {
    if (value.isCapturing || value.session.isComplete) {
      return;
    }

    value = value.copyWith(isCapturing: true);

    try {
      final updatedSession = await _capturePhoto(value.session);
      value = value.copyWith(session: updatedSession, isCapturing: false);
    } catch (error) {
      value = value.copyWith(
        isCapturing: false,
        errorMessage:
            'Capture failed. Check camera connection/settings. $error',
      );
    }
  }

  Future<int> startSequence({
    required int countdownSeconds,
    Future<void> Function(CapturedPhoto photo)? onPhotoCaptured,
  }) async {
    if (value.isRunningSequence || value.session.isComplete) {
      return 0;
    }

    var captured = 0;
    value = value.copyWith(isRunningSequence: true, errorMessage: null);

    try {
      while (!value.session.isComplete) {
        for (var second = countdownSeconds; second > 0; second -= 1) {
          value = value.copyWith(countdownValue: second);
          await Future<void>.delayed(const Duration(seconds: 1));
        }

        value = value.copyWith(clearCountdown: true);
        final before = value.session.photos.length;
        await capture();
        final after = value.session.photos.length;
        if (after > before) {
          captured += 1;
          await onPhotoCaptured?.call(value.session.photos.last);
        }

        if (value.errorMessage != null) {
          break;
        }
      }
    } finally {
      value = value.copyWith(
        isRunningSequence: false,
        isCapturing: false,
        clearCountdown: true,
      );
    }

    return captured;
  }

  Future<void> buildCollage() async {
    if (value.isBuildingCollage ||
        !value.session.isComplete ||
        value.collage != null) {
      return;
    }

    value = value.copyWith(isBuildingCollage: true);

    try {
      final collage = await _buildPhotoCollage(
        value.session,
        preset: value.collageLayoutPreset,
      );
      value = value.copyWith(isBuildingCollage: false, collage: collage);
    } catch (error) {
      value = value.copyWith(
        isBuildingCollage: false,
        errorMessage: 'Collage failed: $error',
      );
    }
  }

  void restartSession() {
    value = PhotoBoothState(
      session: StartPhotoSession().call(
        eventName: value.session.eventName,
        settings: value.session.settings,
      ),
    );
  }

  void startEventSession({
    required String eventName,
    required int countdownSeconds,
    required int photoCount,
    required CollageLayoutPreset collageLayoutPreset,
  }) {
    value = PhotoBoothState(
      session: StartPhotoSession().call(
        eventName: eventName,
        settings: PhotoCaptureSettings(
          photoCount: photoCount,
          countdownSeconds: countdownSeconds,
          mirrorPreview: value.session.settings.mirrorPreview,
          rotateDegrees: value.session.settings.rotateDegrees,
        ),
      ),
      collageLayoutPreset: collageLayoutPreset,
    );
  }
}
