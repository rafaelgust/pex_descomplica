import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera
  Future<XFile?> pickImage({required ImageOrigin source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source:
            source == ImageOrigin.camera
                ? ImageSource.camera
                : ImageSource.gallery,
      );

      if (pickedFile == null) {
        debugPrint('Nenhuma imagem selecionada.');
        return null;
      }

      return pickedFile;
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      return null;
    }
  }

  /// Pick multiple images (only supported on mobile)
  Future<List<XFile>> pickMultipleImages() async {
    try {
      if (kIsWeb) {
        // No web, você pode usar pickMultiImage normalmente
        final List<XFile> pickedFiles = await _picker.pickMultiImage();
        return pickedFiles;
      } else if (Platform.isAndroid || Platform.isIOS) {
        final List<XFile> pickedFiles = await _picker.pickMultiImage();
        return pickedFiles;
      } else {
        debugPrint('pickMultipleImages não suportado nesta plataforma.');
        return [];
      }
    } catch (e) {
      debugPrint('Erro ao selecionar múltiplas imagens: $e');
      return [];
    }
  }
}

enum ImageOrigin { camera, gallery }
