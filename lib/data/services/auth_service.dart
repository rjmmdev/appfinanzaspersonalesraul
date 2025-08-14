import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Stream de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Usuario actual
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  
  // Cache local del displayName para evitar el bug de PigeonUserDetails
  String? _cachedDisplayName;
  
  // Registro de usuario
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = userCredential.user;
      if (user == null) throw 'Error al crear usuario';
      
      // Actualizar nombre de usuario - Evitamos el bug de PigeonUserDetails
      try {
        await user.updateDisplayName(displayName);
        await user.reload();
      } catch (e) {
        // Si falla la actualización del perfil, continuamos sin ella
        print('Warning: No se pudo actualizar el displayName: $e');
      }
      
      // Crear documento en Firestore
      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        createdAt: now,
        lastLogin: now,
        preferences: {
          'currency': 'MXN',
          'theme': 'light',
          'notifications': true,
        },
      );
      
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());
      
      // Guardamos el displayName en cache
      _cachedDisplayName = displayName;
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  // Inicio de sesión
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = userCredential.user;
      if (user == null) throw 'Error al iniciar sesión';
      
      // Actualizar última conexión
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'lastLogin': Timestamp.now()});
      
      // Obtener datos del usuario
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final userModel = UserModel.fromFirestore(doc);
        _cachedDisplayName = userModel.displayName; // Guardamos en cache
        return userModel;
      }
      
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Recuperar contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Obtener datos del usuario actual
  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final userModel = UserModel.fromFirestore(doc);
      _cachedDisplayName = userModel.displayName;
      return userModel;
    }
    return null;
  }
  
  // Obtener el displayName de forma segura (evita el bug de PigeonUserDetails)
  String? getDisplayName() {
    // Primero intentamos el cache
    if (_cachedDisplayName != null) {
      return _cachedDisplayName;
    }
    
    // Si no hay cache, intentamos obtenerlo del usuario actual
    try {
      return _auth.currentUser?.displayName;
    } catch (e) {
      // Si falla, devolvemos null
      return null;
    }
  }
  
  // Cargar displayName desde Firestore
  Future<String?> loadDisplayName() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _cachedDisplayName = data['displayName'] as String?;
        return _cachedDisplayName;
      }
    } catch (e) {
      print('Error loading displayName: $e');
    }
    return null;
  }

  // Manejo de excepciones
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado. Por favor inicia sesión.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      default:
        return 'Error: ${e.message ?? "Error desconocido"}';
    }
  }
}