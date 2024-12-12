enum LeaveStatus { pending, approved, rejected }
enum LeaveType { annual, sick, personal, other }

class LeaveRequest {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final LeaveType type;
  final String reason;
  final LeaveStatus status;
  final String? documentUrl;
  final DateTime requestDate;
  final String? approverComment;

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.reason,
    required this.status,
    this.documentUrl,
    required this.requestDate,
    this.approverComment,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      type: LeaveType.values.firstWhere(
          (e) => e.toString() == 'LeaveType.${json['type']}'),
      reason: json['reason'] as String,
      status: LeaveStatus.values.firstWhere(
          (e) => e.toString() == 'LeaveStatus.${json['status']}'),
      documentUrl: json['documentUrl'] as String?,
      requestDate: DateTime.parse(json['requestDate'] as String),
      approverComment: json['approverComment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type.toString().split('.').last,
      'reason': reason,
      'status': status.toString().split('.').last,
      'documentUrl': documentUrl,
      'requestDate': requestDate.toIso8601String(),
      'approverComment': approverComment,
    };
  }
}
