class TeamMember {
  final int id;
  final String name;
  final String nim;
  final String? photoUrl;

  const TeamMember({
    required this.id,
    required this.name,
    required this.nim,
    this.photoUrl,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        nim: json['nim'] as String? ?? '',
        photoUrl: json['photo_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nim': nim,
        'photo_url': photoUrl,
      };
}
