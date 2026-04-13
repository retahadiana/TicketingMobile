enum UserRole {
  user,
  helpdesk,
  admin,
}

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.helpdesk:
        return 'Helpdesk';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

UserRole roleFromString(String rawRole) {
  switch (rawRole.toLowerCase()) {
    case 'helpdesk':
      return UserRole.helpdesk;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.user;
  }
}

class Profile {
  final String id;
  final String fullName;
  final UserRole role;
  final String email;

  const Profile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.email,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: (json['full_name'] as String?) ?? '-',
      role: roleFromString((json['role'] as String?) ?? 'User'),
      email: (json['email'] as String?) ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role.value,
      'email': email,
    };
  }

  Profile copyWith({
    String? id,
    String? fullName,
    UserRole? role,
    String? email,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      email: email ?? this.email,
    );
  }
}
