import '../utils/helper_function.dart';

abstract class NetworkInfo {
  Future<bool?> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl();

  @override
  Future<bool?> get isConnected async =>
       await checkInternetConnection();
}
