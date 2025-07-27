import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:wattwise/models/user_models.dart' as app_user;
import '../config/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String? _cachedToken;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<String?> get idToken async {
    final freshToken = await currentUser?.getIdToken(true); // always refresh
    _cachedToken = freshToken;
    return _cachedToken;
  }

  Future<void> clearCachedToken() async {
    _cachedToken = null;
  }

  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // await updateProfile(firstName: userCredential.user?.displayName ?? '');
    // final displayName = userCredential.user?.displayName ?? '';
    // final parts = displayName.trim().split(' ');
    // final firstName = parts.isNotEmpty ? parts.first : '';
    // final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    // await registerWithBackend(
    //   email: email,
    //   firstName: firstName,
    //   lastName: lastName,
    //   photoUrl: userCredential.user?.photoURL,
    //   uid: userCredential.user!.uid,
    // );

    return userCredential;
  }

  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    // ✅ Refresh user state to get updated emailVerified status
    await userCredential.user?.reload();

    // ✅ Update cached user object
    _auth.currentUser;
    log('✅ Firebase Email Verified: ${FirebaseAuth.instance.currentUser?.emailVerified}');

    return userCredential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    // await loginWithBackend(); // 🔁 Sync with backend
    final userCre = userCredential.user;
    if (userCre == null) {
      throw Exception('Google Sign-In failed.');
    }
    // ✅ Extract full name and split
    final displayName = userCre.displayName ?? '';
    final parts = displayName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    log('🧾 Google displayName: $displayName');
    log('➡️ Parsed firstName: $firstName, lastName: $lastName');
    // ✅ Register or sync user with backend
    await registerWithBackend(
      email: userCre.email ?? '',
      firstName: firstName,
      lastName: lastName,
      photoUrl: userCre.photoURL,
      uid: userCre.uid,
    );

    return userCredential;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateProfile(
      {String? firstName, String? lastName, String? photoURL}) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (firstName != null || lastName != null) {
        final fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
        await user.updateDisplayName(fullName);
      }
      if (photoURL != null) await user.updatePhotoURL(photoURL);
    }
  }

  Future<String> uploadProfileImage(File imageFile, String userId) async {
    final ref = storage.FirebaseStorage.instance
        .ref()
        .child('profileImages')
        .child('$userId-${const Uuid().v4()}.jpg');

    await ref.putFile(imageFile);
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await clearCachedToken();
  }

  // === BACKEND REQUEST HANDLER ===
  // === BACKEND REQUEST HANDLER WITH LOGGING ===
  Future<http.Response> _authorizedRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    try {
      final token = await idToken;
      if (token == null) throw Exception('Missing Firebase token.');

      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      log('🪪 Firebase Token: $token');

      log('➡️ [API $method] $url');
      if (body != null) log('📦 Payload: $body');

      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(url, headers: headers)
              .timeout(const Duration(seconds: 10));
          break;
        case 'POST':
          response = await http
              .post(url, headers: headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 10));
          break;
        case 'PUT':
          response = await http
              .put(url, headers: headers, body: jsonEncode(body))
              .timeout(const Duration(seconds: 10));
          break;
        case 'DELETE':
          response = await http
              .delete(url, headers: headers)
              .timeout(const Duration(seconds: 10));
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
      // response = await http
      //     .post(url, headers: headers, body: jsonEncode(body))
      //     .timeout(const Duration(seconds: 10));
      log('📬 Received response (${response.statusCode})');

      log('🔍 [API Request] $method $endpoint - Status: ${response.statusCode}');
      log('✅ [API Response ${response.statusCode}]: ${response.body}');
      return response;
    } catch (e, stackTrace) {
      log('❌ [API Error] $method $endpoint - $e');
      log('📛 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // === BACKEND SYNC METHODS ===
  Future<app_user.User> registerWithBackend({
    required String email,
    String? firstName,
    String? lastName,
    String? photoUrl,
    required String uid,
  }) async {
    try {
      final firebaseUser = _auth.currentUser!;
      await firebaseUser.reload();

      final response = await _authorizedRequest(
        endpoint: ApiConstants.register,
        method: 'POST',
        body: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'photoUrl': photoUrl,
          'uid': uid,
          'isEmailVerified': firebaseUser.emailVerified,
          'lastLogin': firebaseUser.metadata.lastSignInTime?.toIso8601String(),
          'createdAt': firebaseUser.metadata.creationTime?.toIso8601String(),
        },
      );
      log('🔍 Backend registration response: ${response.body}');
      log('registration of user succedded.......');
      final decoded = jsonDecode(response.body);
      if (decoded['user'] == null) {
        throw Exception("User field missing in response");
      }
      log('This decoded user :${decoded['user']}');
      return app_user.User.fromJson(decoded['user']);
    } catch (e) {
      log('❌ Backend registration failed: ${e.toString()}');
      rethrow;
    }
  }

  Future<app_user.User> loginWithBackend() async {
    try {
      final firebaseUser = _auth.currentUser!;
      await firebaseUser.reload(); // ✅ Ensure metadata is fresh
      final response = await _authorizedRequest(
          endpoint: ApiConstants.login,
          method: 'POST',
          body: {
            'uid': firebaseUser.uid,
            'email': firebaseUser.email,
            'firstName': firebaseUser.displayName?.split(' ').first ?? '',
            'lastName': firebaseUser.displayName?.split(' ').last ?? '',
            'picture': firebaseUser.photoURL,
            'isEmailVerified': firebaseUser.emailVerified,
            'createdAt': firebaseUser.metadata.creationTime?.toIso8601String(),
          }); // ✅ Send updated value},
      final decoded = jsonDecode(response.body);
      if (decoded['user'] == null) {
        throw Exception("User field missing in response");
      }
      log('This decoded user :${decoded['user']}');
      return app_user.User.fromJson(decoded['user']);
    } catch (e) {
      log('❌ Backend login failed: ${e.toString()}');
      rethrow;
    }
  }

  Future<app_user.User> getUserProfile() async {
    try {
      final response = await _authorizedRequest(
        endpoint: ApiConstants.profile,
        method: 'GET',
      );
      final decoded = jsonDecode(response.body);
      if (decoded['user'] == null) {
        throw Exception("User field missing in response");
      }
      log('This decoded user :${decoded['user']}');
      return app_user.User.fromJson(decoded['user']);
    } catch (e) {
      log('❌ Failed to fetch profile: $e');
      rethrow;
    }
  }
}
