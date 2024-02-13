 import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resus_test/Utility/internetConnectivityCheck.dart';

 void main(){
   test('test internet connectivity', ()  async {
     WidgetsFlutterBinding.ensureInitialized();
     InternetConnectivityCheck internetConnectivityCheck=InternetConnectivityCheck();
     var result= await internetConnectivityCheck.checkInternet();
     expect(result, "ConnectivityResult.none");
   });
 }