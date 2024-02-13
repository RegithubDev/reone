import 'package:flutter/material.dart';
import 'package:resus_test/AppStation/Protect/Incident_report/pending_actions.dart';
import 'package:resus_test/AppStation/Protect/ProtectOnboardScreen.dart';

import '../../../Utility/utils/constants.dart';
import 'action_taken.dart';
import 'my_ir.dart';

class IncidentTabviewScreen extends StatelessWidget {
  int selectedPage;

  IncidentTabviewScreen(this.selectedPage);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ProtectOnboard()),
            (route) => false);
        return true;
      },
      child: Material(
        child: DefaultTabController(
          initialIndex: selectedPage,
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              key: const ValueKey('tabviewContainer'),
              backgroundColor: kReSustainabilityRed,
              title: const Text(
                "Incident Report",
                style: TextStyle(
                    fontFamily: "ARIAL",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
              centerTitle: true,
              elevation: 0,
              bottom: const TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      "My IR",
                      style: TextStyle(
                          fontFamily: "ARIAL",
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Pending Actions",
                      style: TextStyle(
                          fontFamily: "ARIAL",
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Action Taken",
                      style: TextStyle(
                          fontFamily: "ARIAL",
                          fontSize: 13,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [MyIR(), PendingActions(), ActionTaken()],
            ),
          ),
        ),
      ),
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

  AlertDialog _buildExitDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Please confirm',
          style: TextStyle(color: Colors.black, fontFamily: "ARIAL")),
      content: const Text('Do you want go back?',
          style: TextStyle(color: Colors.black, fontFamily: "ARIAL")),
      actions: <Widget>[
        TextButton(
          child: const Text('No',
              style:
                  TextStyle(color: kReSustainabilityRed, fontFamily: "ARIAL")),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: () => {
            // Navigator.of(context).pop(),
            // Navigator.of(context).pop()
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ProtectOnboard()),
                (route) => false)
          },
          child: const Text(
            'Yes',
            style: TextStyle(color: kReSustainabilityRed, fontFamily: "ARIAL"),
          ),
        ),
      ],
    );
  }
}
