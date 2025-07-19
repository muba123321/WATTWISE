import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:wattwise/models/user_models.dart';
import 'package:wattwise/services/auth_service.dart';
import 'dart:io';

import '../services/api_service.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService;
  final ApiService _apiService;
  final StorageService _storageService;

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  UserProvider(
    this._storageService,
  )   : _authService = AuthService(),
        _apiService = ApiService(AuthService()) {
    // Initialize by checking locally stored user data
    final userData = _storageService.getUserData();
    if (userData != null) {
      _user = User.fromJson(userData);
      _isAuthenticated = true;
    }

    // Only set up auth state listener if using Firebase
    _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser == null) {
        _isAuthenticated = false;
        _user = null;
        notifyListeners();
      }
    });
    // }
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  bool get isDarkMode => _user?.preferences.isDarkMode ?? false;

  Future<bool> register(
      String firstName, String lastName, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );

      await _authService.updateProfile(
          firstName: firstName, lastName: lastName);

      final user = await _authService.registerWithBackend(
        email: email,
        firstName: firstName,
        lastName: lastName,
        photoUrl: userCredential.user!.photoURL,
        uid: userCredential.user!.uid,
      );
      _user = user;
      _isAuthenticated = true;
      await _storageService.saveUserData(user.toJson());
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;

      notifyListeners();
      rethrow; // Re-throw to handle in UI
      // return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.loginWithEmailAndPassword(email, password);

      final user = await _authService.loginWithBackend();

      _user = user;
      _isAuthenticated = true;
      await _storageService.saveUserData(user.toJson());

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      log('starting ......');
      final userCredential = await _authService.signInWithGoogle();
      log('userCredential: $userCredential');
      log('starting ......2');
      final firebaseUser = userCredential.user;
      log('starting ......3');
      if (firebaseUser == null) {
        log('starting ......4');
        throw Exception('Google Sign-In failed.');
      }

      final userfromB = await _authService.loginWithBackend();
      log('user in provider ......${userfromB.email}');
      log('user in provider ......${userfromB.firstName}');
      log('user in provider ......${userfromB.lastName}');
      log('user in provider ......${userfromB.id}');
      log('user in provider ......${userfromB.photoUrl}');

      _user = userfromB;
      _isAuthenticated = true;
      await _storageService.saveUserData(userfromB.toJson());

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      log(_error!);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final firebaseUser = _authService.currentUser;
      // ✅ Check if token exists (was cleared during logout)
      if (firebaseUser != null) {
        await firebaseUser.reload(); // ✅ Ensure fresh metadata
      }
      final token = _storageService.getToken();
      if (firebaseUser == null || token == null) {
        _user = null;
        _isAuthenticated = false;

        return false;
      }

      // Optional: Refresh token if needed
      await firebaseUser.getIdToken(true);

      // Get full user profile from backend
      final user = await _authService.getUserProfile();
      _user = user;
      _isAuthenticated = true;
      await _storageService.saveUserData(user.toJson());

      notifyListeners();
      return true;
    } catch (e) {
      _user = null;
      _isAuthenticated = false;
      await _storageService.clearUserData();
      await _storageService.clearToken();
      notifyListeners();
      return false;
    }
  }

  // Send verification email
  Future<void> sendVerificationEmail() async {
    final fb.User? currentUser = fb.FirebaseAuth.instance.currentUser;

    if (currentUser != null && !currentUser.emailVerified) {
      await currentUser.sendEmailVerification();
    } else {
      throw Exception("User is already verified or not logged in.");
    }
  }

  // Fetch user profile from the backend
  Future<void> fetchUserProfile({bool forceRefresh = false}) async {
    if (_user != null && !forceRefresh) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.getUserProfile();

      log('user in providerfetching user ......$user');
      log('user in providerfetching user firstname ......${user.firstName}');

      _user = user;
      _isAuthenticated = true;
      await _storageService.saveUserData(user.toJson());
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(
      {String? firstName, String? lastName, File? profileImage}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? imageUrl;

      // Upload to Firebase Storage if image is present
      if (profileImage != null && _authService.currentUser != null) {
        imageUrl = await _authService.uploadProfileImage(
            profileImage, _authService.currentUser!.uid);
      }

      // Update Firebase display name and photoURL
      await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        photoURL: imageUrl,
      );

      // Sync with backend
      final profileData = <String, dynamic>{};
      if (firstName != null) profileData['firstName'] = firstName;
      if (lastName != null) profileData['lastName'] = lastName;
      if (imageUrl != null) profileData['photoUrl'] = imageUrl;

      final updatedUser = await _apiService.updateUserProfile(profileData);
      _user = updatedUser;
      await _storageService.saveUserData(updatedUser.toJson());

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user preferences
  Future<bool> updateUserPreferences(UserPreferences preferences) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update backend preferences
      final updatedUser =
          await _apiService.updateUserPreferences(preferences.toJson());

      // Update local data
      _user = updatedUser;
      await _storageService.saveUserData(updatedUser.toJson());

      // Update local theme settings
      await _storageService.setDarkMode(preferences.isDarkMode);
      await _storageService.setEnergyUnit(preferences.energyUnit);
      if (preferences.currency != null) {
        await _storageService.setCurrency(preferences.currency!);
      }
      await _storageService
          .setNotificationsEnabled(preferences.notificationsEnabled);
      if (preferences.notificationTypes != null) {
        await _storageService
            .setNotificationTypes(preferences.notificationTypes!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Toggle dark mode
  Future<bool> toggleDarkMode() async {
    if (_user == null) return false;

    final newPreferences = _user!.preferences.copyWith(
      isDarkMode: !_user!.preferences.isDarkMode,
    );

    return await updateUserPreferences(newPreferences);
  }

  // Logout
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();

      _user = null;
      _isAuthenticated = false;
      bool clearedUser = await _storageService.clearUserData();
      bool clearedToken = await _storageService.clearToken();

      if (!clearedUser || !clearedToken) {
        log('⚠️ Failed to clear user data or token');
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user energy goals
  Future<List<EnergyGoal>> getUserGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final goals = await _apiService.getUserGoals();

      // Update user with goals
      if (_user != null) {
        _user = User(
          id: _user!.id,
          email: _user!.email,
          firstName: _user!.firstName,
          lastName: _user!.lastName,
          photoUrl: _user!.photoUrl,
          isEmailVerified: _user!.isEmailVerified,
          createdAt: _user!.createdAt,
          // lastLogin: _user!.lastLogin,
          preferences: _user!.preferences,
          goals: goals,
        );

        await _storageService.saveUserData(_user!.toJson());
      }

      _isLoading = false;
      notifyListeners();
      return goals;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Create a new energy goal
  Future<bool> createGoal(Map<String, dynamic> goalData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newGoal = await _apiService.createGoal(goalData);

      // Update user's goals
      if (_user != null) {
        final currentGoals = _user!.goals ?? [];
        final updatedGoals = [...currentGoals, newGoal];

        _user = User(
          id: _user!.id,
          email: _user!.email,
          firstName: _user!.firstName,
          lastName: _user!.lastName,
          photoUrl: _user!.photoUrl,
          isEmailVerified: _user!.isEmailVerified,
          createdAt: _user!.createdAt,
          // lastLogin: _user!.lastLogin,
          preferences: _user!.preferences,
          goals: updatedGoals,
        );

        await _storageService.saveUserData(_user!.toJson());
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an energy goal
  Future<bool> updateGoal(String goalId, Map<String, dynamic> goalData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedGoal = await _apiService.updateGoal(goalId, goalData);

      // Update user's goals
      if (_user != null && _user!.goals != null) {
        final updatedGoals = _user!.goals!.map((goal) {
          if (goal.id == goalId) {
            return updatedGoal;
          }
          return goal;
        }).toList();

        _user = User(
          id: _user!.id,
          email: _user!.email,
          firstName: _user!.firstName,
          lastName: _user!.lastName,
          photoUrl: _user!.photoUrl,
          isEmailVerified: _user!.isEmailVerified,
          createdAt: _user!.createdAt,
          // lastLogin: _user!.lastLogin,
          preferences: _user!.preferences,
          goals: updatedGoals,
        );

        await _storageService.saveUserData(_user!.toJson());
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete an energy goal
  Future<bool> deleteGoal(String goalId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteGoal(goalId);

      if (success && _user != null && _user!.goals != null) {
        final updatedGoals =
            _user!.goals!.where((goal) => goal.id != goalId).toList();

        _user = User(
          id: _user!.id,
          email: _user!.email,
          firstName: _user!.firstName,
          lastName: _user!.lastName,
          photoUrl: _user!.photoUrl,
          isEmailVerified: _user!.isEmailVerified,
          createdAt: _user!.createdAt,
          // lastLogin: _user!.lastLogin,
          preferences: _user!.preferences,
          goals: updatedGoals,
        );

        await _storageService.saveUserData(_user!.toJson());
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
