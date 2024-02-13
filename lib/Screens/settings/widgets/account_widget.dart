import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../Utility/utils/constants.dart';

class AccountWidget extends StatelessWidget {
  final Color color;

  const AccountWidget({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          color: color,
          padding: const EdgeInsets.all(15),
          child: Text(
            'accounts'.tr(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListTile(
          leading: Text(
            'logout'.tr(),
            style: const TextStyle(
              color: kReSustainabilityRed,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(
            Icons.exit_to_app,
            color: kReSustainabilityRed,
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
