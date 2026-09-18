class TeamMember {
  final int id;
  final String nim;
  final String name;
  final String roleInApp;
  final String? photoUrl;

  const TeamMember({
    required this.id,
    required this.nim,
    required this.name,
    required this.roleInApp,
    this.photoUrl,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: (json['id'] as num).toInt(),
        nim: json['nim'] as String,
        name: json['name'] as String,
        roleInApp: json['role_in_app'] as String,
        photoUrl: json['photo_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nim': nim,
        'name': name,
        'role_in_app': roleInApp,
        'photo_url': photoUrl,
      };
}
