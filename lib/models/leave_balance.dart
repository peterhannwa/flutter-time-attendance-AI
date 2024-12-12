class LeaveBalance {
  final String employeeId;
  final int year;
  final Map<String, LeaveQuota> quotas;

  LeaveBalance({
    required this.employeeId,
    required this.year,
    required this.quotas,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    final quotasMap = json['quotas'] as Map<String, dynamic>;
    final convertedQuotas = quotasMap.map(
      (key, value) => MapEntry(key, LeaveQuota.fromJson(value)),
    );

    return LeaveBalance(
      employeeId: json['employeeId'],
      year: json['year'],
      quotas: convertedQuotas,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'year': year,
      'quotas': quotas.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  LeaveBalance copyWith({
    String? employeeId,
    int? year,
    Map<String, LeaveQuota>? quotas,
  }) {
    return LeaveBalance(
      employeeId: employeeId ?? this.employeeId,
      year: year ?? this.year,
      quotas: quotas ?? this.quotas,
    );
  }
}

class LeaveQuota {
  final double total;
  final double used;
  final double pending;
  final DateTime lastUpdated;

  LeaveQuota({
    required this.total,
    required this.used,
    required this.pending,
    required this.lastUpdated,
  });

  double get remaining => total - used - pending;

  bool get hasBalance => remaining > 0;

  factory LeaveQuota.fromJson(Map<String, dynamic> json) {
    return LeaveQuota(
      total: json['total'].toDouble(),
      used: json['used'].toDouble(),
      pending: json['pending'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'used': used,
      'pending': pending,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  LeaveQuota copyWith({
    double? total,
    double? used,
    double? pending,
    DateTime? lastUpdated,
  }) {
    return LeaveQuota(
      total: total ?? this.total,
      used: used ?? this.used,
      pending: pending ?? this.pending,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
