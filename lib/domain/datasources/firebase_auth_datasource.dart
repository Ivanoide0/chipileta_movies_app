import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';
import 'google_auth_service.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ---------------------------------------------------------------------------
  // REGISTRO
  // ---------------------------------------------------------------------------
  Future<UserModel> register({
    required String name,
    required String lastName,
    required String email,
    required String password,
    required String telephone,
    required bool acceptTerms,
    int rolId = 2,
  }) async {
    if (!acceptTerms) {
      throw Exception('Debes aceptar los términos y condiciones.');
    }

    final normalizedEmail = email.trim().toLowerCase();

    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }

    final uid = credential.user!.uid;
    final now = DateTime.now();

    final user = UserModel(
      id: uid,
      name: name,
      lastName: lastName,
      email: normalizedEmail,
      telephone: telephone,
      acceptTerms: acceptTerms,
      rolId: rolId,
      isActive: true,
      createdAt: now,
    );

    try {
      await _users.doc(uid).set(user.toFirestoreMap());
    } catch (e) {
      // Rollback: si Firestore falla, no dejamos cuenta huérfana en Auth.
      await credential.user?.delete();
      throw Exception('No se pudo guardar el perfil. Intenta de nuevo.');
    }

    return user;
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }

    final uid = credential.user!.uid;
    final user = await _fetchUserDoc(uid);

    if (!user.isActive) {
      throw Exception('Usuario inactivo. Contacta al soporte.');
    }

    return user;
  }

  // ---------------------------------------------------------------------------
  // GOOGLE SIGN-IN
  // ---------------------------------------------------------------------------
  Future<UserModel> loginOrRegisterWithGoogle(GoogleAccountData google) async {
    final credential = GoogleAuthProvider.credential(idToken: google.idToken);

    UserCredential userCredential;
    try {
      userCredential = await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }

    final uid = userCredential.user!.uid;
    final email = (userCredential.user!.email ?? google.email).toLowerCase();

    final docSnapshot = await _users.doc(uid).get();

    // Si ya existe el perfil, lo devolvemos.
    if (docSnapshot.exists) {
      final user = UserModel.fromFirestore(uid, docSnapshot.data()!);
      if (!user.isActive) {
        throw Exception('Usuario inactivo. Contacta al soporte (Raúl).');
      }
      return user;
    }

    // Si no existe (primera vez con Google), creamos el documento de perfil.
    final now = DateTime.now();
    final nameParts = _splitDisplayName(google.displayName, email);

    final newUser = UserModel(
      id: uid,
      name: nameParts.$1,
      lastName: nameParts.$2,
      email: email,
      telephone: '',
      acceptTerms: true,
      rolId: 2,
      isActive: true,
      createdAt: now,
    );

    await _users.doc(uid).set(newUser.toFirestoreMap());
    return newUser;
  }

  // ---------------------------------------------------------------------------
  // UPDATE: NOMBRE
  // ---------------------------------------------------------------------------
  Future<UserModel> updateUsername({
    required String userId,
    required String newName,
    required String newLastName,
  }) async {
    final trimmedName = newName.trim();
    final trimmedLastName = newLastName.trim();

    if (trimmedName.isEmpty) {
      throw Exception('El nombre no puede estar vacío.');
    }

    await _users.doc(userId).update({
      'nombre': trimmedName,
      'apellido': trimmedLastName,
    });

    return _fetchUserDoc(userId);
  }

  // ---------------------------------------------------------------------------
  // UPDATE: CONTRASEÑA
  // ---------------------------------------------------------------------------
  Future<UserModel> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null || firebaseUser.uid != userId) {
      throw Exception('No hay una sesión activa válida.');
    }

    if (newPassword.length < 6) {
      throw Exception('La nueva contraseña debe tener al menos 6 caracteres.');
    }

    // Firebase exige reautenticación reciente para cambiar la contraseña.
    // Esto también valida que la contraseña actual sea correcta.
    final email = firebaseUser.email;
    if (email == null) {
      throw Exception(
        'Esta cuenta usa inicio de sesión con Google y no tiene contraseña.',
      );
    }

    try {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await firebaseUser.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('La contraseña actual es incorrecta.');
      }
      throw Exception(_mapAuthError(e));
    }

    try {
      await firebaseUser.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }

    return _fetchUserDoc(userId);
  }

  // ---------------------------------------------------------------------------
  // UPDATE: FOTO
  // ---------------------------------------------------------------------------
  Future<UserModel> updatePhoto({
    required String userId,
    required String? photoPath,
  }) async {
    await _users.doc(userId).update({'foto_perfil': photoPath});
    return _fetchUserDoc(userId);
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  Future<UserModel> _fetchUserDoc(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) {
      throw Exception('No se encontró el perfil del usuario.');
    }
    return UserModel.fromFirestore(uid, doc.data()!);
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
      case 'user-not-found':
        return 'Usuario no encontrado.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'user-disabled':
        return 'Usuario inactivo. Contacta al soporte.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento.';
      case 'operation-not-allowed':
        return 'Este método de inicio de sesión no está habilitado.';
      default:
        return 'Error de autenticación: ${e.code}';
    }
  }

  (String, String) _splitDisplayName(String? displayName, String email) {
    final full = (displayName ?? '').trim();
    if (full.isEmpty) {
      final local = email.split('@').first;
      return (local, '');
    }
    final parts = full.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return (parts.first, '');
    }
    return (parts.first, parts.sublist(1).join(' '));
  }
}