import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseState {
  static bool get isInitialized {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }
}
