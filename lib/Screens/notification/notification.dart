import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utility/MySharedPreferences.dart';
import '../../Utility/gps_dialogbox.dart';
import '../../Utility/showLoader.dart';
import '../home/home.dart';
import 'CNotification.dart';
import 'notificationApiCall.dart';
import 'notification_sort_popup.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late List<CNotification> listNotification = [];
  List<CNotification> itemsNotification = [];

  TextEditingController searchController = TextEditingController();

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  void initState() {
    getConnectivity();
    _gpsService();
    super.initState();
    MySharedPreferences.instance
        .getCityStringValue('user_id')
        .then((userid) async {
      MySharedPreferences.instance
          .getCityStringValue('JSESSIONID')
          .then((session) async {
        populateNotificationList(session, userid);

        final service = FlutterBackgroundService();
        service.invoke("stopService");
      });
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
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
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

  void populateNotificationList(String sessionId, String userId) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ShowLoader();
        });
    NotificationApiCall obj = NotificationApiCall(sessionId, userId);
    var response = await obj.callNotificationAPi();
    for (Map json in jsonDecode(response.body)) {
      if (json["user_id"] == null) {
        json["user_id"] = '';
      }
      if (json["module_type"] == null) {
        json["module_type"] = '';
      }
      if (json["message"] == null) {
        json["message"] = '';
      }
      if (json["create_date"] == null) {
        json["create_date"] = '';
      }
      if (json["session_count"] == null) {
        json["session_count"] = '';
      }
      if (json["time_period"] == null) {
        json["time_period"] = '';
      }

      listNotification.add(CNotification.fromJson(json));
    }
    if(this.mounted){
      setState(() {
        itemsNotification.addAll(listNotification);
      });
    }
    Navigator.of(context).pop();

  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('az');
    return Material(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: kReSustainabilityRed,
            elevation: 0.0,
            title: const Text(
              'Notifications',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'ARIAL',
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: InkWell(
                  key: const Key("home_icon_btn"),
                  child: const Icon(Icons.home, color: Colors.white),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                              builder: (context) => Home(
                                    googleSignInAccount: null,
                                    userId: '',
                                    emailId: '',
                                    initialSelectedIndex: 0,
                                  )),
                        )
                        .then((value) => setState(() {}));
                  },
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                  child: Stack(
                children: [
                  Padding(
                      padding:
                          const EdgeInsets.only(top: 30.0, right: 10, left: 10),
                      child: TextField(
                        style: const TextStyle(color: kReSustainabilityRed),
                        cursorColor: kReSustainabilityRed,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: const BorderSide(
                                color: kReSustainabilityRed, width: 0.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(
                                color: Colors.grey[300]!, width: 0.5),
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: kReSustainabilityRed),
                          ),
                          hintText: 'Search..',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: kReSustainabilityRed),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              searchController.clear();
                              FocusManager.instance.primaryFocus?.unfocus();
                              String? sortKey = await showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) =>
                                      const NotificationSortPopup());
                              setState(() {
                                if (sortKey == 'Date') {
                                  listNotification.sort((a, b) =>
                                      a.create_date.compareTo(b.create_date));
                                  itemsNotification.clear();
                                  itemsNotification.addAll(listNotification);
                                }
                                if (sortKey == 'Message') {
                                  listNotification.sort(
                                      (a, b) => a.message.compareTo(b.message));
                                  itemsNotification.clear();
                                  itemsNotification.addAll(listNotification);
                                }

                                if (sortKey == 'Module Type') {
                                  listNotification.sort((a, b) =>
                                      a.module_type.compareTo(b.module_type));
                                  itemsNotification.clear();
                                  itemsNotification.addAll(listNotification);
                                }
                              });
                            },
                            icon: const Icon(Icons.sort_sharp,
                                color: kReSustainabilityRed),
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        ),
                        onChanged: (value) {
                          filterNotificationSearchResults(value.toLowerCase());
                        },
                        controller: searchController,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 100.0, bottom: 20.0, left: 10.0, right: 10.0),
                    child: ListView.builder(
                        key: const ValueKey('MyIrListViewKey'),
                        itemCount: itemsNotification.length,
                        itemBuilder: (BuildContext context, int index) {
                          return notificationCard(
                              index, itemsNotification[index]);
                        }),
                  )
                ],
              )),
            ],
          )),
    );
  }

  Widget notificationCard(int index, CNotification cNotification) {
    return GestureDetector(
      child: Container(
        key: const ValueKey('notificationcontainer2'),
        // height: 100.0,
        height: MediaQuery.of(context).size.height * 0.12,
        width: double.infinity,
        margin: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: Border.all(color: const Color(0xfff2f2f2)),
            color: const Color(0xffFAF9F6)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cNotification.module_type,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                    color: Color(0xff7B7FA7),
                    fontFamily: "ARIAL"),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                cNotification.message,
                style: const TextStyle(
                    fontSize: 12.0,
                    color: Color(0xff7B7FA7),
                    fontFamily: "ARIAL"),
              ),
              Row(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(
                      top:6.0,
                    ),
                    child: Text(
                      DateFormat("dd-MM-yyyy h:mm a").format(
                          DateFormat('yyyy-MM-dd HH:mm:ss.sss')
                              .parse(cNotification.create_date.toString(), true)
                              .toLocal()),
                      style: const TextStyle(
                          fontSize: 10.0,
                          color: Colors.black,
                          fontFamily: "ARIAL"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: () {},
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }

  Widget prefixIcon() {
    return Container(
      height: 40,
      width: 40,
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade300),
      child: const Icon(
        Icons.notifications,
        size: 20,
        color: kReSustainabilityRed,
      ),
    );
  }

  void filterNotificationSearchResults(String query) {
    List<CNotification> dummySearchList = [];
    dummySearchList.addAll(listNotification);
    if (query.isNotEmpty) {
      List<CNotification> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.user_id.toString().toLowerCase().contains(query) ||
            item.module_type.toString().toLowerCase().contains(query) ||
            item.message.toString().toLowerCase().contains(query) ||
            item.create_date.toString().toLowerCase().contains(query) ||
            item.session_count.toString().toLowerCase().contains(query) ||
            item.time_period.toString().toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        itemsNotification.clear();
        itemsNotification.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        itemsNotification.clear();
        itemsNotification.addAll(listNotification);
      });
    }
  }
}
