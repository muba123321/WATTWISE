class User {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime createdAt;
  // final DateTime? lastLogin;
  final UserPreferences preferences;
  final List<EnergyGoal>? goals;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    required this.isEmailVerified,
    // this.lastLogin,
    required this.createdAt,
    required this.preferences,
    this.goals,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      photoUrl: json['photoUrl'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      // lastLogin:
      // json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      goals: json['goals'] != null
          ? (json['goals'] as List)
              .map((goal) => EnergyGoal.fromJson(goal))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstname': firstName,
      'lastname': lastName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      // 'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences.toJson(),
      'goals': goals?.map((goal) => goal.toJson()).toList(),
    };
  }

  String getInitials() {
    final f = (firstName?.isNotEmpty ?? false) ? firstName!.trim()[0] : '';
    final l = (lastName?.isNotEmpty ?? false) ? lastName!.trim()[0] : '';
    final initials = (f + l).toUpperCase();
    return initials.isNotEmpty ? initials : 'User';
  }
}

class UserPreferences {
  final bool isDarkMode;
  final String? currency;
  final String energyUnit; // kWh, MJ, etc.
  final bool notificationsEnabled;
  final List<String>? notificationTypes;

  UserPreferences({
    this.isDarkMode = false,
    this.currency,
    this.energyUnit = 'kWh',
    this.notificationsEnabled = true,
    this.notificationTypes,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isDarkMode: json['isDarkMode'] ?? false,
      currency: json['currency'],
      energyUnit: json['energyUnit'] ?? 'kWh',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      notificationTypes: json['notificationTypes'] != null
          ? List<String>.from(json['notificationTypes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'currency': currency,
      'energyUnit': energyUnit,
      'notificationsEnabled': notificationsEnabled,
      'notificationTypes': notificationTypes,
    };
  }

  UserPreferences copyWith({
    bool? isDarkMode,
    String? currency,
    String? energyUnit,
    bool? notificationsEnabled,
    List<String>? notificationTypes,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currency: currency ?? this.currency,
      energyUnit: energyUnit ?? this.energyUnit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTypes: notificationTypes ?? this.notificationTypes,
    );
  }
}

class EnergyGoal {
  final String id;
  final String title;
  final String description;
  final double targetValue;
  final String unit;
  final DateTime startDate;
  final DateTime endDate;
  final GoalType type;
  final GoalStatus status;
  final double currentValue;

  EnergyGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.unit,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.status,
    required this.currentValue,
  });

  factory EnergyGoal.fromJson(Map<String, dynamic> json) {
    return EnergyGoal(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      targetValue: json['targetValue']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'kWh',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(Duration(days: 30)),
      type: _getGoalType(json['type']),
      status: _getGoalStatus(json['status']),
      currentValue: json['currentValue']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'unit': unit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'currentValue': currentValue,
    };
  }

  static GoalType _getGoalType(String? type) {
    switch (type) {
      case 'reduction':
        return GoalType.reduction;
      case 'limit':
        return GoalType.limit;
      default:
        return GoalType.reduction;
    }
  }

  static GoalStatus _getGoalStatus(String? status) {
    switch (status) {
      case 'active':
        return GoalStatus.active;
      case 'completed':
        return GoalStatus.completed;
      case 'failed':
        return GoalStatus.failed;
      default:
        return GoalStatus.active;
    }
  }

  double get progressPercentage {
    if (type == GoalType.reduction) {
      return (targetValue > 0) ? (currentValue / targetValue) * 100 : 0;
    } else {
      // For limit goals, progress is inverse (lower is better)
      return (targetValue > 0)
          ? ((targetValue - currentValue) / targetValue) * 100
          : 0;
    }
  }
}

enum GoalType {
  reduction, // Reduce energy usage by a specific amount
  limit // Keep energy usage below a specific amount
}

enum GoalStatus { active, completed, failed }
