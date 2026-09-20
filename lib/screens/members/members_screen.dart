import 'package:flutter/material.dart';

import '../../models/team_member.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  // Data anggota manual langsung dari kode & file assets
  static const List<TeamMember> members = [
    TeamMember(
      id: 1,
      name: 'Rafi\'i Maulana', // Sesuaikan nama
      nim: '124240138', // Sesuaikan NIM
      photoUrl: 'assets/images/MR.jpeg',
    ),
    TeamMember(
      id: 2,
      name: 'Aslam Arganda', // Sesuaikan nama
      nim: '124240179', // Sesuaikan NIM
      photoUrl: 'assets/images/AA.png',
    ),
    TeamMember(
      id: 3,

      name: 'Ahmad Santosa',
      nim: '124240200', // Sesuaikan dengan NIM asli
      photoUrl: 'assets/images/AS.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Anggota'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: members.length,
        separatorBuilder: (context, i) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _MemberCard(member: members[i]),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});
  final TeamMember member;

  String get _initials {
    final parts = member.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  // Helper untuk menentukan apakah NetworkImage atau AssetImage
  ImageProvider? _getImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final imageProvider = _getImageProvider(member.photoUrl);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: imageProvider,
          backgroundColor: scheme.primaryContainer,
          child: imageProvider == null
              ? Text(
                  _initials,
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('NIM: ${member.nim}'),
      ),
    );
  }
}
