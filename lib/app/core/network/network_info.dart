// lib/core/network/network_info.dart

import 'package:internet_connection_checker/internet_connection_checker.dart';

/// واجهة للتحقق من اتصال الإنترنت
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// تنفيذ للتحقق من اتصال الإنترنت
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
