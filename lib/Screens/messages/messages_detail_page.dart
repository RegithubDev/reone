import 'package:flutter/material.dart';
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utility/utils/constants.dart';

class MessagesDetailPage extends StatefulWidget {
  @override
  _MessagesDetailPageState createState() => _MessagesDetailPageState();
}

class _MessagesDetailPageState extends State<MessagesDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Row(
            children: <Widget>[
              SizedBox(
                key: const ValueKey('chatcontainer1'),
                width: 40,
                height: 40,
                child: Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: kReSustainabilityRed,
                      child: FutureBuilder(
                          future: getStringValue('user_name'),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                '${snapshot.data.toString()[0]}'.titleCase,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontFamily: 'ARIAL',
                                  fontWeight: FontWeight.bold, // italic
                                ),
                              );
                              // your widget
                            } else {
                              return const CircularProgressIndicator();
                            }
                          }),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        key: const ValueKey('chatcontainer2'),
                        margin: const EdgeInsets.all(2),
                        padding: const EdgeInsets.all(1),
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              FutureBuilder(
                  future: getStringValue('user_name'),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data.toString().titleCase,
                          textAlign: TextAlign.left,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2!
                              .copyWith(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontFamily: 'ARIAL')); // your widget
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
            ],
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.phone,
                color: kReSustainabilityRed,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.info,
                color: kReSustainabilityRed,
              ),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            const Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      MessageItem(
                        send: false,
                        message: 'Hello',
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      MessageItem(
                        send: true,
                        message: 'Hello How are you?',
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      MessageItem(
                        send: false,
                        message: 'Fine \nIncident Submitted',
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      MessageItem(
                        send: false,
                        message: 'Don\'t forget to Review.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Container(
                key: const ValueKey('chatcontainer3'),
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!, width: 0.5),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.attach_file,
                        size: 25,
                        color: kReSustainabilityRed,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 25,
                        color: kReSustainabilityRed,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[250],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          hintText: 'Enter message',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                        autofocus: false,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        cursorWidth: 1,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.send,
                        size: 25,
                        color: kReSustainabilityRed,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }
}

class MessageItem extends StatelessWidget {
  final bool send;
  final String message;

  const MessageItem({Key? key, required this.send, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: send ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Visibility(
          visible: !send,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: kReSustainabilityRed,
            child: FutureBuilder(
                future: getStringValue('user_name'),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      '${snapshot.data.toString()[0]}'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontFamily: 'ARIAL',
                        fontWeight: FontWeight.bold, // italic
                      ),
                    );
                    // your widget
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          ),
        ),
        Flexible(
          child: Container(
            key: const ValueKey('chatcontainer4'),
            margin: EdgeInsets.only(
              left: !send ? 5 : (MediaQuery.of(context).size.width / 2) - 80,
              right: send ? 5 : (MediaQuery.of(context).size.width / 2) - 80,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(send ? 20 : 0),
                bottomRight: Radius.circular(send ? 0 : 20),
              ),
              color: send ? const Color(0xffeaf2fe) : kReSustainabilityRed,
            ),
            child: SelectableText(
              message,
              style: TextStyle(
                color: send ? kColorDarkBlue : Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        Visibility(
          visible: send,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: kReSustainabilityRed,
            child: FutureBuilder(
                future: getStringValue('user_name'),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      '${snapshot.data.toString()[0]}'.titleCase,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontFamily: 'ARIAL',
                        fontWeight: FontWeight.bold, // italic
                      ),
                    );
                    // your widget
                  } else {
                    return const CircularProgressIndicator();
                  }
                }),
          ),
        ),
      ],
    );
  }

  Future<String> getStringValue(String key) async {
    SharedPreferences myPrefs = await SharedPreferences.getInstance();
    return myPrefs.getString(key) ?? "";
  }
}
