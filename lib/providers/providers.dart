import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/services/connectivity_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:checkmk_api/checkmk_api.dart' as cmk_api;

import 'package:letscheck/javascript/javascript.dart';
import 'package:letscheck/providers/connection_data/connection_data_notifier.dart';
import 'package:letscheck/providers/connection_data/connection_data_state.dart';
import 'package:letscheck/providers/hosts/hosts_provider.dart';
import 'package:letscheck/providers/hosts/hosts_state.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/search/search_provider.dart';
import 'package:letscheck/providers/search/search_state.dart';
import 'package:letscheck/providers/services/services_provider.dart';
import 'package:letscheck/providers/services/services_state.dart';
import 'package:letscheck/providers/settings/settings_provider.dart';

export 'package:letscheck/providers/settings/settings_provider.dart';

final clientProvider = Provider.family<cmk_api.Client, String>((ref, alias) {
  final settings = ref.watch(settingsProvider
      .select((s) => s.connections.where((c) => c.alias == alias).single));

  final client = cmk_api.Client(
    cmk_api.ClientSettings(
      baseUrl: settings.baseUrl,
      site: settings.site,
      username: settings.username,
      secret: settings.password,
      insecure: !settings.insecure,
    ),
  );

  return client;
});

final clientStatesProvider =
    StreamProvider.family<cmk_api.ConnectionState, String>((ref, alias) {
  final client = ref.watch(clientProvider(alias));

  return client.connectionState;
});

final clientStateProvider =
    StreamProvider.family<cmk_api.ConnectionState?, String>((ref, alias) async* {
  final settings = ref.watch(settingsProvider
      .select((s) => s.connections.where((c) => c.alias == alias).single));

  final client = ref.watch(clientProvider(alias));
  final connectivity = await ref.watch(connectivityProvider.future);
  final currentState = ref.watch(clientStatesProvider(alias));

  if (settings.wifiOnly) {
    // Disconnect the client when we are on mobile and wifiOnly is true
    if (currentState.value == cmk_api.ConnectionState.connected &&
        (connectivity.contains(ConnectivityResult.mobile) ||
            connectivity.contains(ConnectivityResult.none))) {
      client.disconnect(reason: cmk_api.BaseException(message: "Not on WiFi"));
    } else if (currentState.value != cmk_api.ConnectionState.connected && currentState.value != cmk_api.ConnectionState.connecting) {
      // Reconnect when the Wifi comes back.
      await client.reconnect();
    } 
  } else if (currentState.value != cmk_api.ConnectionState.connected && currentState.value != cmk_api.ConnectionState.connecting) {
    await client.reconnect();
  }

  yield currentState.value;
});

final connectionDataProvider = StateNotifierProvider.family<
    ConnectionDataNotifier, ConnectionDataState, String>((ref, alias) {
  return ConnectionDataNotifier(ref, alias);
});

final hostsProvider = StateNotifierProvider.family<HostsNotifier, HostsState,
    AliasAndFilterParams>((ref, params) {
  return HostsNotifier(ref, params);
});

final servicesProvider = StateNotifierProvider.family<ServicesNotifier,
    ServicesState, AliasAndFilterParams>((ref, params) {
  return ServicesNotifier(ref, params);
});

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

final javascriptRuntimeProvider =
    FutureProvider<JavascriptRuntimeWrapper>((ref) async {
  return await initJavascriptRuntime();
});
