import 'package:flutter/material.dart';
import 'package:wattwise/models/user_models.dart';
import 'package:wattwise/services/api_service.dart';

class GoalsProvider extends ChangeNotifier {
  final ApiService _apiService;

  GoalsProvider(this._apiService);

  List<EnergyGoal> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EnergyGoal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all user goals from the API
  Future<void> fetchGoals() async {
    _setLoading(true);
    try {
      _goals = await _apiService.getUserGoals();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load goals: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new goal
  Future<void> addGoal(EnergyGoal newGoal) async {
    _setLoading(true);
    try {
      final createdGoal = await _apiService.createGoal(newGoal.toJson());
      _goals.add(createdGoal);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add goal: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing goal
  Future<void> updateGoal(EnergyGoal updatedGoal) async {
    _setLoading(true);
    try {
      final result = await _apiService.updateGoal(
        updatedGoal.id,
        updatedGoal.toJson(),
      );
      final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = result;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update goal: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a goal by ID
  Future<void> deleteGoal(String goalId) async {
    _setLoading(true);
    try {
      final success = await _apiService.deleteGoal(goalId);
      if (success) {
        _goals.removeWhere((g) => g.id == goalId);
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to delete goal: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Private helper to manage loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Optional: Get a goal by ID (if needed in future)
  EnergyGoal? getGoalById(String id) {
    return _goals.firstWhere((g) => g.id == id);
  }
}
