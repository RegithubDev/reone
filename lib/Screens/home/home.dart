import 'dart:convert';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:resus_test/AppStation/AppStationDashBoard.dart';
import 'package:resus_test/Screens/home/rewards.dart';
import 'package:resus_test/Screens/home/widgets/help_desk.dart';
import 'package:resus_test/Screens/home/widgets/nav_bar_item_widget.dart';
import 'package:resus_test/Utility/utils/constants.dart';

import '../../data/pref_manager.dart';
import '../drawer/drawer.dart';
import '../notification/notification.dart';
import 'home_page.dart';
import 'widgets/widgets.dart';

class Home extends StatefulWidget {
  final GoogleSignInAccount? googleSignInAccount;
  final String userId;
  final String emailId;
  int? initialSelectedIndex = 0;

  Home(
      {required this.googleSignInAccount,
      required this.userId,
      required this.emailId,
      required this.initialSelectedIndex});

  @override
  _HomeState createState() =>
      _HomeState(googleSignInAccount, userId, emailId, initialSelectedIndex!);
}

class _HomeState extends State<Home> {
  GoogleSignInAccount? m_googleSignInAccount;
  String m_UserId;
  String m_emailId;
  int m_selectedIndex;

  _HomeState(this.m_googleSignInAccount, this.m_UserId, this.m_emailId,
      this.m_selectedIndex);

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isDrawerOpen = false;

  late PageController? _pageController;
  final websiteUri = Uri.parse(
      "https://play.google.com/store/apps/details?id=com.google.android.apps.dynamite");

  @override
  void initState() {
    _pageController = PageController(
      initialPage: m_selectedIndex!,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController?.dispose();
    _googleSignIn.signInSilently();
    if (m_googleSignInAccount != null) {
      _handleGetContact(m_googleSignInAccount!);
    }
  }

  _selectPage(int index) {
    if (_pageController!.hasClients) _pageController!.jumpToPage(index);
    setState(() {
      m_selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _pages = [
      HomePage(
          googleSignInAccount: m_googleSignInAccount,
          userId: m_UserId,
          emailId: m_emailId),
      HelpDesk(),
      Container(),
      Container(),
      const AppStation(),
    ];
    return Stack(
      key: const ValueKey('homeContainer'),
      children: <Widget>[
        DrawerPage(
          key: const Key("btn_drawer_page"),
          onTap: () {
            setState(
              () {
                xOffset = 0;
                yOffset = 0;
                scaleFactor = 1;
                isDrawerOpen = false;
              },
            );
          },
        ),
        AnimatedContainer(
          transform: Matrix4.translationValues(xOffset, yOffset, 0)
            ..scale(scaleFactor)
            ..rotateY(isDrawerOpen ? -0.5 : 0),
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.white,
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: kReSustainabilityRed,
                elevation: 0.0,
                leading: isDrawerOpen
                    ? IconButton(
                        key: const Key("back_button"),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              xOffset = 0;
                              yOffset = 0;
                              scaleFactor = 1;
                              isDrawerOpen = false;
                            },
                          );
                        },
                      )
                    : IconButton(
                        key: const Key("hamburger_btn"),
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            xOffset = size.width - size.width / 3;
                            yOffset = size.height * 0.1;
                            scaleFactor = 0.8;
                            isDrawerOpen = true;
                          });
                        },
                      ),
                title: AppBarTitleWidget(),
                actions: <Widget>[
                  m_selectedIndex == 2
                      ? IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add,
                          ),
                        )
                      : Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: InkWell(
                                key: const Key("home_icon_btn"),
                                child:
                                    const Icon(Icons.home, color: Colors.white),
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
                            GestureDetector(
                              child: SvgPicture.asset(
                                  'assets/icons/tropy icon.svg',
                                  color: Colors.white,
                                  semanticsLabel: 'Acme Logo'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const RewardsScreen();
                                    },
                                  ),
                                );
                              },
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
                                String? notification_count =
                                    data.length.toString();

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
                                              padding: EdgeInsets.only(
                                                  right: 1.0, top: 3.5),
                                              child: Icon(
                                                Icons
                                                    .notifications_none_outlined,
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
                                                      width: 1.0,
                                                      color: Colors.white),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 1.0,
                                                              bottom: 1.0),
                                                      child: Text(
                                                        notification_count!,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 7.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    m_selectedIndex = index;
                  });
                },
                children: _pages,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                backgroundColor: kReSustainabilityRed,
                child: SvgPicture.asset(
                  'assets/icons/reone.svg',
                  semanticsLabel: 'Acme Logo',
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                    color: Color(0xfff2f3f6),
                    // color: Colors.transparent,
                    border: Border(
                        top: BorderSide(color: Colors.white, width: 0.0))),
                child: BottomAppBar(
                  color:
                      Prefs.isDark() ? const Color(0xff121212) : Colors.white,
                  surfaceTintColor: kReSustainabilityRed,
                  shape: const CircularNotchedRectangle(),
                  notchMargin: 10,
                  child: Row(
                    //children inside bottom appbar
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      NavBarItemWidget(
                        onTap: () {
                          // _selectPage(0);
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                                builder: (context) => Home(
                                    googleSignInAccount: null,
                                    userId: '',
                                    emailId: '',
                                    initialSelectedIndex: 0)),
                          );

                        },
                        image: 'new_home',
                        isSelected: m_selectedIndex == 0,
                        label: 'Home',
                      ),
                      NavBarItemWidget(
                        onTap: () async {
                          _selectPage(1);
                        },
                        image: 'new_helpdesk',
                        isSelected: m_selectedIndex == 1,
                        label: 'Help desk',
                      ),
                      NavBarItemWidget(
                        onTap: () {
                          _selectPage(3);
                        },
                        image: '',
                        isSelected: false,
                        label: '',
                      ),
                      NavBarItemWidget(
                        onTap: () async {
                          var openAppResult = await LaunchApp.openApp(
                            androidPackageName:
                                'com.google.android.apps.dynamite',
                            appStoreLink:
                                'https://play.google.com/store/apps/details?id=com.google.android.apps.dynamite',
                          );
                          print(
                              'openAppResult => $openAppResult ${openAppResult.runtimeType}');
                        },
                        image: 'new_chat',
                        isSelected: m_selectedIndex == 3,
                        label: 'Chat',
                      ),
                      NavBarItemWidget(
                        onTap: () {
                          _selectPage(4);
                        },
                        image: 'new_appstation',
                        isSelected: m_selectedIndex == 4,
                        label: 'App station',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '180023549420-laibl7g5ebqfe7lmagf0a2aflhih2g97.apps.googleusercontent.com',
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/calendar.readonly \ https://www.googleapis.com/auth/contacts.readonly'
    ],
  );

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {});
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {});
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
      } else {}
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final List<dynamic> names = contact['names'] as List<dynamic>;
      final Map<String, dynamic>? name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }
}
