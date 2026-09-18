import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../models/team_member.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Anggota'), centerTitle: true),
      body: FutureBuilder<List<TeamMember>>(
        future: SupabaseService.instance.getTeamMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Gagal memuat data: ${snapshot.error}',
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }
          final members = snapshot.data ?? [];
          if (members.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group_off_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Belum ada data anggota.'),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: members.length,
            separatorBuilder: (context, i) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _MemberCard(member: members[i]),
          );
        },
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage:
              member.photoUrl != null ? NetworkImage(member.photoUrl!) : null,
          backgroundColor: scheme.primaryContainer,
          child: member.photoUrl == null
              ? Text(_initials,
                  style: TextStyle(
                      color: scheme.primary, fontWeight: FontWeight.bold))
              : null,
        ),
        title: Text(member.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NIM: ${member.nim}'),
            Text(member.roleInApp,
                style: TextStyle(color: scheme.primary, fontSize: 12)),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
