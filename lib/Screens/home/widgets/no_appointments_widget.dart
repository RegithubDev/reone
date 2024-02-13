import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../Utility/utils/constants.dart';

class NoAppointmentsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Image.asset('assets/images/icon_no_appointments.png'),
          const SizedBox(
            height: 10,
          ),
          Text(
            'there_is_no_appontments'.tr(),
            style: const TextStyle(
              color: kColorDarkBlue,
              fontSize: 20,
              fontFamily: 'ARIAL',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'create_new_appointment'.tr(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontFamily: 'ARIAL',
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          const SizedBox(
            height: 100,
            child: Icon(
              Icons.arrow_downward,
              color: kReSustainabilityRed,
            ),
          ),
        ],
      ),
    );
  }
}
