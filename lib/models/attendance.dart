import 'package:uuid/uuid.dart';

enum AttendanceStatus {
  present,
  absent,
  late,
  halfDay,
  onLeave,
  workFromHome,
  holiday
}

class Attendance {
  final String id;
  final String employeeId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final AttendanceStatus status;
  final String? notes;
  final String? location;
  final Map<String, dynamic>? metadata;
  final bool isModified;
  final String? modifiedBy;
  final DateTime? modifiedAt;

  Attendance({
    String? id,
    required this.employeeId,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.notes,
    this.location,
    this.metadata,
    this.isModified = false,
    this.modifiedBy,
    this.modifiedAt,
  }) : id = id ?? const Uuid().v4();

  Duration? get workDuration {
    if (checkIn == null || checkOut == null) return null;
    return checkOut!.difference(checkIn!);
  }

  bool get isLate {
    if (checkIn == null) return false;
    final expectedCheckIn = DateTime(
      checkIn!.year,
      checkIn!.month,
      checkIn!.day,
      9, // 9 AM
      0,
    );
    return checkIn!.isAfter(expectedCheckIn);
  }

  bool get isEarlyCheckout {
    if (checkOut == null) return false;
    final expectedCheckOut = DateTime(
      checkOut!.year,
      checkOut!.month,
      checkOut!.day,
      17, // 5 PM
      0,
    );
    return checkOut!.isBefore(expectedCheckOut);
  }

  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
    AttendanceStatus? status,
    String? notes,
    String? location,
    Map<String, dynamic>? metadata,
    bool? isModified,
    String? modifiedBy,
    DateTime? modifiedAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      isModified: isModified ?? this.isModified,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'status': status.toString(),
      'notes': notes,
      'location': location,
      'metadata': metadata,
      'isModified': isModified,
      'modifiedBy': modifiedBy,
      'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      employeeId: json['employeeId'],
      date: DateTime.parse(json['date']),
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn']) : null,
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut']) : null,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      notes: json['notes'],
      location: json['location'],
      metadata: json['metadata'],
      isModified: json['isModified'],
      modifiedBy: json['modifiedBy'],
      modifiedAt:
          json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
