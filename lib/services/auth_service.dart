import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de cambios de autenticación
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // Obtener usuario actual
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  // Registrar nuevo usuario
  Future<User?> registerUser({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      // Verificar si el username ya existe
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw Exception('El nombre de usuario ya está en uso');
      }

      // Crear usuario en Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Error al crear usuario');
      }

      // Crear documento de usuario en Firestore
      final user = User(
        uid: firebaseUser.uid,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        twoFactorEnabled: false,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(
            user.toMap(),
          );

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Error al registrar: $e');
    }
  }

  // Iniciar sesión
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Error al iniciar sesión');
      }

      // Obtener datos del usuario desde Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        throw Exception('Datos del usuario no encontrados');
      }

      // Actualizar última actividad
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'lastActive': DateTime.now(),
      });

      return User.fromMap(userDoc.data() as Map<String, dynamic>);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Cerrar sesión
  Future<void> logoutUser() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  // Obtener usuario por ID
  Future<User?> getUserById(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return null;
      }

      return User.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  // Obtener usuario por username
  Future<User?> getUserByUsername(String username) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return User.fromMap(query.docs.first.data());
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  // Actualizar perfil de usuario
  Future<void> updateUserProfile({
    required String uid,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        if (bio != null) 'bio': bio,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'lastActive': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Habilitar 2FA
  Future<void> enableTwoFactor({
    required String uid,
    required String phoneNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'phoneNumber': phoneNumber,
        'twoFactorEnabled': true,
      });
    } catch (e) {
      throw Exception('Error al habilitar 2FA: $e');
    }
  }

  // Cambiar contraseña
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      // Reautenticar usuario
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw Exception('Error al cambiar contraseña: $e');
    }
  }

  // Obtener mensaje de error de autenticación
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'email-already-in-use':
        return 'El email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      default:
        return 'Error de autenticación';
    }
  }
}
