import '../enums/UserRole.dart';

class UserModel {
  static String table = 'users';
  static String columnUserId = 'user_id';
  static String columnUsername = 'username';
  static String columnFullName = 'fullname';
  static String columnPassword = 'password';
  static String columnRole = 'role';
  static String columnCreatedAt = 'created_at';
  static String columnModifiedAt = 'modified_at';

  final int? userId;
  final String username;
  final String fullname;
  final String password;
  final UserRole role;
  final String? createdAt;
  final String? modifiedAt;

  UserModel({
    this.userId,
    required this.username,
    required this.fullname,
    required this.password,
    required this.role,
    this.createdAt,
    this.modifiedAt,
  });

  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      columnUsername: username,
      columnFullName: fullname,
      columnPassword: password,
      columnRole: role.name,
    };

    if (userId != null) {
      map[columnUserId] = userId;
    }

    if (createdAt != null) {
      map[columnCreatedAt] = createdAt;
    }

    if (modifiedAt != null) {
      map[columnModifiedAt] = modifiedAt;
    }

    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map[columnUserId],
      username: map[columnUsername],
      fullname: map[columnFullName],
      password: map[columnPassword],
      role: UserRole.values.firstWhere(
            (e) => e.name == map[columnRole],
      ),
      createdAt: map[columnCreatedAt],
      modifiedAt: map[columnModifiedAt],
    );
  }
}