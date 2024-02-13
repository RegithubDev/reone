import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../Utility/gps_dialogbox.dart';

class HelpDesk extends StatefulWidget {
  @override
  State<HelpDesk> createState() => _HelpDeskState();
}

class _HelpDeskState extends State<HelpDesk> {
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
      body: WebView(
        initialUrl:
            'https://accounts.zoho.com/signin?servicename=SDPOnDemand&hide_title=true&hideyahoosignin=true&hidefbconnect=true&hide_secure=true&serviceurl=https%3A%2F%2Fithelpdesk.resustainability.com%2Fjsp%2Findex.jsp&signupurl=https://ithelpdesk.resustainability.com/AccountCreation.do&portal_id=784502603&hide_signup=true',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (_controller) {
          this._controller = _controller;
        },
      ),
    );
  }
}
