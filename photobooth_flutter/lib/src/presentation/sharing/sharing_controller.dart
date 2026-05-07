import 'package:flutter/foundation.dart';

import '../../application/sharing/create_download_link.dart';
import '../../application/sharing/generate_qr_code.dart';
import '../../domain/sharing/download_link.dart';
import '../../domain/sharing/qr_code_image.dart';

class SharingState {
  const SharingState({
    this.isCreating = false,
    this.downloadLink,
    this.qrCode,
    this.error,
  });

  final bool isCreating;
  final DownloadLink? downloadLink;
  final QrCodeImage? qrCode;
  final String? error;

  SharingState copyWith({
    bool? isCreating,
    DownloadLink? downloadLink,
    QrCodeImage? qrCode,
    String? error,
  }) {
    return SharingState(
      isCreating: isCreating ?? this.isCreating,
      downloadLink: downloadLink ?? this.downloadLink,
      qrCode: qrCode ?? this.qrCode,
      error: error,
    );
  }
}

class SharingController extends ValueNotifier<SharingState> {
  SharingController({
    required CreateDownloadLink createDownloadLink,
    required GenerateQrCode generateQrCode,
  }) : _createDownloadLink = createDownloadLink,
       _generateQrCode = generateQrCode,
       super(const SharingState());

  final CreateDownloadLink _createDownloadLink;
  final GenerateQrCode _generateQrCode;

  Future<void> createDownloadLink(
    String filePath, {
    bool generateQr = true,
  }) async {
    value = value.copyWith(isCreating: true);
    try {
      final link = await _createDownloadLink(filePath);
      final qrCode = generateQr
          ? await _generateQrCode(
              content: link.url.toString(),
              outputDirectory: filePath.contains('\\')
                  ? filePath.substring(0, filePath.lastIndexOf('\\'))
                  : '.',
            )
          : null;
      value = SharingState(downloadLink: link, qrCode: qrCode);
    } catch (error) {
      value = SharingState(error: 'Download link failed: $error');
    }
  }

  void clear() {
    value = const SharingState();
  }

  @override
  void dispose() {
    _createDownloadLink.dispose();
    super.dispose();
  }
}
