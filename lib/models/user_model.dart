class UserModel {
  final String id;
  final String name;
  final String email;
  final String status;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as String,
        name: j['name'] as String,
        email: j['email'] as String,
        status: j['status'] as String,
        role: j['role'] as String,
      );

  UserModel copyWith({String? name, String? email, String? status, String? role}) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        status: status ?? this.status,
        role: role ?? this.role,
      );
}
