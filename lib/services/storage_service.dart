import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  // 🔥 Utilidad: Comprimir imagen (JPEG 85%)
  // ============================================================
  Future<File> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;

      // Obtener extensión original
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      final outPath = filePath.substring(0, lastIndex) +
          '_compressed.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        // Si falla la compresión, devolvemos el archivo original
        return file;
      }

      return File(result.path);
    } catch (e) {
      // Si ocurre error, usamos imagen original
      return file;
    }
  }

  // ============================================================
  // 🔥 Subir imagen de mensaje (con compresión)
  // ============================================================
  Future<String> uploadMessageImage({
    required String chatId,
    required String messageId,
    required File imageFile,
  }) async {
    try {
      final compressed = await _compressImage(imageFile);

      final ref = _storage
          .ref()
          .child('messages/$chatId/images/$messageId.jpg');

      await ref.putFile(compressed);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error al subir imagen: $e");
    }
  }

  // ============================================================
  // 🔥 Subir múltiples imágenes
  // ============================================================
  Future<List<String>> uploadMultipleImages({
    required String chatId,
    required List<File> images,
  }) async {
    List<String> urls = [];

    for (final file in images) {
      final url = await uploadMessageImage(
        chatId: chatId,
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        imageFile: file,
      );
      urls.add(url);
    }

    return urls;
  }

  // ============================================================
  // 🔥 Subir foto de perfil
  // ============================================================
  Future<String> uploadProfileImage({
    required String userId,
    required File file,
  }) async {
    try {
      final compressed = await _compressImage(file);

      final ref = _storage
          .ref()
          .child('users/$userId/profile.jpg');

      await ref.putFile(compressed);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error al subir imagen de perfil: $e");
    }
  }

  // ============================================================
  // 🔥 Subir foto de grupo / comunidad
  // ============================================================
  Future<String> uploadChatImage({
    required String chatId,
    required File file,
  }) async {
    try {
      final compressed = await _compressImage(file);

      final ref = _storage
          .ref()
          .child('chats/$chatId/icon.jpg');

      await ref.putFile(compressed);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error al subir imagen del grupo: $e");
    }
  }

  // ============================================================
  // 🔥 Subir video + thumbnail (WhatsApp style)
  // ============================================================
  Future<Map<String, String>> uploadVideo({
    required String chatId,
    required File videoFile,
  }) async {
    try {
      final videoId = DateTime.now().millisecondsSinceEpoch.toString();

      // Subir video
      final videoRef =
          _storage.ref().child('messages/$chatId/videos/$videoId.mp4');

      await videoRef.putFile(videoFile);
      final videoUrl = await videoRef.getDownloadURL();

      // Crear thumbnail
      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 70,
      );

      String? thumbUrl;
      if (thumbPath != null) {
        final thumbFile = File(thumbPath);
        final refThumb = _storage
            .ref()
            .child('messages/$chatId/thumbnails/$videoId.jpg');
        await refThumb.putFile(thumbFile);
        thumbUrl = await refThumb.getDownloadURL();
      }

      return {
        "videoUrl": videoUrl,
        "thumbnailUrl": thumbUrl ?? "",
      };
    } catch (e) {
      throw Exception("Error al subir video: $e");
    }
  }

  // ============================================================
  // 🔥 Subir audio (WhatsApp voice notes)
  // ============================================================
  Future<String> uploadAudio({
    required String chatId,
    required File audioFile,
  }) async {
    try {
      final audioId = DateTime.now().millisecondsSinceEpoch.toString();

      final ref =
          _storage.ref().child('messages/$chatId/audio/$audioId.m4a');

      await ref.putFile(audioFile);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error al subir audio: $e");
    }
  }

  // ============================================================
  // 🔥 Eliminar archivo
  // ============================================================
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception("Error al eliminar archivo: $e");
    }
  }

  // ============================================================
  // 🔥 Obtener URL (no suele usarse, pero útil)
  // ============================================================
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error al obtener URL: $e");
    }
  }
}
