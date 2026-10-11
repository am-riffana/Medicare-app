import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration for MediCare.
/// Reads from `--dart-define` environment flags with secure defaults.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase project URL.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wjnpxdfltrvhucpawuaf.supabase.co',
  );

  /// Supabase publishable / anon key.
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_obBTq9mFpEzcspeQORKA_Q_ya95IDFU',
  );

  /// Checks whether the required Supabase credentials are available.
  static bool get hasCredentials =>
      url.trim().isNotEmpty && publishableKey.trim().isNotEmpty;

  /// Initializes Supabase before runApp().
  static Future<void> initialize() async {
    if (!hasCredentials) {
      const String errorMessage = '''
[MediCare Configuration Error]
Supabase credentials are missing!
''';
      debugPrint(errorMessage);
      throw StateError(errorMessage);
    }

    await Supabase.initialize(
      url: url.trim(),
      publishableKey: publishableKey.trim(),
      debug: kDebugMode,
    );
  }

  /// Global Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;
}