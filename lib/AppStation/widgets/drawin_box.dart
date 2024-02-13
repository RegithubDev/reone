import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Utility/gps_dialogbox.dart';
import '../../Utility/utils/constants.dart';

class DrawinBox extends StatefulWidget {
  @override
  State<DrawinBox> createState() => _DrawinBoxState();
}

class _DrawinBoxState extends State<DrawinBox> {
  TextEditingController searchController = TextEditingController();

  late WebViewController _controller;

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    getConnectivity();
    _gpsService();
    super.initState();
  }

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
            (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );
  showDialogBox() => showCupertinoDialog<String>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => WillPopScope(
      onWillPop: () async => false,
      child: CupertinoAlertDialog(
        title: const Text('No Connection'),
        content: const Text('Please check your internet connectivity'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.pop(context, 'Cancel');
              setState(() => isAlertSet = false);
              isDeviceConnected =
              await InternetConnectionChecker().hasConnection;
              if (!isDeviceConnected && isAlertSet == false) {
                showDialogBox();
                setState(() => isAlertSet = true);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );

  Future _gpsService() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      // ignore: use_build_context_synchronously
      if (Theme.of(context).platform == TargetPlatform.android) {
        // ignore: use_build_context_synchronously
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => const GPSDialog());
        return;
      }
    }
  }

  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kReSustainabilityRed,
        title: const Text(
          'Drawin Box',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'ARIAL',
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),

        centerTitle: true,
        elevation: 0,
      ),
      body: WebView(
        initialUrl: 'https://play.google.com/store/apps/details?id=com.darwinbox.darwinbox',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (_controller) {
          this._controller = _controller;
        },
      ),

    );
  }

}
