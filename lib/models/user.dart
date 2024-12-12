class User {
  final String id;
  final String name;
  final String email;
  final String? employeeId;
  final String? department;
  final String? role;
  final String? phone;
  final DateTime? joinDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.employeeId,
    this.department,
    this.role,
    this.phone,
    this.joinDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      employeeId: json['employeeId'] as String?,
      department: json['department'] as String?,
      role: json['role'] as String?,
      phone: json['phone'] as String?,
      joinDate: json['joinDate'] != null 
          ? DateTime.parse(json['joinDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'employeeId': employeeId,
      'department': department,
      'role': role,
      'phone': phone,
      'joinDate': joinDate?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? employeeId,
    String? department,
    String? role,
    String? phone,
    DateTime? joinDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      department: department ?? this.department,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}
