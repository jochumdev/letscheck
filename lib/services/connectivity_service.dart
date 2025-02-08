import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  final connectivity = Connectivity();
  // Return a Stream that emits the current connectivity status and then
  // emits new values whenever the status changes
  return connectivity.onConnectivityChanged;
});

final isWifiProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (status) => status == ConnectivityResult.wifi,
    loading: () => false,
    error: (_, __) => false,
  );
});

class ConnectivityService {
  static Future<bool> isOnWifi() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity == ConnectivityResult.wifi;
  }

  static Future<ConnectivityResult> checkConnectivity() async {
    return await Connectivity().checkConnectivity();
  }

  static Stream<ConnectivityResult> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged;
  }
}
