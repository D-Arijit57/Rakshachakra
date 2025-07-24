class User {
  final String id;
  final String username;
  final String name;
  final String email;
  final String phoneNumber;
  final DateTime lastLogin;
  final bool isBiometricEnabled;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.lastLogin,
    this.isBiometricEnabled = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      lastLogin: DateTime.parse(json['lastLogin']),
      isBiometricEnabled: json['isBiometricEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'lastLogin': lastLogin.toIso8601String(),
      'isBiometricEnabled': isBiometricEnabled,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? phoneNumber,
    DateTime? lastLogin,
    bool? isBiometricEnabled,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastLogin: lastLogin ?? this.lastLogin,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
} 