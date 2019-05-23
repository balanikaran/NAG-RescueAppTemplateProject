import 'package:connectivity/connectivity.dart';

class InternetConnectivityCheck{
  static Future<bool> getConnectionStatus() async {
    ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi){
      return true;
    }else{
      return false;
    }
  }
}