import 'package:uuid/uuid.dart';

enum LeaveType {
  annual,
  sick,
  personal,
  maternity,
  paternity,
  unpaid,
  other
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled
}

class LeaveRequest {
  final String id;
  final String employeeId;
  final String employeeName;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final String? approverNote;
  final String? approverId;
  final DateTime requestDate;
  final List<String>? attachments;

  LeaveRequest({
    String? id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.approverNote,
    this.approverId,
    DateTime? requestDate,
    this.attachments,
  }) : id = id ?? const Uuid().v4(),
       requestDate = requestDate ?? DateTime.now();

  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;
  bool get isRejected => status == LeaveStatus.rejected;
  bool get isCancelled => status == LeaveStatus.cancelled;

  LeaveRequest copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    LeaveType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveStatus? status,
    String? approverNote,
    String? approverId,
    DateTime? requestDate,
    List<String>? attachments,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approverNote: approverNote ?? this.approverNote,
      approverId: approverId ?? this.approverId,
      requestDate: requestDate ?? this.requestDate,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'type': type.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'status': status.toString(),
      'approverNote': approverNote,
      'approverId': approverId,
      'requestDate': requestDate.toIso8601String(),
      'attachments': attachments,
    };
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      employeeId: json['employeeId'],
      employeeName: json['employeeName'],
      type: LeaveType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason'],
      status: LeaveStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      approverNote: json['approverNote'],
      approverId: json['approverId'],
      requestDate: DateTime.parse(json['requestDate']),
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaveRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
