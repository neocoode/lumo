class User {
  final String id;
  final String email;
  final String name;
  final String? photo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final bool verified;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photo,
    required this.createdAt,
    this.updatedAt,
    required this.isActive,
    required this.verified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isActive: json['isActive'] ?? true,
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo': photo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'verified': verified,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photo,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? verified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      verified: verified ?? this.verified,
    );
  }
}

class Session {
  final String id;
  final String email; // Usar email como chave primária
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final DateTime createdAt;
  final bool isActive;
  final String? deviceInfo;

  Session({
    required this.id,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.createdAt,
    required this.isActive,
    this.deviceInfo,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresAt: DateTime.parse(json['expiresAt'] ??
          DateTime.now().add(Duration(hours: 1)).toIso8601String()),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      deviceInfo: json['deviceInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'deviceInfo': deviceInfo,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Session copyWith({
    String? id,
    String? email,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    DateTime? createdAt,
    bool? isActive,
    String? deviceInfo,
  }) {
    return Session(
      id: id ?? this.id,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String? confirmPassword;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      if (confirmPassword != null) 'confirmPassword': confirmPassword,
    };
  }
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class AuthResponse {
  final User user;
  final Session session;
  final String message;

  AuthResponse({
    required this.user,
    required this.session,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] ?? {}),
      session: Session.fromJson(json['session'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}
