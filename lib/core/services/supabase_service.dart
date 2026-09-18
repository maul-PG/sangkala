import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event.dart';
import '../../models/event_budget.dart';
import '../../models/profile.dart';
import '../../models/team_member.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String nim,
    required String role,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final userId = response.user?.id;
    if (userId == null) throw Exception('Registrasi gagal: user ID tidak ditemukan.');

    await _client.from(AppConstants.tableProfiles).insert({
      'id': userId,
      'name': name,
      'nim': nim,
      'role': role,
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Profile?> getProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final data = await _client
        .from(AppConstants.tableProfiles)
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromJson(data);
  }

  // ── Events ────────────────────────────────────────────────────────────────

  Future<List<Event>> getEvents() async {
    final data = await _client
        .from(AppConstants.tableEvents)
        .select()
        .order('event_date', ascending: true);
    return (data as List).map((e) => Event.fromJson(e)).toList();
  }

  Future<void> insertEvent(Event event) async {
    final uid = currentUser?.id;
    if (uid == null) throw Exception('User belum login.');
    await _client.from(AppConstants.tableEvents).insert({
      ...event.toJson(),
      'user_id': uid,
    });
  }

  Future<void> updateEvent(Event event) async {
    await _client
        .from(AppConstants.tableEvents)
        .update(event.toJson())
        .eq('id', event.id);
  }

  Future<void> deleteEvent(String id) async {
    await _client.from(AppConstants.tableEvents).delete().eq('id', id);
  }

  // ── Event Budgets ─────────────────────────────────────────────────────────

  Future<List<EventBudget>> getBudgets(String eventId) async {
    final data = await _client
        .from(AppConstants.tableEventBudgets)
        .select()
        .eq('event_id', eventId)
        .order('created_at', ascending: true);
    return (data as List).map((e) => EventBudget.fromJson(e)).toList();
  }

  Future<void> insertBudget(EventBudget budget) async {
    await _client.from(AppConstants.tableEventBudgets).insert(budget.toJson());
  }

  Future<void> updateBudget(EventBudget budget) async {
    await _client
        .from(AppConstants.tableEventBudgets)
        .update(budget.toJson())
        .eq('id', budget.id);
  }

  Future<void> deleteBudget(String id) async {
    await _client.from(AppConstants.tableEventBudgets).delete().eq('id', id);
  }

  // ── Team Members ──────────────────────────────────────────────────────────

  Future<List<TeamMember>> getTeamMembers() async {
    final data = await _client
        .from(AppConstants.tableTeamMembers)
        .select()
        .order('id', ascending: true);
    return (data as List).map((e) => TeamMember.fromJson(e)).toList();
  }
}
