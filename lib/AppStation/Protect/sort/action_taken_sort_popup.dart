import 'package:flutter/material.dart';
import 'package:resus_test/Utility/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../../Utility/OptionRadio.dart';

class ActionTakenSortPopup extends StatefulWidget {
  const ActionTakenSortPopup({Key? key}) : super(key: key);

  @override
  State<ActionTakenSortPopup> createState() => _ActionTakenSortPopupState();
}

class _ActionTakenSortPopupState extends State<ActionTakenSortPopup> {
  String sort_key = "";
  late int selectedButton = 5;
  int selectedIndex = 0;


  Future<bool> saveSwitchState(int value, String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
    return prefs.setInt(key, value);
  }

  getSwitchValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedButton = prefs.getInt("selected_item")!;
    });
  }

  @override
  void initState() {
    super.initState();
    // getSwitchValues();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const ValueKey('actionTakenDialog'),
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Sort',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24, right: 24, bottom: 10),
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: kReSustainabilityRed),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 15.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            thickness: 1,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.only(left:10,top: 20),
            child: Row(
              children: [
                Radio(
                    value: "radio value",
                    groupValue: "group value",
                    onChanged: (value){
                      print(value); //selected value
                    }
                ),
                SizedBox(width: 15,),
                Text("Incident #",
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  softWrap: true,),
                SizedBox(width: 10,),
                ToggleSwitch(
                  fontSize: 11,
                  minWidth: 45.0,
                  minHeight: 25,
                  initialLabelIndex: selectedIndex,
                  cornerRadius: 20.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey,
                  inactiveFgColor: Colors.white,
                  totalSwitches: 2,
                  changeOnTap: true,
                  labels: ['Asc', 'Desc'],
                  // icons: [FontAwesomeIcons.mars, FontAwesomeIcons.venus],
                  activeBgColors: [[kReSustainabilityRed],[kReSustainabilityRed]],
                  onToggle: (index) {
                    setState(() {
                      if(index==0){
                        sort_key ='Asc';
                      }else if(index==1){
                        sort_key ='Desc';
                      }
                      selectedIndex = index!;
                    });
                  },

                ),

              ],
            ),
          ),
          OptionRadio(
              text: 'Status',
              index: 1,
              selectedButton: selectedButton,
              press: (val) {
                selectedButton = val;
                setState(() {
                  sort_key = 'Status';
                  saveSwitchState(val, 'selected_item');
                });
              }),
          OptionRadio(
              text: 'Project',
              index: 2,
              selectedButton: selectedButton,
              press: (val) {
                selectedButton = val;
                setState(() {
                  sort_key = 'Project';
                  saveSwitchState(val, 'selected_item');
                });
              }),
          OptionRadio(
              text: 'Incident Type',
              index: 3,
              selectedButton: selectedButton,
              press: (val) {
                selectedButton = val;
                setState(() {
                  sort_key = 'Incident Type';
                  saveSwitchState(val, 'selected_item');
                });
              }),
          Center(
            child: TextButton(
                onPressed: () {
                  Navigator.pop(context, sort_key);
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                      color: kReSustainabilityRed,
                      fontFamily: "ARIAL",
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                )),
          )
        ],
      ),
    );
  }
}
