import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class InternetConnectivityCheck {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  InternetConnectivityCheck();

  Future<String> checkInternet() async {
    initConnectivity();
    return _connectionStatus.toString();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus = result;
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    return _updateConnectionStatus(result);
  }
}
