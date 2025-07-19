enum ApplianceEfficiency { high, medium, low }

class Appliance {
  final String id;
  final String name;
  final String type;
  final String? brand;
  final String? model;
  final double powerRatingWatts; // renamed for clarity
  final double standbyPowerWatts; // defaults to 0.0
  final bool isSmartDevice;
  final String? imageUrl;
  final double dailyUsageHours;
  final ApplianceEfficiency efficiency;
  final DateTime addedDate;
  final String roomLocation;
  final Map<String, dynamic>? customFields;

  Appliance({
    required this.id,
    required this.name,
    required this.type,
    this.brand,
    this.model,
    required this.powerRatingWatts,
    this.standbyPowerWatts = 0.0,
    required this.isSmartDevice,
    this.imageUrl,
    required this.dailyUsageHours,
    required this.efficiency,
    required this.addedDate,
    required this.roomLocation,
    this.customFields,
  });

  factory Appliance.fromJson(Map<String, dynamic> json) {
    return Appliance(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      brand: json['brand'],
      model: json['model'],
      powerRatingWatts: json['powerRating']?.toDouble() ?? 0.0,
      standbyPowerWatts: json['standbyPower']?.toDouble() ?? 0.0,
      isSmartDevice: json['isSmartDevice'] ?? false,
      imageUrl: json['imageUrl'],
      dailyUsageHours: json['dailyUsageHours']?.toDouble() ?? 0.0,
      efficiency: _getEfficiencyFromString(json['efficiency']),
      addedDate: json['addedDate'] != null
          ? DateTime.tryParse(json['addedDate']) ?? DateTime.now()
          : DateTime.now(),
      roomLocation: json['roomLocation'] ?? 'Unknown',
      customFields: json['customFields'],
    );
  }

  Appliance copyWith({
    String? id,
    String? name,
    String? type,
    String? brand,
    String? model,
    double? powerRatingWatts,
    double? standbyPowerWatts,
    bool? isSmartDevice,
    String? imageUrl,
    double? dailyUsageHours,
    ApplianceEfficiency? efficiency,
    DateTime? addedDate,
    String? roomLocation,
    Map<String, dynamic>? customFields,
  }) {
    return Appliance(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      powerRatingWatts: powerRatingWatts ?? this.powerRatingWatts,
      standbyPowerWatts: standbyPowerWatts ?? this.standbyPowerWatts,
      isSmartDevice: isSmartDevice ?? this.isSmartDevice,
      imageUrl: imageUrl ?? this.imageUrl,
      dailyUsageHours: dailyUsageHours ?? this.dailyUsageHours,
      efficiency: efficiency ?? this.efficiency,
      addedDate: addedDate ?? this.addedDate,
      roomLocation: roomLocation ?? this.roomLocation,
      customFields: customFields ?? this.customFields,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'brand': brand,
      'model': model,
      'powerRating': powerRatingWatts,
      'standbyPower': standbyPowerWatts,
      'isSmartDevice': isSmartDevice,
      'imageUrl': imageUrl,
      'dailyUsageHours': dailyUsageHours,
      'efficiency': efficiency.name,
      'addedDate': addedDate.toIso8601String(),
      'roomLocation': roomLocation,
      'customFields': customFields,
    };
  }

  double calculateDailyConsumption() {
    return (powerRatingWatts * dailyUsageHours) / 1000;
  }

  double calculateMonthlyConsumption() {
    return calculateDailyConsumption() * 30;
  }

  double calculateAnnualConsumption() {
    return calculateDailyConsumption() * 365;
  }

  double calculateStandbyConsumption() {
    double standbyHours = 24 - dailyUsageHours;
    if (standbyHours < 0) standbyHours = 0;
    return (standbyPowerWatts * standbyHours * 30) / 1000;
  }

  static ApplianceEfficiency _getEfficiencyFromString(String? efficiency) {
    switch ((efficiency ?? 'medium').toLowerCase()) {
      case 'high':
        return ApplianceEfficiency.high;
      case 'low':
        return ApplianceEfficiency.low;
      case 'medium':
      default:
        return ApplianceEfficiency.medium;
    }
  }
}

class StandardAppliance {
  final String id;
  final String name;
  final String type;
  final double averagePowerRating;
  final double? standbyPower;
  final String iconName;
  final Map<String, dynamic>? specifications;

  StandardAppliance({
    required this.id,
    required this.name,
    required this.type,
    required this.averagePowerRating,
    this.standbyPower,
    required this.iconName,
    this.specifications,
  });

  factory StandardAppliance.fromJson(Map<String, dynamic> json) {
    return StandardAppliance(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      averagePowerRating: json['averagePowerRating']?.toDouble() ?? 0.0,
      standbyPower: json['standbyPower']?.toDouble(),
      iconName: json['iconName'] ?? 'device',
      specifications: json['specifications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'type': type,
      'averagePowerRating': averagePowerRating,
      'standbyPower': standbyPower,
      'iconName': iconName,
      'specifications': specifications,
    };
  }
}
