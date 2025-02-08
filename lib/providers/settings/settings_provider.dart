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
          connections: {},
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
      state = SettingsState.fromJson(stateMap);
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

  Future<void> addConnection(String alias, SettingsStateConnection connection) async {
    if (state.connections.containsKey(alias)) {
      throw StateError('Connection with alias $alias already exists');
    }

    state = state.copyWith(
      connections: Map.from(state.connections)..addAll({alias: connection}),
    );
    _saveState();
  }

  Future<void> updateConnection(String site, SettingsStateConnection connection) async {
    if (!state.connections.containsKey(site)) return;

    final connections = Map<String, SettingsStateConnection>.from(state.connections)..update(site, (value) => connection);
    state = state.copyWith(connections: connections);
    _saveState();
  }

  Future<void> deleteConnection(String site) async {
    if (!state.connections.containsKey(site)) return;

    final connections = Map<String, SettingsStateConnection>.from(state.connections);
    connections.remove(site);

    state = state.copyWith(
      connections: connections,
    );
    _saveState();
  }

  Future<void> setCurrentSite(String site) async {
    if (!state.connections.containsKey(site)) {
      throw StateError('Connection with alias $site does not exist');
    }

    if (state.currentAlias == site) return;

    state = state.copyWith(currentAlias: site);
    _saveState();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this provider in your app');
});
