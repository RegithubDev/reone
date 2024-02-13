import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:root/root.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'Screens/routes/route_generator.dart';
import 'Screens/routes/routes.dart';
import 'Utility/MyHttpOverrides.dart';
import 'Utility/MySharedPreferences.dart';
import 'Utility/api_Url.dart';
import 'Utility/utils/themebloc/theme_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await EasyLocalization.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // var session = prefs.getString('JSESSIONID');

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://34fd60e014724a48b7d021a9f817bf72@o4505425767628800.ingest.sentry.io/4505425811341312';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 0.01;
    },
    appRunner: () => runApp(
      //   DevicePreview(
      //   enabled: !kReleaseMode,
      //   builder: (context) => EasyLocalization(
      //     supportedLocales: const [
      //       Locale('en', 'US'),
      //       //Locale('de', 'DE'),
      //       //Locale('ar', 'DZ'),
      //       Locale('es', 'ES'),
      //       Locale('it', 'IT'),
      //       Locale('pt', 'PT'),
      //       //Locale('fr', 'FR'),
      //     ],
      //     path: 'assets/languages',
      //     // child: MaterialApp(
      //     //     debugShowCheckedModeBanner: false,
      //     //     home: session == null ? MyApp() : Home()),
      //
      //     child: MyApp(),
      //
      //   ), // Wrap your app
      // ),

      EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('es', 'ES'),
          Locale('it', 'IT'),
          Locale('pt', 'PT'),
          //Locale('fr', 'FR'),
        ],
        path: 'assets/languages',
        child: MyApp(),
        // MaterialApp(
        //     debugShowCheckedModeBanner: false,
        //     home: session == null ? MyApp() : Home(googleSignInAccount: null, userId: '', emailId: '',)),
      ), // Wrap your
    ),
  );
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  if (defaultTargetPlatform == TargetPlatform.android) {
  } else if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {}
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    String latestNotification = "";
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    MySharedPreferences.instance.setStringValue("notification_last_sync_time",
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()));

    String user_id = prefs.getString('user_id') ?? '54321';
    if ((prefs.getString('JSESSIONID') ?? '') != "") {
      final response = await http.post(Uri.parse(GET_NOTIFICATION_LIST),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.cookieHeader: prefs.getString('JSESSIONID') ?? ''
          },
          body: jsonEncode({
            "user": user_id,
            "last_sync_time": prefs.getString("notification_last_sync_time")
          }),
          encoding: Encoding.getByName("utf-8"));

      if (response.statusCode == 200 && response.body != "[]") {
        latestNotification = jsonDecode(response.body)[0]["message"];
      } else {
        latestNotification = "Loading...";

        throw Exception('Failed to load post');
      }
    }
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'RE Notifications',
          latestNotification,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOxREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _status = false;

  @override
  void initState() {
    super.initState();
    checkRoot();
  }

  //Check Root status
  Future<void> checkRoot() async {
    bool? result = await Root.isRooted();
    if(mounted==true){
      setState(() {
        _status = result!;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return BlocProvider(
        create: (context) => ThemeBloc(),
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: _buildWithTheme,
        ),
      );
    });
  }

  Widget _buildWithTheme(BuildContext context, ThemeState state) {
    return MaterialApp(
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child!,
        );
      },
      title: 'Re-Sustainability',
      initialRoute: Routes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
      localizationsDelegates: [
        EasyLocalization.of(context)!.delegate,
      ],
      supportedLocales: EasyLocalization.of(context)!.supportedLocales,
      locale: EasyLocalization.of(context)!.locale,
      debugShowCheckedModeBanner: false,
      theme: state.themeData,
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
