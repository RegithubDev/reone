import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:resus_test/Screens/drawer/privacy_policy.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import 'package:sizer/sizer.dart';

import '../../Utility/network_error_dialogbox.dart';
import '../../Utility/showDialogBox.dart';
import '../components/custom_button.dart';
import '../components/labeled_text_form_field.dart';
import '../drawer/terms_and_conditions.dart';
import '../otp_verification/login_with_otp.dart';
import 'loginApiCall.dart';
import 'widgets/social_login_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final _emailController = TextEditingController(text: "@resustainability.com");
  TextEditingController _emailController = TextEditingController();


  String _userAgent = '<unknown>';

  String deviceName = '';
  String deviceVersion = '';
  String identifier = '';

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  List<String> suggestons = ["@resustainability.com"];

  @override
  void initState() {
    getConnectivity();
    super.initState();
    _deviceDetails();
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

  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: const ValueKey('loginContainer'),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Padding(
            padding:  EdgeInsets.only(bottom: 45.0.h),
            child: Center(
              child: Image.asset(
                'assets/images/reone_logo_updated.png',
                height: height * 0.03.h,
                scale: 0.09.h,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 380),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              color: kReSustainabilityRed,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.only(top: 40.h, left: 3.h, right: 3.h),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 13.h,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'ARIAL',
                            color: Colors.white),
                      ),
                      LabeledTextFormField(
                        key: const Key('email'),
                        title: '',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'Resustainability Email Only',
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    key: const Key('login_btn'),
                    onPressed: () async {
                      if (_emailController.text == "") {
                        // ignore: use_build_context_synchronously
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => const ShowDialogBox(
                                  title: 'Please Enter Email-Id',
                                ));
                        return;
                      }
                      if (!_emailController.text.contains("@resustainability.com")) {
                        // ignore: use_build_context_synchronously
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => const ShowDialogBox(
                              title: 'Invalid Email-Id. \nPlease Use Only Resustainability Email-Id.',
                            ));
                        return;
                      }

                      var isConnected =
                          await Future.value(checkInternetConnection())
                              .timeout(const Duration(seconds: 2));
                      if (!isConnected) {
                        Navigator.of(context).pop();
                        // ignore: use_build_context_synchronously
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) => const NetworkErrorDialog());
                        return;
                      }

                      PackageInfo packageInfo =
                          await PackageInfo.fromPlatform();
                      LoginApiCall loginApiCall = LoginApiCall(
                          _emailController.text,
                          deviceName,
                          "1",
                          packageInfo.version);

                      var response = await loginApiCall.callLoginAPi();
                      if (response?.statusCode == 200) {
                        String output = await loginApiCall.userLogin(
                            _emailController.text,
                            deviceName,
                            "1",
                            packageInfo.version);
                        if (output != "") {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginWithOtpScreen(
                                  emailId: _emailController.text.toString())));
                        } else {
                          // ignore: use_build_context_synchronously
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => const ShowDialogBox(
                                    title:
                                        'Authentication failed.\nPlease Enter a Valid Email-Id.',
                                  ));
                        }
                      }
                    },
                    text: 'Continue to Get OTP'.tr(),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                   Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Or",
                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Login With',
                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                      )
                    ],
                  ),
                  Center(child: SocialLoginWidget()),
                  const SizedBox(
                    height: 10,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 35.0),
                  //   child: Align(
                  //     alignment: FractionalOffset.bottomCenter,
                  //     child: Column(
                  //       children: [
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             TextButton(
                  //                 onPressed: () async {
                  //                   Navigator.push(
                  //                     context,
                  //                     MaterialPageRoute(
                  //                       builder: (context) {
                  //                         return TermsAndConditions();
                  //                       },
                  //                     ),
                  //                   );
                  //                 },
                  //                 child: Container(
                  //                   decoration: BoxDecoration(
                  //                     border: Border(bottom: BorderSide(
                  //                       color: Colors.white,
                  //                       width: 1.0, // Underline thickness
                  //                     ))
                  //                   ),
                  //                   child: Text(
                  //                     "Terms and Conditions",
                  //                     style: TextStyle(
                  //                       // decoration: TextDecoration.underline,
                  //                         color: Colors.grey.shade300, fontSize: 14),
                  //                   ),
                  //                 )),
                  //             const Text(
                  //               "&",
                  //               style: TextStyle(color: Colors.white, fontSize: 14),
                  //             ),
                  //             TextButton(
                  //                 onPressed: () async {
                  //                   Navigator.push(
                  //                     context,
                  //                     MaterialPageRoute(
                  //                       builder: (context) {
                  //                         return PrivacyPolicy();
                  //                       },
                  //                     ),
                  //                   );
                  //                 },
                  //                 child: Container(
                  //                   decoration: BoxDecoration(
                  //                       border: Border(bottom: BorderSide(
                  //                         color: Colors.white,
                  //                         width: 1.0, // Underline thickness
                  //                       ))
                  //                   ),
                  //                   child: Text(
                  //                     "Privacy Policy",
                  //                     style: TextStyle(
                  //                         color: Colors.grey.shade300, fontSize: 14),
                  //                   ),
                  //                 )),
                  //           ],
                  //         ),
                  //         FutureBuilder<PackageInfo>(
                  //           future: PackageInfo.fromPlatform(),
                  //           builder: (context, snapshot) {
                  //             switch (snapshot.connectionState) {
                  //               case ConnectionState.done:
                  //                 return Align(
                  //                   alignment: Alignment.center,
                  //                   child: Row(
                  //                     mainAxisAlignment: MainAxisAlignment.center,
                  //                     children: [
                  //                       Text(
                  //                           ' V${snapshot.data!.version}',
                  //                           style: const TextStyle(
                  //                             fontFamily: 'PTSans-Bold',
                  //                             color: Colors.white,
                  //                             fontSize: 14,
                  //                             fontWeight: FontWeight.normal, // italic
                  //                           )),
                  //                       const SizedBox(width: 1,),
                  //                       const Icon(Icons.copyright,color: Colors.white,size: 14,),
                  //                       const Text(
                  //                           ' 2023 ',
                  //                           style: TextStyle(
                  //                             fontFamily: 'PTSans-Bold',
                  //                             color: Colors.white,
                  //                             fontSize: 14,
                  //                             fontWeight: FontWeight.normal, // italic
                  //                           )),
                  //                       SizedBox(width: 1,),
                  //                       SvgPicture.asset(
                  //                         'assets/icons/re.svg',
                  //                         height: 11.5,
                  //                         width: 11.5,
                  //                         color: Colors.white,
                  //                       )
                  //
                  //                     ],
                  //                   ),
                  //                 );
                  //               default:
                  //                 return const SizedBox();
                  //             }
                  //           },
                  //         ),
                  //       ]
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: kReSustainabilityRed,
        height: 10.h,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return TermsAndConditions();
                          },
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(
                            color: Colors.white,
                            width: 1.0, // Underline thickness
                          ))
                      ),
                      child: Text(
                        "Terms and Conditions",
                        style: TextStyle(
                          // decoration: TextDecoration.underline,
                            color: Colors.grey.shade300, fontSize: 11.sp),
                      ),
                    )),
                 Text(
                  "&",
                  style: TextStyle(color: Colors.white, fontSize: 11.sp),
                ),
                TextButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PrivacyPolicy();
                          },
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(
                            color: Colors.white,
                            width: 1.0, // Underline thickness
                          ))
                      ),
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(
                            color: Colors.grey.shade300, fontSize: 11.sp),
                      ),
                    )),
              ],
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              ' V${snapshot.data!.version}',
                              style:  TextStyle(
                                fontFamily: 'PTSans-Bold',
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.normal, // italic
                              )),
                          const SizedBox(width: 1,),
                          Icon(Icons.copyright,color: Colors.white,size: 11.sp,),
                           Text(
                              ' 2023 ',
                              style: TextStyle(
                                fontFamily: 'PTSans-Bold',
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.normal, // italic
                              )),
                          SizedBox(width: 1,),
                          SvgPicture.asset(
                            'assets/icons/re.svg',
                            height: 1.5.h,
                            width: 1.5.h,
                            color: Colors.white,
                          )

                        ],
                      ),
                    );
                  default:
                    return const SizedBox();
                }
              },
            ),

          ],
        ),
      ),

    );
  }

  Future<bool> checkInternetConnection() async {
    bool isConnected = true;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }

  Future<void> _deviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceName = build.model;
          deviceVersion = build.version.toString();
        });
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceName = data.name;
          deviceVersion = data.systemVersion;
          identifier = data.identifierForVendor!;
        }); //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
  }

  static Size boundingTextSize(String text, TextStyle style,
      {int maxLines = 2 ^ 31, double maxWidth = double.infinity}) {
    if (text.isEmpty) {
      return Size.zero;
    }
    final TextPainter textPainter = TextPainter(
        textDirection: ui.TextDirection.ltr,
        text: TextSpan(text: text, style: style),
        maxLines: maxLines)
      ..layout(maxWidth: maxWidth);
    return textPainter.size;
  }

  Widget email() {
    return Container(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: _emailController,
              onChanged: (text) {
                setState(() {});
              },
            ),
            Positioned(
              left: boundingTextSize(
                      _emailController.text,
                      const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white))
                  .width,
              child: Visibility(
                  visible: _emailController.text.isNotEmpty,
                  child: const Text(
                    "@resustainability.com",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ],
        ));
  }
}
