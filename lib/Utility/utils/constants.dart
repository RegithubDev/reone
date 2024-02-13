import 'dart:io' show Platform;

import 'package:flutter/material.dart';

const kColorBlue = Color(0xff2e83f8);
const kColorDarkBlue = Color(0xff1b3a5e);
const kColorPink = Color(0xffff748d);

const kInputTextStyle = TextStyle(
    fontSize: 14,
    color: Color(0xffbcbcbc),
    fontWeight: FontWeight.w300,
    fontFamily: 'ARIAL');

const kColorPrimary = Color(0xff2e83f8);
const kColorPrimaryDark = Color(0xff1b3a5e);
const kColorSecondary = Color(0xffff748d);
const kColorDark = Color(0xff121212);
const kColorLight = Color(0xffEBF2F5);
const kColorRed = Color(0xffff0000);
const kReSustainabilityRed = Color(0xffe12228);
const kPrimaryLightColor = Color(0xFF3E4095);

// const kReSustainabilityRed = Color(0xffDB171A);

const inactiveColor = Color(0xff8b8080);
const searchFillColor = Color(0xffd6d6d6);
const protectBackgroundColor = Color(0xfff2f3f6);

const kBottomPadding = 48.0;

const kTextStyleButton = TextStyle(
  color: kReSustainabilityRed,
  fontSize: 18,
  fontWeight: FontWeight.w500,
  fontFamily: 'ARIAL',
);

const kTextStyleSubtitle1 = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  fontFamily: 'ARIAL',
);

const kTextStyleSubtitle2 = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  fontFamily: 'ARIAL',
);

const kTextStyleBody2 = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  fontFamily: 'ARIAL',
);

const kTextStyleHeadline6 = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w500,
  fontFamily: 'ARIAL',
);

const REFRESH_TOKEN_KEY = 'https://oauth2.googleapis.com/token';
const BACKEND_TOKEN_KEY = 'backend_token';
const GOOGLE_ISSUER = 'https://accounts.google.com';
const GOOGLE_CLIENT_ID_IOS =
    '180023549420-laibl7g5ebqfe7lmagf0a2aflhih2g97.apps.googleusercontent.com';
const GOOGLE_REDIRECT_URI_IOS =
    'https://appmint.resustainability.com/reirm/login';
const GOOGLE_CLIENT_ID_ANDROID =
    '180023549420-laibl7g5ebqfe7lmagf0a2aflhih2g97.apps.googleusercontent.com';
const GOOGLE_REDIRECT_URI_ANDROID =
    'https://appmint.resustainability.com/reirm/login';

String clientID() {
  if (Platform.isAndroid) {
    return GOOGLE_CLIENT_ID_ANDROID;
  } else if (Platform.isIOS) {
    return GOOGLE_CLIENT_ID_IOS;
  }
  return '';
}

String redirectUrl() {
  if (Platform.isAndroid) {
    return GOOGLE_REDIRECT_URI_ANDROID;
  } else if (Platform.isIOS) {
    return GOOGLE_REDIRECT_URI_IOS;
  }
  return '';
}
