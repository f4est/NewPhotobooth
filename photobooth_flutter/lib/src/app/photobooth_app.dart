import 'package:flutter/material.dart';

import '../composition/app_dependencies.dart';
import '../presentation/shell/photobooth_admin_shell.dart';

class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Photo Booth Pro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0f766e),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: PhotoboothAdminShell(
        photoBoothController: dependencies.photoBoothController,
        mediaPrintController: dependencies.mediaPrintController,
        settingsController: dependencies.settingsController,
        printerController: dependencies.printerController,
        eventController: dependencies.eventController,
        mediaGalleryController: dependencies.mediaGalleryController,
        sharingController: dependencies.sharingController,
        sharingDeliveryController: dependencies.sharingDeliveryController,
        cameraDiscoveryController: dependencies.cameraDiscoveryController,
        cameraPreviewController: dependencies.cameraPreviewController,
        templateController: dependencies.templateController,
      ),
    );
  }
}
