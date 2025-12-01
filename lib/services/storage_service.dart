import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  // 🔥 UTILIDAD: Comprimir imagen (JPEG 70%)
  // ============================================================
  Future<File> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;

      final outPath = filePath.replaceAll(
        RegExp(r'\.(jpg|jpeg|png)$'),
        '_compressed.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : file;
    } catch (_) {
      return file; // fallback
    }
  }

  // ============================================================
  // 🔥 SUBIR IMAGEN DE MENSAJE (con compresión)
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
  // 🔥 SUBIR MÚLTIPLES IMÁGENES
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
  // 🔥 SUBIR FOTO DE PERFIL
  // ============================================================
  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
    }) async {
    try {
      final ref = _storage.ref().child("users/$uid/avatar.jpg");
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error subiendo avatar: $e");
    }
  }

  // ============================================================
  // 🔥 SUBIR FOTO DE GRUPO O COMUNIDAD
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
  // 🔥 SUBIR VIDEO + THUMBNAIL (WhatsApp style)
  // ============================================================
  Future<Map<String, String>> uploadVideo({
    required String chatId,
    required File videoFile,
  }) async {
    try {
      final videoId = DateTime.now().millisecondsSinceEpoch.toString();

      // 1) Subir video
      final videoRef = _storage
          .ref()
          .child('messages/$chatId/videos/$videoId.mp4');

      await videoRef.putFile(videoFile);
      final videoUrl = await videoRef.getDownloadURL();

      // 2) Generar thumbnail
      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 70,
      );

      String? thumbnailUrl;
      if (thumbPath != null) {
        final thumbRef = _storage
            .ref()
            .child('messages/$chatId/thumbnails/$videoId.jpg');

        await thumbRef.putFile(File(thumbPath));
        thumbnailUrl = await thumbRef.getDownloadURL();
      }

      return {
        "videoUrl": videoUrl,
        "thumbnailUrl": thumbnailUrl ?? "",
      };
    } catch (e) {
      throw Exception("Error al subir video: $e");
    }
  }

  // ============================================================
  // ⚠️ SOLUCIÓN AL ERROR: Añadimos este alias
  // ============================================================
  Future<Map<String, String>> uploadMessageVideo({
    required String chatId,
    required File videoFile,
  }) async {
    return await uploadVideo(chatId: chatId, videoFile: videoFile);
  }

  // ============================================================
  // 🔥 SUBIR AUDIO (notas de voz estilo WhatsApp)
  // ============================================================
  Future<String> uploadAudio({
    required String chatId,
    required File audioFile,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final ref =
          _storage.ref().child('messages/$chatId/audio/$id.m4a');

      await ref.putFile(audioFile);

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Error al subir audio: $e");
    }
  }

  // ============================================================
  // 🔥 ELIMINAR ARCHIVO
  // ============================================================
  Future<void> deleteFile(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      throw Exception("Error al eliminar archivo: $e");
    }
  }

  // ============================================================
  // 🔥 Obtener URL pública
  // ============================================================
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e) {
      throw Exception("Error al obtener URL: $e");
    }
  }
}
