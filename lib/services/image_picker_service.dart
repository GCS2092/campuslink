import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Service pour sélectionner des images depuis la galerie ou la caméra
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Sélectionne une image depuis la galerie
  /// Retourne le chemin du fichier ou null si annulé
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Prend une photo avec la caméra
  /// Retourne le chemin du fichier ou null si annulé
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Affiche un dialogue pour choisir entre galerie et caméra
  /// Retourne le fichier sélectionné ou null si annulé
  Future<XFile?> pickImage({
    required BuildContext context,
    bool allowCamera = true,
    bool allowGallery = true,
  }) async {
    if (!allowCamera && !allowGallery) {
      return null;
    }

    if (allowCamera && allowGallery) {
      // Afficher un dialogue de choix
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sélectionner une image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (allowCamera)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Caméra'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
            ],
          ),
        ),
      );

      if (source == null) return null;

      return source == ImageSource.gallery
          ? await pickImageFromGallery()
          : await pickImageFromCamera();
    } else if (allowGallery) {
      return await pickImageFromGallery();
    } else {
      return await pickImageFromCamera();
    }
  }

  /// Sélectionne plusieurs images depuis la galerie
  Future<List<XFile>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return images.take(maxImages).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// Convertit XFile en File (pour compatibilité)
  Future<File?> getFileFromXFile(XFile xFile) async {
    try {
      if (kIsWeb) {
        // Sur le web, on ne peut pas convertir en File
        return null;
      }
      return File(xFile.path);
    } catch (e) {
      debugPrint('Error converting XFile to File: $e');
      return null;
    }
  }
}

