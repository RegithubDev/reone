import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:recase/recase.dart';
import 'package:resus_test/Screens/home/rewards_sort_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utility/MySharedPreferences.dart';
import '../../Utility/gps_dialogbox.dart';
import '../../Utility/showLoader.dart';
import '../../Utility/utils/constants.dart';
import '../notification/notification.dart';
import 'CRewards.dart';
import 'getRewardsApiCall.dart';
import 'home.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  TextEditingController searchController = TextEditingController();

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  late List<CRewards> listRewards = [];
  List<CRewards> itemsRewards = [];

  @override
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
        populateRewardsList(session, userid);
      });
    });
  }

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            if(mounted==true){
              setState(() => isAlertSet = true);
            }

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
                if(mounted==true){
                  setState(() => isAlertSet = false);
                }
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  if(mounted==true){
                    setState(() => isAlertSet = true);
                  }
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

  void populateRewardsList(String sessionId, String userId) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ShowLoader();
        });
    RewardsApiCall obj = RewardsApiCall(sessionId, userId);
    var response = await obj.callRewardsAPi();
    for (Map json in jsonDecode(response.body)) {
      if (json["reward_points"] == null) {
        json["reward_points"] = '';
      }

      listRewards.add(CRewards.fromJson(json));
    }
    if(this.mounted){
      setState(() {
        itemsRewards.addAll(listRewards);
      });
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kReSustainabilityRed,
          title: const Text(
            'Rewards',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'ARIAL',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
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
                                    initialSelectedIndex: 0)),
                          )
                          .then((value) => setState(() {}));
                    },
                  ),
                ),
                StreamBuilder<Map<String, dynamic>?>(
                  stream: FlutterBackgroundService().on('update'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Notifications();
                                },
                              ),
                            );
                          },
                          child: Container(
                              padding: const EdgeInsets.all(10.0),
                              child: Stack(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 10.0,
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/icons/bell icon.svg',
                                      color: Colors.white,
                                      semanticsLabel: 'Acme Logo',
                                    ),
                                  ),
                                ],
                              )));
                    }

                    final data = snapshot.data!;
                    String? notification_count = data.length.toString();

                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Notifications();
                              },
                            ),
                          );
                        },
                        child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: <Widget>[
                                const Padding(
                                  padding:
                                      EdgeInsets.only(right: 1.0, top: 3.5),
                                  child: Icon(
                                    Icons.notifications_none_outlined,
                                    size: 25.0,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    height: 15.0,
                                    width: 15.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kReSustainabilityRed,
                                      border: Border.all(
                                          width: 1.0, color: Colors.white),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 1.0, bottom: 1.0),
                                          child: Text(
                                            notification_count!,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 7.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )));
                  },
                )
              ],
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
                          borderSide:
                              BorderSide(color: Colors.grey[300]!, width: 0.5),
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
                                    const RewardsSortPopup());
                            setState(() {
                              if (sortKey == 'User Name') {
                                listRewards.sort((a, b) =>
                                    a.user_name.compareTo(b.user_name));
                                itemsRewards.clear();
                                itemsRewards.addAll(listRewards);
                              }
                              if (sortKey == 'Reward Points') {
                                listRewards.sort((a, b) =>
                                    a.reward_points.compareTo(b.reward_points));
                                itemsRewards.clear();
                                itemsRewards.addAll(listRewards);
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
                        filterRewardsSearchResults(value.toLowerCase());
                      },
                      controller: searchController,
                    )),
                Padding(
                    padding: const EdgeInsets.only(
                        top: 90.0, bottom: 20.0, left: 10.0, right: 10.0),
                    child: getRewardsListView())
              ],
            )),
          ],
        ));
  }

  Widget rewardsCard(int index, CRewards cRewards) {
    return GestureDetector(
      child: Container(
        key: const ValueKey('notificationcontainer2'),
        // height: 85.0,
        height: MediaQuery.of(context).size.height * 0.11,

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
          padding: const EdgeInsets.only(left: 10.0,),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textField("User Name", cRewards.user_name.titleCase),
              _textField("Reward Points", cRewards.reward_points),
            ],
          ),
        ),
      ),
      onTap: () {},
    );
  }

  Widget getRewardsListView() {
    return itemsRewards.isNotEmpty
        ? ListView.builder(
            itemCount: itemsRewards.length,
            itemBuilder: (BuildContext context, int index) {
              return rewardsCard(index, itemsRewards[index]);
            })
        : const Center(
            child: Text(
            "No Rewards",
            style: TextStyle(color: Colors.black),
          ));
  }

  void filterRewardsSearchResults(String query) {
    List<CRewards> dummySearchList = [];
    dummySearchList.addAll(listRewards);
    if (query.isNotEmpty) {
      List<CRewards> dummyListData = [];
      dummySearchList.forEach((item) {
        if (item.reward_points.toString().toLowerCase().contains(query)||
            item.user_name.toString().toLowerCase().contains(query) ) {
          dummyListData.add(item);
        }
      });
      setState(() {
        itemsRewards.clear();
        itemsRewards.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        itemsRewards.clear();
        itemsRewards.addAll(listRewards);
      });
    }
  }

  Widget _textField(label, value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: <Widget>[
          SizedBox(
              width: 80.0,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xff7B7FA7),
                ),
              )),
          const SizedBox(width: 2),
          const Text(
            ":",
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 8),
          Flexible(
            child:
            /*Container(
              width: 200,
              alignment: Alignment.centerLeft,
              height: 30,
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  color: Color(0xff7B7FA7),
                ),
              ),
            ),*/
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Color(0xff7B7FA7),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }
}
