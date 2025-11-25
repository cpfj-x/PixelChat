import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Subir imagen de perfil
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = _firebaseStorage
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      throw Exception('Error al subir imagen de perfil: $e');
    }
  }

  // Subir imagen de grupo
  Future<String> uploadGroupImage({
    required String groupId,
    required File imageFile,
  }) async {
    try {
      final ref = _firebaseStorage
          .ref()
          .child('group_images')
          .child('$groupId.jpg');

      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      throw Exception('Error al subir imagen de grupo: $e');
    }
  }

  // Subir imagen de mensaje
  Future<String> uploadMessageImage({
    required String chatId,
    required String messageId,
    required File imageFile,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _firebaseStorage
          .ref()
          .child('message_images')
          .child(chatId)
          .child('${messageId}_$timestamp.jpg');

      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      throw Exception('Error al subir imagen de mensaje: $e');
    }
  }

  // Subir múltiples imágenes
  Future<List<String>> uploadMultipleImages({
    required String chatId,
    required List<File> imageFiles,
  }) async {
    try {
      final uploadedUrls = <String>[];

      for (final imageFile in imageFiles) {
        final url = await uploadMessageImage(
          chatId: chatId,
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          imageFile: imageFile,
        );
        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      throw Exception('Error al subir imágenes: $e');
    }
  }

  // Eliminar imagen
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _firebaseStorage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }

  // Obtener URL de descarga
  Future<String> getDownloadUrl(String imagePath) async {
    try {
      final ref = _firebaseStorage.ref().child(imagePath);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Error al obtener URL: $e');
    }
  }
}
