import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:letscheck/background_service.dart' as background_service;

import 'settings_state.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(const SettingsState(
          connections: [],
          currentAlias: '',
          isLightMode: false,
          refreshSeconds: 60,
        )) {
    _loadState();
  }

  void _loadState() {
    final stateJson = _prefs.getString('settings');
    if (stateJson != null) {
      final stateMap = jsonDecode(stateJson) as Map<String, dynamic>;
      try {
        state = SettingsState.fromJson(stateMap);
        background_service.sendSettings(state);
      } catch (e) {
        // Ignore.
      }
    }
  }

  void _saveState() {
    _prefs.setString('settings', jsonEncode(state.toJson()));

    background_service.sendSettings(state);
  }

  Future<void> setTheme(bool lightMode) async {
    state = state.copyWith(isLightMode: lightMode);
    _saveState();
  }

  Future<void> updateRefreshSeconds(int seconds) async {
    state = state.copyWith(
      refreshSeconds: seconds,
    );
    _saveState();
  }

  bool hasConnection(String alias) =>
      state.connections.any((c) => c.alias == alias);

  Future<void> addConnection(SettingsStateConnection connection) async {
    if (hasConnection(connection.alias)) {
      throw StateError(
          'Connection with alias ${connection.alias} already exists');
    }

    state = state.copyWith(
      connections: List.from(state.connections)..add(connection),
    );
    _saveState();
  }

  Future<void> updateConnection(SettingsStateConnection connection) async {
    if (!hasConnection(connection.alias)) return;

    final connections = List<SettingsStateConnection>.from(state.connections)
      ..removeWhere((c) => c.alias == connection.alias)
      ..add(connection);
    state = state.copyWith(connections: connections);
    _saveState();
  }

  Future<void> deleteConnection(SettingsStateConnection connection) async {
    if (!hasConnection(connection.alias)) return;

    final connections = List<SettingsStateConnection>.from(state.connections)
      ..removeWhere((c) => c.alias == connection.alias);
    state = state.copyWith(
      connections: connections,
    );
    _saveState();
  }

  Future<void> setCurrentAlias(String alias) async {
    if (!hasConnection(alias)) {
      throw StateError('Connection with alias $alias does not exist');
    }

    if (state.currentAlias == alias) return;

    state = state.copyWith(currentAlias: alias);
    _saveState();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this provider in your app');
});
