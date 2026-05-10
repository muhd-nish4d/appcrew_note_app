import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum AppNetworkStatus { online, offline, checking }

class ConnectivityManager {
  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  final _controller = StreamController<AppNetworkStatus>.broadcast();
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _internetSubscription;

  ConnectivityManager() {
    _init();
  }

  void _init() {
    _controller.add(AppNetworkStatus.checking);
    
    // Listen to physical interface changes (WiFi/Mobile)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isEmpty || results.contains(ConnectivityResult.none)) {
        _controller.add(AppNetworkStatus.offline);
      }
    });

    // Listen to actual internet pings
    _internetSubscription = _internetChecker.onStatusChange.listen((InternetStatus status) {
      if (status == InternetStatus.connected) {
        _controller.add(AppNetworkStatus.online);
      } else {
        _controller.add(AppNetworkStatus.offline);
      }
    });
  }

  Stream<AppNetworkStatus> get onStatusChange => _controller.stream;

  Future<AppNetworkStatus> checkInternetAccess() async {
    final hasAccess = await _internetChecker.hasInternetAccess;
    return hasAccess ? AppNetworkStatus.online : AppNetworkStatus.offline;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _controller.close();
  }
}
