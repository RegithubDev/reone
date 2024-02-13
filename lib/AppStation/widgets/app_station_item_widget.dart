import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

class AppStationItemWidget extends StatelessWidget {
  final void Function() onTap;
  final String image;
  final String label;

  const AppStationItemWidget({
    Key? key,
    required this.onTap,
    required this.image,
    required this.label
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // icon: Image.asset('assets/images/$image.png'),
      icon: SvgPicture.asset(
        'assets/icons/$image.svg',
        semanticsLabel: 'Acme Logo',
        height: 30.h,
        width: 30.w,
      ),
      iconSize: 12.h,
      onPressed: onTap,
    );
  }
}
