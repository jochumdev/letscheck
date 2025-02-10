import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivity = Connectivity();
  // Return a Stream that emits the current connectivity status and then
  // emits new values whenever the status changes
  return connectivity.onConnectivityChanged;
});

final isMobileProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (status) => status.contains(ConnectivityResult.mobile),
    loading: () => true,
    error: (_, __) => true,
  );
});

class ConnectivityService {
  static Future<bool> isMobile() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity.contains(ConnectivityResult.mobile);
  }

  static Future<List<ConnectivityResult>> checkConnectivity() async {
    return await Connectivity().checkConnectivity();
  }

  static Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged;
  }
}
