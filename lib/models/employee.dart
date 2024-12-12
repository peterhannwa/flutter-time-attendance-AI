class Employee {
  final String id;
  final String name;
  final String email;
  final String department;
  final String position;
  final String? managerId;
  final String? phoneNumber;
  final String? address;
  final DateTime joiningDate;
  final String password; // In production, store hashed passwords only
  final List<String> roles;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    this.managerId,
    this.phoneNumber,
    this.address,
    required this.joiningDate,
    required this.password,
    required this.roles,
    this.isActive = true,
  });

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    String? position,
    String? managerId,
    String? phoneNumber,
    String? address,
    DateTime? joiningDate,
    String? password,
    List<String>? roles,
    bool? isActive,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      position: position ?? this.position,
      managerId: managerId ?? this.managerId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      joiningDate: joiningDate ?? this.joiningDate,
      password: password ?? this.password,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      department: json['department'],
      position: json['position'],
      managerId: json['managerId'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      joiningDate: DateTime.parse(json['joiningDate']),
      password: json['password'],
      roles: List<String>.from(json['roles']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'position': position,
      'managerId': managerId,
      'phoneNumber': phoneNumber,
      'address': address,
      'joiningDate': joiningDate.toIso8601String(),
      'password': password,
      'roles': roles,
      'isActive': isActive,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
