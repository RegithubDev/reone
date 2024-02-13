import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../Screens/components/custom_circular_indicator.dart';
import '../../Screens/components/round_icon_button.dart';
import '../../Screens/home/home.dart';
import '../../Utility/MySharedPreferences.dart';
import '../../Utility/api_Url.dart';
import '../../Utility/gps_dialogbox.dart';
import '../../Utility/shared_preferences_string.dart';
import '../../Utility/showLoader.dart';
import '../../Utility/utils/constants.dart';
import '../../custom_sharedPreference.dart';
import 'Incident_report/inbox.dart';
import 'Incident_report/incident_tabview_screen.dart';
import 'Incident_report/outbox.dart';

class ProtectOnboard extends StatefulWidget {
  const ProtectOnboard({Key? key}) : super(key: key);

  @override
  State<ProtectOnboard> createState() => _ProtectOnboardState();
}

class _ProtectOnboardState extends State<ProtectOnboard> {
  late double _all_irm;
  late double _active_irm;
  late double _inActive_irm;
  late double _not_assigned;

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  void initState() {
    getConnectivity();
    _gpsService();
    super.initState();
    _all_irm = 0.0;
    _active_irm = 0.0;
    _inActive_irm = 0.0;
    _not_assigned = 0.0;

    MySharedPreferences.instance
        .getCityStringValue('JSESSIONID')
        .then((session) async {
      getDashboardCount(session);
      ;
    });
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
      key: const ValueKey('protectContainer'),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Protect",
          style: TextStyle(
              fontFamily: "ARIAL",
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        leading: InkWell(
            onTap: () async {
              String userId = await CustomSharedPref.getPref<String>(
                      SharedPreferencesString.userId) ??
                  '';
              String emailId = await CustomSharedPref.getPref<String>(
                      SharedPreferencesString.emailId) ??
                  '';

              // ignore: use_build_context_synchronously
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(
                          googleSignInAccount: null,
                          userId: userId,
                          emailId: emailId,
                          initialSelectedIndex: 4)));
            },
            child: const Icon(Icons.arrow_back_ios)),
        elevation: 0,
        backgroundColor: kReSustainabilityRed,
        actions: [
          InkWell(
            key: const Key("home_icon_btn"),
            child: const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.home, color: Colors.white),
            ),
            onTap: () async {
              String userId = await CustomSharedPref.getPref<String>(
                      SharedPreferencesString.userId) ??
                  '';
              String emailId = await CustomSharedPref.getPref<String>(
                      SharedPreferencesString.emailId) ??
                  '';

              // ignore: use_build_context_synchronously
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(
                          googleSignInAccount: null,
                          userId: userId,
                          emailId: emailId,
                          initialSelectedIndex: 0)));
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FutureBuilder(
                              future: getStringValue('user_name'),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasData) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          snapshot.data.toString().titleCase,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: "ARIAL",
                                            color: Colors.black,
                                            fontSize: 13.sp,
                                            fontWeight:
                                                FontWeight.bold, // italic
                                          ),
                                        ),
                                      ),
                                    ],
                                  ); // your widget
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              }),
                          FutureBuilder(
                              future: getStringValue('base_role'),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasData) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          snapshot.data.toString().titleCase,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 9.sp,
                                            fontFamily: 'ARIAL',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ); // your widget
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              }),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        const Text(
                          "Total Incidents",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'ARIAL'),
                        ),
                        const SizedBox(height: 10),
                        RawMaterialButton(
                          key: const Key("btn_incident_screen"),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        IncidentTabviewScreen(0)))
                                .then((value) => setState(() {}));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          fillColor: kReSustainabilityRed,
                          child: Container(
                            height: 4.h,
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    _all_irm.toString().split('.')[0],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.white),
                                    onTap: () {},
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Divider(
                  height: 1,
                  color: Colors.grey[350],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: [
                        const Text(
                          "Resolved",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'ARIAL'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomCircularIndicator(
                          radius: 65,
                          percent: 1.0,
                          lineWidth: 5,
                          line1Width: 2,
                          count: _active_irm / _all_irm * 100,
                        ),
                        RawMaterialButton(
                          key: const Key("btn_tab_view"),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        IncidentTabviewScreen(2)))
                                .then((value) => setState(() {}));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          fillColor: kReSustainabilityRed,
                          child: Container(
                            height: 4.h,
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    _active_irm.toString().split('.')[0],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const IncidentTabview()));
                                      })
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          "In Progress",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'ARIAL'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomCircularIndicator(
                          radius: 65,
                          percent: 1.0,
                          lineWidth: 5,
                          line1Width: 2,
                          count: _inActive_irm / _all_irm * 100,
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        IncidentTabviewScreen(1)))
                                .then((value) => setState(() {}));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          fillColor: kReSustainabilityRed,
                          child: Container(
                            height: 4.h,
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    _inActive_irm.toString().split('.')[0],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      onTap: () {})
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          "No Reviewer",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'ARIAL'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomCircularIndicator(
                          radius: 65,
                          percent: 1.0,
                          lineWidth: 5,
                          line1Width: 2,
                          count: _not_assigned / _all_irm * 100,
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                builder: (context) =>
                                    IncidentTabviewScreen(0)))
                                .then((value) => setState(() {}));
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          fillColor: kReSustainabilityRed,
                          child: Container(
                            height: 4.h,
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    _not_assigned.toString().split('.')[0],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      child: const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: Colors.white),
                                      onTap: () {
                                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const IncidentTabview()));
                                      })
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 2.h,
                ),
                Divider(
                  height: 1,
                  color: Colors.grey[350],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3.0.h),
                  child: Container(
                    // color: Colors.grey.shade200,
                    height: 25.h,
                    child:
                    ListView(
                      scrollDirection: Axis.horizontal,
                      children:<Widget> [
                        Container(
                          height: 40.0,
                          width: 150.0,
                          child: Image.asset(
                            'assets/images/PPE_R1_1.jpg',
                            scale: 0.09.h, fit: BoxFit.fill,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        SizedBox(width: 20,),
                        Container(
                          height: 40.0,
                          width: 150.0,
                          child: Image.asset(
                            'assets/images/ELECTRICAL-SAFETY_R1_1.jpg',
                            scale: 0.09.h, fit: BoxFit.fill,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        SizedBox(width: 20,),
                        Container(
                          height: 40.0,
                          width: 150.0,
                          child: Image.asset(
                            'assets/images/MACHINE-SAFETY_R1.jpg',
                            scale: 0.09.h, fit: BoxFit.fill,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        SizedBox(width: 20,),
                        Container(
                          height: 40.0,
                          width: 150.0,
                          child: Image.asset(
                            'assets/images/Transport-R1_1.jpg',
                            scale: 0.09.h, fit: BoxFit.fill,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        SizedBox(width: 20,),
                        Container(
                          height: 40.0,
                          width: 150.0,
                          child: Image.asset(
                            'assets/images/WALLPOSTER_LIFE-SAVING-RULES_FINAL_ENGLISH_1.jpg',
                            scale: 0.09.h, fit: BoxFit.fill,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),

                      ],
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.only(
              top: 10.0, left: 20, right: 20, bottom: 20.0),
          child: Row(
            children: <Widget>[
              badges.Badge(
                position: badges.BadgePosition.topEnd(top: -15, end: -15),
                badgeStyle: badges.BadgeStyle(
                  badgeColor: Colors.green,
                ),
                badgeContent: Container(
                  width: 25,
                  height: 20,
                  alignment: Alignment.center,
                  child: Text(
                    _active_irm.toString().split('.')[0],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                child: RoundIconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const Inbox()));
                  },
                  icon: Icons.move_to_inbox,
                  elevation: 1,
                  color: kReSustainabilityRed,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              badges.Badge(
                position: badges.BadgePosition.topEnd(top: -15, end: -15),
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Colors.green,
                ),
                badgeContent: Container(
                  width: 25,
                  height: 20,
                  alignment: Alignment.center,
                  child: Text(
                    _inActive_irm.toString().split('.')[0],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                child: RoundIconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Outbox()));
                  },
                  icon: Icons.outbox,
                  elevation: 1,
                  color: kReSustainabilityRed,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: RawMaterialButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                              builder: (context) => IncidentTabviewScreen(0)),
                        )
                        .then((value) => setState(() {}));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  fillColor: kReSustainabilityRed,
                  child: SizedBox(
                    height: 48,
                    child: Center(
                      child: Text(
                        'View ' + '/ ' + 'create incident'.titleCase,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontFamily: 'ARIAL',
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getDashboardCount(String sessionId) async {
    var headers = {'Content-Type': 'application/json', "Cookie": sessionId};
    var request = http.Request('GET', Uri.parse(GET_DASHBOARD_COUNT));
    request.body = json.encode({
      // "user_id": userId
    });
    request.headers.addAll(headers);
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ShowLoader();
        });
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      if (jsonDecode(response.body).isEmpty) {
        return;
      }
      setState(() {
        _all_irm = double.parse(jsonDecode(response.body)[0]["all_irm"]);
        _active_irm = double.parse(jsonDecode(response.body)[0]["active_irm"]);
        _inActive_irm =
            double.parse(jsonDecode(response.body)[0]["inActive_irm"]);
        _not_assigned =
            double.parse(jsonDecode(response.body)[0]["not_assigned"]);
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }
}
