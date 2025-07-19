class MeterReading {
  final String id;
  final String userId;
  final double reading;
  final DateTime timestamp;
  final String readingType; // electricity, gas, water, etc.
  final ReadingSource source;
  final String? notes;
  final String? imageUrl;
  final MeterReadingStatus status;
  final BillingCycle? billingCycle;

  MeterReading({
    required this.id,
    required this.userId,
    required this.reading,
    required this.timestamp,
    required this.readingType,
    required this.source,
    this.notes,
    this.imageUrl,
    required this.status,
    this.billingCycle,
  });

  factory MeterReading.fromJson(Map<String, dynamic> json) {
    return MeterReading(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      reading: json['reading']?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      readingType: json['readingType'] ?? 'electricity',
      source: _getReadingSource(json['source']),
      notes: json['notes'],
      imageUrl: json['imageUrl'],
      status: _getReadingStatus(json['status']),
      billingCycle: json['billingCycle'] != null
          ? BillingCycle.fromJson(json['billingCycle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'reading': reading,
      'timestamp': timestamp.toIso8601String(),
      'readingType': readingType,
      'source': source.toString().split('.').last,
      'notes': notes,
      'imageUrl': imageUrl,
      'status': status.toString().split('.').last,
      'billingCycle': billingCycle?.toJson(),
    };
  }

  static ReadingSource _getReadingSource(String? source) {
    switch (source?.toLowerCase()) {
      case 'manual':
        return ReadingSource.manual;
      case 'bill':
        return ReadingSource.bill;
      case 'camera':
        return ReadingSource.camera;
      case 'smart_meter':
        return ReadingSource.smartMeter;
      default:
        return ReadingSource.manual;
    }
  }

  static MeterReadingStatus _getReadingStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return MeterReadingStatus.verified;
      case 'unverified':
        return MeterReadingStatus.unverified;
      case 'estimated':
        return MeterReadingStatus.estimated;
      case 'error':
        return MeterReadingStatus.error;
      default:
        return MeterReadingStatus.unverified;
    }
  }
}

class BillingCycle {
  final DateTime startDate;
  final DateTime endDate;
  final double amount; // Billing amount in user's currency
  final String? currency;
  final double rate; // Cost per unit (kWh, etc.)

  BillingCycle({
    required this.startDate,
    required this.endDate,
    required this.amount,
    this.currency,
    required this.rate,
  });

  factory BillingCycle.fromJson(Map<String, dynamic> json) {
    return BillingCycle(
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now().subtract(Duration(days: 30)),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),
      amount: json['amount']?.toDouble() ?? 0.0,
      currency: json['currency'],
      rate: json['rate']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'rate': rate,
    };
  }
}

enum ReadingSource { manual, bill, camera, smartMeter }

enum MeterReadingStatus { verified, unverified, estimated, error }
