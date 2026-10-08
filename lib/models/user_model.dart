enum UserRole {
  citizen,
  admin
}

class UserModel {
  final String id;
  final String name;
  final String username;
  final String phone;
  final int jalPoints;
  final int ecoPoints;
  final UserRole role;
  final int wardNumber;

  UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.phone,
    this.jalPoints = 0,
    this.ecoPoints = 0,
    this.role = UserRole.citizen,
    this.wardNumber = 4,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'phone': phone,
    'jalPoints': jalPoints,
    'ecoPoints': ecoPoints,
    'role': role.index,
    'wardNumber': wardNumber,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    name: json['name'],
    username: json['username'],
    phone: json['phone'],
    jalPoints: json['jalPoints'] ?? 0,
    ecoPoints: json['ecoPoints'] ?? 0,
    role: UserRole.values[json['role'] ?? 0],
    wardNumber: json['wardNumber'] ?? 4,
  );
}
