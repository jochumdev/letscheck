import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/services/connectivity_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:dio/dio.dart';

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

final talkerProvider = Provider<Talker>((ref) {
  throw UnimplementedError('Initialize this provider in your app');
});

final talkerDioLoggerProvider = Provider<TalkerDioLogger>((ref) {
  return TalkerDioLogger(
    talker: ref.read(talkerProvider),
    settings: const TalkerDioLoggerSettings(
      printRequestData: false,
      printRequestHeaders: false,
      printResponseHeaders: false,
      printResponseMessage: false,
      printErrorHeaders: false,
      printResponseData: false,
      printResponseRedirects: false,
    ),
  );
});

final clientProvider = Provider.family<cmk_api.Client, String>((ref, alias) {
  final allSettings = ref.watch(settingsProvider);
  final settings =
      allSettings.connections.where((c) => c.alias == alias).single;

  final talkerDioLogger = ref.read(talkerDioLoggerProvider);

  final client = cmk_api.Client(
    () {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      dio.interceptors.add(
        talkerDioLogger,
      );
      return dio;
    },
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

/// Provides the connection state for a specific client identified by [alias].
///
/// The state is determined by:
/// - Network connectivity (WiFi vs Mobile/None)
/// - Connection settings (WiFi only mode, paused state)
/// - Current client state
///
/// Throws [StateError] if no connection with the given alias exists.
final clientStateProvider =
    StreamProvider.family<cmk_api.ConnectionState, String>((ref, alias) {
  final allSettings = ref.watch(settingsProvider);
  final settings =
      allSettings.connections.where((c) => c.alias == alias).single;

  var client = ref.watch(clientProvider(alias));

  return Rx.combineLatest2(
      client.connectionStateStream, ConnectivityService.onConnectivityChanged,
      (state, connectivity) {
    final hasWifiConnection =
        !connectivity.contains(ConnectivityResult.mobile) &&
            !connectivity.contains(ConnectivityResult.none);

    final shouldBePaused =
        settings.paused || (settings.wifiOnly && !hasWifiConnection);
    final isPaused =
        client.requestedConnectionState == cmk_api.ConnectionState.paused ||
            client.connectionState == cmk_api.ConnectionState.initial;

    // Handle connection state based on settings and network conditions
    if (shouldBePaused) {
      client.pause(
          reason: settings.wifiOnly
              ? 'Paused - This is Wifi Only'
              : 'Paused by Settings');
    } else if (isPaused) {
      client.connect();
    }

    return client.connectionState;
  });
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

final packageInfoProvider = Provider<PackageInfo>((ref) {
  throw UnimplementedError('Initialize the provider in the app');
});

final javascriptRuntimeProvider = Provider<JavascriptRuntimeWrapper>((ref) {
  throw UnimplementedError('Initialize the provider in the app');
});
