import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:resus_test/AppStation/widgets/app_station_item_widget.dart';
import 'package:resus_test/AppStation/widgets/brain_box.dart';
import 'package:resus_test/AppStation/widgets/complyone.dart';
import 'package:resus_test/AppStation/widgets/iris.dart';
import 'package:resus_test/AppStation/widgets/re_learning.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../Screens/routes/routes.dart';
import '../Utility/gps_dialogbox.dart';
import '../Utility/showDialogBox.dart';
import '../Utility/utils/constants.dart';

class AppStation extends StatefulWidget {
  const AppStation({Key? key}) : super(key: key);

  @override
  State<AppStation> createState() => _AppStationState();
}

class _AppStationState extends State<AppStation> {
  TextEditingController searchController = TextEditingController();

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
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => const GPSDialog());
      return;
    }
  }

  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('appStationContainer'),
      resizeToAvoidBottomInset: false,
      backgroundColor: protectBackgroundColor,
      body: Stack(
        key: const ValueKey('appStationContainer1'),
        children: [
          Container(
            height: 100,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              color: kReSustainabilityRed,
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 25.0, right: 30, left: 30),
              child: TextField(
                enabled: false,
                style: const TextStyle(color: kReSustainabilityRed),
                cursorColor: kReSustainabilityRed,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: searchFillColor,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: kReSustainabilityRed, width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Colors.grey[300]!, width: 0.5),
                  ),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: kReSustainabilityRed),
                  ),
                  hintText: 'Search..',
                  hintStyle: const TextStyle(color: kColorDark),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: kColorDark),
                  contentPadding:
                      const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                ),
                controller: searchController,
              )),
          Stack(
            children: [
              Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 18.h),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            AppStationItemWidget(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(Routes.protectOnboard);
                              },
                              image: 'protect_new',
                              label: 'Protect',
                            ),
                            AppStationItemWidget(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BrainBox();
                                    },
                                  ),
                                );
                              },
                              image: 'brain_box_new',
                              label: 'Brain Box',
                            ),
                            AppStationItemWidget(
                              onTap: () async {
                                var openAppResult = await LaunchApp.openApp(
                                  androidPackageName: 'com.darwinbox.darwinbox',
                                  appStoreLink:
                                      'https://play.google.com/store/apps/details?id=com.darwinbox.darwinbox',
                                  // openStore: false
                                );
                                print(
                                    'openAppResult => $openAppResult ${openAppResult.runtimeType}');
                              },
                              image: 'drawing_box_new',
                              label: 'Darwinbox',
                            )
                          ])),
                  const SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        AppStationItemWidget(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ReLearning();
                                },
                              ),
                            );
                          },
                          image: 're_leraning_new',
                          label: 'Relearning',
                        ),
                        AppStationItemWidget(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Complyone();
                                },
                              ),
                            );
                          },
                          image: 'complyone_new',
                          label: 'Complyone',
                        ),
                        AppStationItemWidget(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Iris();
                                },
                              ),
                            );
                          },
                          image: 'Iris_new',
                          label: 'Iris',
                        )
                      ])
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }
}
