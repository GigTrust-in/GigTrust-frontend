import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/role.dart';

/// Controls feature flags / model selection for the app.
///
/// This provider persists the "Claude Sonnet 3.5" flag to
/// `SharedPreferences` so the toggle survives app restarts.
class ModelProvider extends ChangeNotifier {
  static const _prefKey = 'claude_sonnet_for_clients';

  
  bool _initialized = false;

  ModelProvider() {
    _loadFromPrefs();
  }

  /// Whether Claude Sonnet 3.5 is enabled globally for client-role users.
  bool get claudeSonnetForClients => _claudeSonnetForClients;

  /// Returns true when the provider finished loading persisted values.
  bool get initialized => _initialized;

  /// Convenience: check by role
  bool isEnabledForRole(Role? role) {
    if (role == null) return false;
    if (role == Role.client) return _claudeSonnetForClients;
    return false;
  }

  /// Set the flag, persist it and notify listeners.
  Future<void> setClaudeSonnetForClients(bool enabled) async {
    if (_claudeSonnetForClients == enabled && _initialized) return;
    _claudeSonnetForClients = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, enabled);
    } catch (_) {
      // Ignore persistence errors; UI still reflects in-memory state.
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getBool(_prefKey);
      if (stored != null) _claudeSonnetForClients = stored;
    } catch (_) {
      // Ignore errors and keep defaults
    }
    _initialized = true;
    notifyListeners();
  }
}
