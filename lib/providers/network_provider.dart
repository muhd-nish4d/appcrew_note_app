import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/network_service.dart';

class NetworkProvider extends ChangeNotifier {
  final ConnectivityManager _manager = ConnectivityManager();
  AppNetworkStatus _status = AppNetworkStatus.checking;
  StreamSubscription? _subscription;

  AppNetworkStatus get status => _status;
  bool get isOffline => _status == AppNetworkStatus.offline;
  bool get isOnline => _status == AppNetworkStatus.online;

  NetworkProvider() {
    _init();
  }

  Future<void> _init() async {
    // Initial check
    _status = await _manager.checkInternetAccess();
    notifyListeners();

    _subscription = _manager.onStatusChange.listen((newStatus) {
      if (_status != newStatus) {
        _status = newStatus;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _manager.dispose();
    super.dispose();
  }
}
