import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:recase/recase.dart';
import 'package:resus_test/Utility/utils/constants.dart';

import '../../../Utility/gps_dialogbox.dart';
import '../models/CProtect.dart';

class IncidentFormView extends StatefulWidget {
  final CProtect cProtect;

  const IncidentFormView({required this.cProtect});

  @override
  State<IncidentFormView> createState() => _IncidentFormViewState(cProtect);
}

class _IncidentFormViewState extends State<IncidentFormView> {
  CProtect m_cProtect;
  late List<CProtect> listProtect = [];
  List<CProtect> itemsProtect = [];

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  _IncidentFormViewState(this.m_cProtect);

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
    return Material(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kReSustainabilityRed,
          title: const Text(
            'IRM Action',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'ARIAL',
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),

          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              IrmActionCardCard(m_cProtect),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20),
                child: Text(
                  "INCIDENT DETAILS",
                  style: TextStyle(
                      fontFamily: "ARIAL",
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  color: const Color(0xffffffff),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 2.0,
                      spreadRadius: 1.0,
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110.0,
                            child: Text(
                              "Incident Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            m_cProtect.incident_type.titleCase,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110.0,
                            child: Text(
                              "Risk Type",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            m_cProtect.risk_type.titleCase,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 110.0,
                            child: Text(
                              "Incident Category",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 160,
                            child: Text(
                              m_cProtect.incident_category.titleCase,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 130.0,
                            child: Text(
                              "Description :",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            m_cProtect.description.titleCase,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20.0, top: 20),
                child: Text(
                  "REVIEWER",
                  style: TextStyle(
                      fontFamily: "ARIAL",
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  color: const Color(0xffffffff),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 2.0,
                      spreadRadius: 1.0,
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 40.0,
                            child: Text(
                              "Name",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            m_cProtect.approver_name.titleCase,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 40.0,
                            child: Text(
                              "Email",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontFamily: "ARIAL"),
                            ),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            m_cProtect.email_id,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: "ARIAL"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget IrmActionCardCard(CProtect cProtect) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        color: const Color(0xffffffff),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 2.0,
            spreadRadius: 1.0,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text(
                  m_cProtect.document_code,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Colors.grey.shade600,
                      fontFamily: "ARIAL"),
                ),
                const Spacer(),
                Container(
                    width: 150.0,
                    height: 38.0,
                    decoration: BoxDecoration(
                        color: colorChange(m_cProtect),
                        // color: Colors.green,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12.withOpacity(0.1),
                              blurRadius: 2.0,
                              spreadRadius: 1.0)
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Center(child: statusChange(m_cProtect)),
                    )),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90.0,
                  child: Text(
                    "Project",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: "ARIAL"),
                  ),
                ),
                Text(
                  ":",
                  style: TextStyle(
                      color: Colors.grey.shade600, fontFamily: "ARIAL"),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  width: 180,
                  child: Text(
                    m_cProtect.project_name.titleCase,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: "ARIAL"),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90.0,
                  child: Text(
                    "Department",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: "ARIAL"),
                  ),
                ),
                Text(
                  ":",
                  style: TextStyle(
                      color: Colors.grey.shade600, fontFamily: "ARIAL"),
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                  width: 180,
                  child: Text(
                    m_cProtect.department_name.titleCase,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: "ARIAL"),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90.0,
                  child: Text(
                    "Date",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: "ARIAL"),
                  ),
                ),
                Text(
                  ":",
                  style: TextStyle(
                      color: Colors.grey.shade600, fontFamily: "ARIAL"),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  // DateFormat("dd-MM-yyyy  hh:mm a").format(
                  //     DateFormat('dd-MMM-yy  hh:mm')
                  //         .parse(m_cProtect.created_date, true)
                  //         .toLocal()),
                    m_cProtect.created_date,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: "ARIAL"),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90.0,
                  child: Text(
                    "Last Updated",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: "ARIAL"),
                  ),
                ),
                Text(
                  ":",
                  style: TextStyle(
                      color: Colors.grey.shade600, fontFamily: "ARIAL"),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                    m_cProtect.action_taken,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: "ARIAL"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color colorChange(CProtect cProtect) {
    if (cProtect.approver_type == "IRL2") {
      return const Color(0xffffcb372);
    }
    if (cProtect.approver_type == "IRL3") {
      return const Color(0xff6B8E23);
    }
    if (cProtect.approver_type == "IRL1") {
      return const Color(0xffE1C16E);
    }
    return Colors.grey;
  }

  Widget statusChange(CProtect cProtect) {
    if (cProtect.approver_type == "IRL1") {
      return const Text(
        "In-Progress",
        style: TextStyle(fontSize: 12, color: Colors.white),
      );
    }
    if (cProtect.approver_type == "IRL2") {
      return Column(
        children: const [
          Text(
            "Action Taken",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          Text(
            "Review In-progress",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      );
    }
    if (cProtect.approver_type == "IRL3") {
      return Column(
        children: const [
          Text(
            "Review Done",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          Text(
            "Closure Pending",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      );
    }
    return const Text(
      "User",
      style: TextStyle(fontSize: 12, color: Colors.white),
    );
  }
}
