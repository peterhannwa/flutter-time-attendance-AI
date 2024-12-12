class ReportData {
  final DateTime date;
  final String employeeId;
  final String employeeName;
  final String department;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status;
  final String? leaveType;
  final String? leaveReason;
  final int? leaveDuration;

  ReportData({
    required this.date,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.leaveType,
    this.leaveReason,
    this.leaveDuration,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      date: DateTime.parse(json['date']),
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      department: json['department'],
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn']) : null,
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut']) : null,
      status: json['status'],
      leaveType: json['leaveType'],
      leaveReason: json['leaveReason'],
      leaveDuration: json['leaveDuration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'employeeId': employeeId,
      'employeeName': employeeName,
      'department': department,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'status': status,
      'leaveType': leaveType,
      'leaveReason': leaveReason,
      'leaveDuration': leaveDuration,
    };
  }
}

class AttendanceStats {
  final int totalEmployees;
  final int presentToday;
  final int onLeave;
  final double attendanceRate;
  final Map<String, int> departmentStats;

  AttendanceStats({
    required this.totalEmployees,
    required this.presentToday,
    required this.onLeave,
    required this.attendanceRate,
    required this.departmentStats,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalEmployees: json['totalEmployees'],
      presentToday: json['presentToday'],
      onLeave: json['onLeave'],
      attendanceRate: json['attendanceRate'].toDouble(),
      departmentStats: Map<String, int>.from(json['departmentStats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEmployees': totalEmployees,
      'presentToday': presentToday,
      'onLeave': onLeave,
      'attendanceRate': attendanceRate,
      'departmentStats': departmentStats,
    };
  }
}
