import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../models/team_member.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late Future<List<TeamMember>> _future;

  @override
  void initState() {
    super.initState();
    _future = SupabaseService.instance.getTeamMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Anggota'), centerTitle: true),
      body: FutureBuilder<List<TeamMember>>(
        future: _future,
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
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: () => setState(
                            () => _future = SupabaseService.instance.getTeamMembers(),
                          ),
                      child: const Text('Coba Lagi')),
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
          return RefreshIndicator(
            onRefresh: () async => setState(
              () => _future = SupabaseService.instance.getTeamMembers(),
            ),
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: members.length,
              separatorBuilder: (context, i) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _MemberCard(member: members[i]),
            ),
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
        subtitle: Text('NIM: ${member.nim}'),
      ),
    );
  }
}
