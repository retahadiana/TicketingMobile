import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _supabase => Supabase.instance.client;

  // FR-001: Login
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // FR-003: Register
  Future<AuthResponse> signUp(String email, String password, String name, String role) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'role': role},
    );

    final signedUpUser = response.user;                                                                               
    // When email confirmation is enabled, Supabase may return user without session.
    // In that case, inserting into profiles from client-side will fail RLS (Unauthorized).
    final hasSession = response.session != null;
    if (signedUpUser != null && hasSession) {
      await _supabase.from('profiles').upsert({
        'id': signedUpUser.id,
        'full_name': name,
        'role': role,
        'email': email,
      });
    }

    return response;
  }

  // FR-004: Reset Password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // FR-002: Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}