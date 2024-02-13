import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../Utility/MySharedPreferences.dart';
import '../../../Utility/internetConnectivityCheck.dart';
import '../../../Utility/network_error_dialogbox.dart';
import '../../../Utility/shared_preferences_string.dart';
import '../../../Utility/showDialogBox.dart';
import '../../../Utility/showLoader.dart';
import '../../../Utility/utils/constants.dart';
import '../../../custom_sharedPreference.dart';
import '../../components/custom_icons.dart';
import '../../components/labeled_text_form_field.dart';
import '../../components/social_icon.dart';
import '../../home/home.dart';
import '../loginApiCall.dart';

class SocialLoginWidget extends StatefulWidget {
  const SocialLoginWidget({Key? key}) : super(key: key);

  @override
  State<SocialLoginWidget> createState() => _SocialLoginWidgetState();
}

class _SocialLoginWidgetState extends State<SocialLoginWidget> {
  String deviceName = '';
  String deviceVersion = '';
  String identifier = '';

  final _emailController = TextEditingController(text: "@resustainability.com");

  @override
  void initState() {
    super.initState();
    _deviceDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('socialLoginContainer1'),
      children: <Widget>[
        SizedBox(
          height: 2.h,
        ),
        SocialIcon(
          colors: const [Colors.white, Colors.white],
          iconData: CustomIcons.googlePlus,
          onPressed: () async {
            googleLogin();
          },
        ),
      ],
    );
  }

  googleLogin() async {
    print("Google login method is called");
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      var result = await _googleSignIn.signIn();
      if (result!.id != null) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        LoginApiCall loginApiCall =
            LoginApiCall(result.email, deviceName, "1", packageInfo.version);
        var response = await loginApiCall.callLoginAPi();
        if (response?.statusCode == 200) {
          String output = await loginApiCall.userLogin(
              result.email, deviceName, "1", packageInfo.version);
          if (output != "") {
            MySharedPreferences.instance
                .setStringValue("GOOGLE_TOKEN", result.id);
            MySharedPreferences.instance
                .setStringValue("EMAIL_ID", result.email);
            // ignore: use_build_context_synchronously
            CustomSharedPref.setPref<bool>(
                SharedPreferencesString.isLoggedIn, true);
            CustomSharedPref.setPref<String>(
                SharedPreferencesString.userId, output);
            CustomSharedPref.setPref<String>(
                SharedPreferencesString.emailId, result.email);
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                      builder: (context) => Home(
                          googleSignInAccount: result,
                          userId: output,
                          emailId: result.email,
                          initialSelectedIndex: 0)),
                )
                .then((value) => setState(() {}));
          } else {
            googleLogout();
            // ignore: use_build_context_synchronously
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => const ShowDialogBox(
                      title:
                          'Authentication Failed, Please Enter Valid Email-Id',
                    ));
          }
        }
      }

      print(result);
    } catch (error) {
      print(error);
    }
  }

  googleLogout() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      _googleSignIn.disconnect();
    } catch (error) {
      print(error);
    }
  }

  socialLoginDialogBox() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          StreamController<String> controller =
              StreamController<String>.broadcast();
          return AlertDialog(
            title: StreamBuilder(
                stream: controller.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  return SizedBox(
                    height: 90,
                    width: 350,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LabeledTextFormField(
                              title: '',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter Your Email',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  // Text(snapshot.hasData ? snapshot.data.toString() : 'Title');
                }),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: kReSustainabilityRed,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _emailController.clear();
                        },
                        child: const Text("Cancel")),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: kReSustainabilityRed,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (BuildContext context) {
                                return ShowLoader();
                              });

                          InternetConnectivityCheck object =
                              InternetConnectivityCheck();
                          var connectivityResult = await object.checkInternet();
                          if (connectivityResult == ConnectivityResult.none) {
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                            // ignore: use_build_context_synchronously
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => const NetworkErrorDialog(),
                            );
                          } else {
                            if (_emailController.text == "") {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              // ignore: use_build_context_synchronously
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (_) => const ShowDialogBox(
                                        title: 'Please Enter Email-Id',
                                      ));
                              return;
                            }

                            PackageInfo packageInfo =
                                await PackageInfo.fromPlatform();

                            LoginApiCall loginApiCall = LoginApiCall(
                                _emailController.text,
                                deviceName,
                                "1",
                                packageInfo.version);
                          }
                        },
                        child: const Text("OK")),
                  ),
                ],
              )
            ],
          );
        });
  }

  Future<void> _deviceDetails() async {
    final DeviceInfoPlugin? deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin?.androidInfo;
        setState(() {
          deviceName = build!.model;
          deviceVersion = build.version.toString();
          // identifier = build.androidId;
        });
        //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin?.iosInfo;
        setState(() {
          deviceName = data!.name;
          deviceVersion = data.systemVersion;
          identifier = data.identifierForVendor!;
        }); //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
  }
}
