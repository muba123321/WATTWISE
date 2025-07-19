class EnergyConsumption {
  final String id;
  final String userId;
  final DateTime date;
  final double amount; // in kWh or user's preferred unit
  final String unit; // kWh, MJ, etc.
  final ConsumptionType type;
  final ConsumptionSource source;
  final double? cost;
  final String? currency;

  EnergyConsumption({
    required this.id,
    required this.userId,
    required this.date,
    required this.amount,
    required this.unit,
    required this.type,
    required this.source,
    this.cost,
    this.currency,
  });

  factory EnergyConsumption.fromJson(Map<String, dynamic> json) {
    return EnergyConsumption(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      amount: json['amount']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'kWh',
      type: _getConsumptionType(json['type']),
      source: _getConsumptionSource(json['source']),
      cost: json['cost']?.toDouble(),
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'amount': amount,
      'unit': unit,
      'type': type.toString().split('.').last,
      'source': source.toString().split('.').last,
      'cost': cost,
      'currency': currency,
    };
  }

  static ConsumptionType _getConsumptionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'electricity':
        return ConsumptionType.electricity;
      case 'gas':
        return ConsumptionType.gas;
      case 'water':
        return ConsumptionType.water;
      case 'other':
        return ConsumptionType.other;
      default:
        return ConsumptionType.electricity;
    }
  }

  static ConsumptionSource _getConsumptionSource(String? source) {
    switch (source?.toLowerCase()) {
      case 'meter_reading':
        return ConsumptionSource.meterReading;
      case 'bill':
        return ConsumptionSource.bill;
      case 'appliance_calculation':
        return ConsumptionSource.applianceCalculation;
      case 'estimate':
        return ConsumptionSource.estimate;
      default:
        return ConsumptionSource.meterReading;
    }
  }
}

class ConsumptionPeriod {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalConsumption;
  final String unit;
  final double? totalCost;
  final String? currency;
  final Map<String, dynamic>? breakdown;
  final double? averageDaily;
  final double? averageHourly;

  ConsumptionPeriod({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalConsumption,
    required this.unit,
    this.totalCost,
    this.currency,
    this.breakdown,
    this.averageDaily,
    this.averageHourly,
  });

  factory ConsumptionPeriod.fromJson(Map<String, dynamic> json) {
    return ConsumptionPeriod(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now().subtract(Duration(days: 30)),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      totalConsumption: json['totalConsumption']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'kWh',
      totalCost: json['totalCost']?.toDouble(),
      currency: json['currency'],
      breakdown: json['breakdown'],
      averageDaily: json['averageDaily']?.toDouble(),
      averageHourly: json['averageHourly']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalConsumption': totalConsumption,
      'unit': unit,
      'totalCost': totalCost,
      'currency': currency,
      'breakdown': breakdown,
      'averageDaily': averageDaily,
      'averageHourly': averageHourly,
    };
  }

  int get durationDays {
    return endDate.difference(startDate).inDays;
  }
}

enum ConsumptionType { electricity, gas, water, other }

enum ConsumptionSource { meterReading, bill, applianceCalculation, estimate }
