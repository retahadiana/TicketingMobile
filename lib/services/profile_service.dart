import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileService {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<Profile?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final Map<String, dynamic>? data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      final generatedProfile = Profile(
        id: user.id,
        fullName: (user.userMetadata?['full_name'] as String?) ?? '-',
        role: roleFromString((user.userMetadata?['role'] as String?) ?? 'User'),
        email: user.email ?? '-',
      );

      await _supabase.from('profiles').upsert({
        'id': generatedProfile.id,
        'full_name': generatedProfile.fullName,
        'role': generatedProfile.role.value,
        'email': generatedProfile.email,
      });

      return generatedProfile;
    }

    final profile = Profile.fromJson(data);
    return profile.copyWith(email: user.email ?? profile.email);
  }

  Future<void> updateProfile({required String fullName}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('profiles').update({'full_name': fullName}).eq('id', user.id);
  }

  Future<List<Profile>> listAllProfilesForAdmin() async {
    final data = await _supabase
        .from('profiles')
        .select()
        .order('full_name', ascending: true);

    return (data as List<dynamic>)
        .map((row) => Profile.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> assignUserRole({
    required String targetUserId,
    required UserRole role,
  }) async {
    await _supabase.rpc(
      'assign_user_role',
      params: <String, dynamic>{
        'target_user_id': targetUserId,
        'new_role': role.value,
      },
    );
  }
}
