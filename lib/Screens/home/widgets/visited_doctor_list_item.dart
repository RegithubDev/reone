import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VisitedDoctorListItem extends StatefulWidget {
  final GoogleSignInAccount? googleSignInAccount;
  final String userId;
  final String emailId;

  const VisitedDoctorListItem(
      {required this.googleSignInAccount,
      required this.userId,
      required this.emailId});

  @override
  State<VisitedDoctorListItem> createState() =>
      _VisitedDoctorListItemState(googleSignInAccount, userId, emailId);
}

class _VisitedDoctorListItemState extends State<VisitedDoctorListItem> {
  GoogleSignInAccount? m_googleSignInAccount;
  String m_user_id;
  String m_emailId;

  _VisitedDoctorListItemState(
      this.m_googleSignInAccount, this.m_user_id, this.m_emailId);

  set _controller(WebViewController _controller) {}

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
        initialUrl = "https://appmint.resustainability.com/reirm/home";
      });
    } else {
      setState(() {
        initialUrl =
            "https://appmint.resustainability.com/reirm/login/$m_emailId";
      });
    }

    super.initState();

    refreshController = PullToRefreshController(
        onRefresh: () {
          webViewController!.reload();
        },
        options: PullToRefreshOptions(
            color: Colors.white, backgroundColor: Colors.black));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('visitedContainer'),
      width: 40.w,
      height: 60.h,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Color(0x0c000000),
              offset: Offset(0, 5),
              blurRadius: 5,
              spreadRadius: 0),
          BoxShadow(
              color: Color(0x0c000000),
              offset: Offset(0, -5),
              blurRadius: 5,
              spreadRadius: 0),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                height: 200,
                width: 150,
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
                )),
          ],
        ),
      ),
    );
  }
}
