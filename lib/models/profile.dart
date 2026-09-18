class Profile {
  final String id;
  final String name;
  final String nim;
  final String role;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.name,
    required this.nim,
    required this.role,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        name: json['name'] as String,
        nim: json['nim'] as String,
        role: json['role'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nim': nim,
        'role': role,
      };
}
