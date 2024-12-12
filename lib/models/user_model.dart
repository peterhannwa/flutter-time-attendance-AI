class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String profileImage;
  final Map<String, double> leaveBalance;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    this.profileImage = '',
    required this.leaveBalance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      profileImage: json['profileImage'] as String? ?? '',
      leaveBalance: Map<String, double>.from(json['leaveBalance'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'profileImage': profileImage,
      'leaveBalance': leaveBalance,
    };
  }
}
