import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:resus_test/database/department/model_department.dart';
import 'package:resus_test/database/sbu/model_sbu.dart';
import 'package:resus_test/database/user/model_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Utility/MySharedPreferences.dart';
import '../../Utility/api_Url.dart';
import '../../Utility/gps_dialogbox.dart';
import '../../Utility/permission_request.dart';
import '../../Utility/shared_preferences_string.dart';
import '../../Utility/utils/constants.dart';
import '../../custom_sharedPreference.dart';
import '../../database/database.dart';
import '../../database/project/model_project.dart';
import '../login/login_page.dart';

class HomePage extends StatefulWidget {
  final GoogleSignInAccount? googleSignInAccount;
  final String userId;
  final String emailId;

  HomePage(
      {required this.googleSignInAccount,
      required this.userId,
      required this.emailId});

  @override
  _HomePageState createState() =>
      _HomePageState(googleSignInAccount, userId, emailId);
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  late final String phoneNumber;

  PermissionRequest permissionRequest = PermissionRequest();

  GoogleSignInAccount? m_googleSignInAccount;
  String m_user_id;
  String m_emailId;

  late WebViewController _webViewController;

  _HomePageState(this.m_googleSignInAccount, this.m_user_id, this.m_emailId);

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  InAppWebViewController? webViewController;
  PullToRefreshController? refreshController;
  late var url;
  var initialUrl = "";
  double progress = 0;
  var urlController = TextEditingController();
  var isloading = false;

  @override
  initState() {
    if (m_user_id == null || m_user_id == "") {
      setState(() {
        initialUrl = "https://appmint.resustainability.com/index/home";
      });
    } else {
      setState(() {
        initialUrl =
            "https://appmint.resustainability.com/index/login?email_id=$m_emailId";
      });
    }

    getConnectivity();
    _gpsService();
    super.initState();

    refreshController = PullToRefreshController(
        onRefresh: () {
          webViewController!.reload();
        },
        options: PullToRefreshOptions(
            color: Colors.white, backgroundColor: Colors.black));

    var cron = Cron();
    //Cron will run Every sunday 7.30 am
    cron.schedule(Schedule.parse('30  7  *  *  0'), () async {
      MySharedPreferences.instance
          .getCityStringValue('JSESSIONID')
          .then((session) async {
        logoutAPICall(session);
      });
    });

    fetchSbuList();
    fetchDepartmentList();
    fetchProjectList();
    fetchUserList();
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
    super.build(context);
    return Material(
      child: WillPopScope(
          onWillPop: () => _onWillPop(context),
          child: Scaffold(
            extendBodyBehindAppBar: true,
            key: const ValueKey('homePageContainer'),
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: Column(
              children: [
                Expanded(
                    child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InAppWebView(
                      onLoadStart: (controller, url) {
                        setState(() {
                          isloading = true;
                        });
                      },
                      onLoadStop: (controller, url) {
                        refreshController!.endRefreshing();
                        setState(() {
                          isloading = false;
                        });
                      },
                      pullToRefreshController: refreshController,
                      onWebViewCreated: (controller) =>
                          webViewController = controller,
                      initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
                    ),
                    Visibility(
                        visible: isloading,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.red),
                        ))
                  ],
                ))
              ],
            ),
          )),
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }

  @override
  bool get wantKeepAlive => true;

  fetchSbuList() async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelSBU;

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    var request = http.Request('GET', Uri.parse(GET_SBU_LIST));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      for (Map json in json.decode(response.body)) {
        model_sbu mdpn = model_sbu(null, json["sbu_code"], json["sbu_name"]);
        model_sbu? savedDealer = await _isSbuAvailable(json["sbu_code"]);

        if (savedDealer == null) {
          dao.insertSBU(mdpn);
        } else {
          dao.updateSBU(
              model_sbu(savedDealer.id, json["sbu_code"], json["sbu_name"]));
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<model_sbu?> _isSbuAvailable(String sbu_code) async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelSBU;
    return dao.findSBUById(sbu_code);
  }

  fetchProjectList() async {
    //TODO this should be split it as 3 function one for database one for json output one for saving data to DB
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelProject;

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    var request = http.Request('GET', Uri.parse(GET_PROJECTS_LIST));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      for (Map json in json.decode(response.body)) {
        model_project mdpn =
            model_project(null, json["project_code"], json["project_name"]);
        model_project? savedDealer =
            await _isProjectAvailable(json["project_code"]);

        if (savedDealer == null) {
          dao.insertProject(mdpn);
        } else {
          dao.updateProject(model_project(
              savedDealer.id, json["project_code"], json["project_name"]));
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<model_project?> _isProjectAvailable(String project_code) async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelProject;
    return dao.findProjectById(project_code);
  }

  fetchDepartmentList() async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelDepartment;

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    var request = http.Request('GET', Uri.parse(GET_DEPARTMENT_LIST));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      for (Map json in json.decode(response.body)) {
        model_department mdpn = model_department(
            null, json["department_code"], json["department_name"]);
        model_department? savedDealer =
            await _isDepartmentAvailable(json["department_code"]);

        if (savedDealer == null) {
          dao.insertDepartment(mdpn);
        } else {
          dao.updateDepartment(model_department(savedDealer.id,
              json["department_code"], json["department_name"]));
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<model_department?> _isDepartmentAvailable(
      String department_code) async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelDepartment;
    return dao.findDepartmentById(department_code);
  }

  fetchUserList() async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelUser;

    var headers = {
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=FD098F89016C70E30F70E16C65351102'
    };
    var request = http.Request('GET', Uri.parse(GET_USER_LIST));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      for (Map json in json.decode(response.body)) {
        model_user mdpn = model_user(null, json["user_id"], json["user_name"]);
        model_user? savedDealer = await _isUserAvailable(json["user_id"]);

        if (savedDealer == null) {
          dao.insertUser(mdpn);
        } else {
          dao.updateUser(
              model_user(savedDealer.id, json["user_id"], json["user_name"]));
        }
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<model_user?> _isUserAvailable(String user_id) async {
    final database = await $FloorFlutterDatabase
        .databaseBuilder('flutter_database.db')
        .build();
    final dao = database.modelUser;
    return dao.findUserById(user_id);
  }

  AlertDialog _buildExitDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm Exit",
          style: TextStyle(
            fontFamily: 'ARIAL',
          )),
      content: const Text("Are you sure you want to exit?",
          style: TextStyle(
            fontFamily: 'ARIAL',
          )),
      actions: <Widget>[
        TextButton(
          child: const Text(
            "YES",
            style: TextStyle(
              color: kReSustainabilityRed,
              fontFamily: 'ARIAL',
            ),
          ),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
        TextButton(
          child: const Text("NO",
              style: TextStyle(
                color: kReSustainabilityRed,
                fontFamily: 'ARIAL',
              )),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    bool? exitResult = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => _buildExitDialog(context),
    );
    return exitResult ?? false;
  }

  logoutAPICall(String sessionId) async {
    var headers = {'Content-Type': 'application/json', 'Cookie': sessionId};
    var request = http.Request('GET', Uri.parse(LOGOUT));
    request.body = json.encode({});
    request.headers.addAll(headers);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print("control comes here 2");
      CustomSharedPref.setPref<bool>(SharedPreferencesString.isLoggedIn, false);
      CustomSharedPref.setPref<String>(SharedPreferencesString.userId, "");
      CustomSharedPref.setPref<String>(SharedPreferencesString.emailId, "");
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
    } else {
      if (kDebugMode) {
        print(response.reasonPhrase);
      }
    }
  }
}
