import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Einfache lokale Konten-Verwaltung (Registrierung/Anmeldung) rein auf dem
/// Gerät gespeichert. Für ein echtes Produkt würde hier ein Backend
/// angebunden, dieses Studio läuft aber vollständig offline.
class AuthService {
  static const _usersKey = 'fs_users_v1';
  static const _sessionKey = 'fs_session_v1';

  Future<Map<String, String>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as String));
  }

  Future<void> _saveUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  String _hash(String input) {
    // Simpler, deterministischer Hash für die lokale Demo-Anmeldung.
    var hash = 0;
    for (final unit in input.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash.toString();
  }

  Future<String?> register(String email, String password) async {
    final users = await _loadUsers();
    final key = email.trim().toLowerCase();
    if (key.isEmpty || password.isEmpty) return 'E-Mail und Passwort erforderlich';
    if (users.containsKey(key)) return 'Konto existiert bereits';
    users[key] = _hash(password);
    await _saveUsers(users);
    await _setSession(key);
    return null;
  }

  Future<String?> login(String email, String password) async {
    final users = await _loadUsers();
    final key = email.trim().toLowerCase();
    if (!users.containsKey(key)) return 'Konto nicht gefunden';
    if (users[key] != _hash(password)) return 'Falsches Passwort';
    await _setSession(key);
    return null;
  }

  Future<void> _setSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<String?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }
}
