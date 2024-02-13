import 'package:flutter/material.dart';

class LogOutLoader extends StatelessWidget {
  LogOutLoader();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              height: 20.0,
              width: 20.0,
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            ),
            Container(
                margin: const EdgeInsets.only(left: 5),
                child: const Text("Please Wait.\nLogout In Progress..",
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'ARIAL',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ))),
          ],
        ),
      ),
    );
  }
}
