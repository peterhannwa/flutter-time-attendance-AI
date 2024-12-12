class Attendance {
  final String id;
  final String userId;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String location;
  final bool isLate;
  final String status;

  Attendance({
    required this.id,
    required this.userId,
    required this.checkIn,
    this.checkOut,
    required this.location,
    required this.isLate,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      userId: json['userId'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: json['checkOut'] != null
          ? DateTime.parse(json['checkOut'] as String)
          : null,
      location: json['location'] as String,
      isLate: json['isLate'] as bool,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'location': location,
      'isLate': isLate,
      'status': status,
    };
  }
}
