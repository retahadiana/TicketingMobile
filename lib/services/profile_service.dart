import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<Profile?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final Map<String, dynamic>? data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (data == null) {
      return Profile(
        id: user.id,
        fullName: (user.userMetadata?['full_name'] as String?) ?? '-',
        role: roleFromString((user.userMetadata?['role'] as String?) ?? 'User'),
        email: user.email ?? '-',
      );
    }

    final profile = Profile.fromJson(data);
    return profile.copyWith(email: user.email ?? profile.email);
  }

  Future<void> updateProfile({required String fullName}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('profiles').update({'full_name': fullName}).eq('id', user.id);
  }
}
