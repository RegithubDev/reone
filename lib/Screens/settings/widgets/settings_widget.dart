import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({
    Key? key,
    required MaterialColor color,
  }) : super(key: key);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  bool _healthTips = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          color: Colors.grey.shade300,
          padding: const EdgeInsets.all(15),
          child: Text(
            'settings'.tr(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListTile(
            leading: Text(
              'Get Help'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () {}
            ),
        ListTile(
            leading: Text(
              'Send Feedback'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () {}),
      ],
    );
  }
}
