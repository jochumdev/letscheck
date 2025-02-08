import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letscheck/javascript/javascript.dart';
import 'package:letscheck/providers/connection/connection_notifier.dart';
import 'package:letscheck/providers/connection/connection_state.dart';
import 'package:letscheck/providers/hosts/hosts_provider.dart';
import 'package:letscheck/providers/hosts/hosts_state.dart';
import 'package:letscheck/providers/params.dart';
import 'package:letscheck/providers/search/search_provider.dart';
import 'package:letscheck/providers/search/search_state.dart';
import 'package:letscheck/providers/services/services_provider.dart';
import 'package:letscheck/providers/services/services_state.dart';
import 'package:package_info_plus/package_info_plus.dart';
export 'package:letscheck/providers/settings/settings_provider.dart';

final connectionProvider = StateNotifierProvider.family<ConnectionNotifier, ConnectionState, String>((ref, site) {
  return ConnectionNotifier(ref, site);
});

final hostsProvider = StateNotifierProvider.family<HostsNotifier, HostsState, SiteAndFilterParams>((ref, params) {
  return HostsNotifier(ref, params);
});

final servicesProvider = StateNotifierProvider.family<ServicesNotifier, ServicesState, SiteAndFilterParams>((ref, params) {
  return ServicesNotifier(ref, params);
});

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

final javascriptRuntimeProvider = FutureProvider<JavascriptRuntimeWrapper>((ref) async {
  return await initJavascriptRuntime();
});
