import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_env.dart';

/// Resolves the worker user id for assignment queries (centralized).
///
/// Order: authenticated user id → [AppEnv.devWorkerUserId] when non-empty.
class WorkerIdentity {
  WorkerIdentity._();

  /// True when the signed-in user is a **non-anonymous** Supabase account.
  /// Anonymous JWTs (e.g. from [signInAnonymously]) are not a worker identity.
  static bool hasAuthenticatedWorkerSession() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      if (user.isAnonymous) return false;
      return user.id.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// `auth.currentUser.id` only for **non-anonymous** sessions; otherwise
  /// [AppEnv.devWorkerUserId] if set, else `null`.
  ///
  /// Anonymous ids must not be used for `inspection_task_assignments` — they
  /// will not match `profiles.id` or admin-created assignments.
  static String? resolveWorkerUserId() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && !user.isAnonymous) {
        final uid = user.id;
        if (uid.isNotEmpty) return uid;
      }
    } catch (_) {}
    final dev = AppEnv.devWorkerUserId.trim();
    if (dev.isNotEmpty) return dev;
    return null;
  }

  /// True when using [AppEnv.devWorkerUserId] (no real worker session).
  static bool isDevWorkerUserIdActive() {
    if (hasAuthenticatedWorkerSession()) return false;
    return AppEnv.devWorkerUserId.trim().isNotEmpty;
  }

  /// Whether the current session is an anonymous Supabase user.
  static bool hasAnonymousSession() {
    try {
      return Supabase.instance.client.auth.currentUser?.isAnonymous ?? false;
    } catch (_) {
      return false;
    }
  }
}
