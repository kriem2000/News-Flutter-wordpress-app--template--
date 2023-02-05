// ignore_for_file: unnecessary_null_comparison

import 'package:connectivity/connectivity.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Demo_Localization.dart';
import 'package:news/Helper/String.dart';
import 'package:news/Helper/Widgets.dart';
import 'package:news/Home.dart';
import 'package:news/Login.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

//prefrence string set using this function
setPrefrence(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

//prefrence string get using this function
Future<String?> getPrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

//prefrence boolean set using this function
setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

//prefrence boolean get using this function
Future<bool> getPrefrenceBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

setPrefrenceList(String key, String query) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? valueList = await getPrefrenceList(key);
  if (!valueList!.contains(query)) {
    if (valueList.length > 4) valueList.removeAt(0);
    valueList.add(query);

    prefs.setStringList(key, valueList);
  }
}

Future<List<String>?> getPrefrenceList(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(key);
}

//check network available or not
Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

contentShimmer(BuildContext context) {
  //bookmarks
  return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: Colors.grey,
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(
          top: 15.0,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          //  BouncingScrollPhysics(),
          itemBuilder: (_, i) => Padding(
              padding: EdgeInsetsDirectional.only(
                top: i == 0 ? 0 : 15.0,
              ), //start: 10, end: 10
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey.withOpacity(0.6)),
                  height: 215.0,
                ),
              ])),
          itemCount: 6,
        ),
      ));
}

contentWithBottomTextShimmer(BuildContext context) {
  //videos,Subcategory & TagsPage
  return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: Colors.grey,
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(
          top: 0.0,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          // BouncingScrollPhysics(),
          itemBuilder: (_, i) => Padding(
              padding: EdgeInsetsDirectional.only(
                  top: i == 0 ? 0 : 15.0, start: 10, end: 10),
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                    top: deviceHeight! / 35.0, start: 10.0, end: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              height: ContainerHeight,
                              // deviceHeight! / 4.2, //deviceWidth! / 3.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.grey.withOpacity(0.6)),
                            )),
                        Positioned.directional(
                          textDirection: Directionality.of(context),
                          bottom: 7.0,
                          start: 7.0,
                          child: SizedBox(
                              height: 16.0,
                              child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: 2,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: index == 0 ? 0 : 5.5),
                                        child: Container(
                                          /* height: 16.0,
                                          width: 45, */
                                          height: 20.0,
                                          width: 65,
                                          alignment: Alignment.center,
                                          padding: EdgeInsetsDirectional.only(
                                              start: 3.0, end: 3.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10.0),
                                                bottomLeft:
                                                    Radius.circular(10.0)),
                                            color: colors.tempboxColor
                                                .withOpacity(0.85),
                                          ),
                                        ));
                                  })),
                        ),
                      ],
                    ),
                    Container(
                      width: deviceWidth!,
                      height: 10.0,
                      margin: EdgeInsetsDirectional.only(
                          top: 4.0, start: 5.0, end: 5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey.withOpacity(0.6)),
                    ),
                    Container(
                      width: deviceWidth! / 2.0,
                      height: 10.0,
                      margin: EdgeInsetsDirectional.only(
                          top: 4.0, start: 5.0, end: 5.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey.withOpacity(0.6)),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                              top: 4.0, start: 5.0, end: 5.0),
                          child: Container(
                            width: deviceWidth! / 10.0,
                            height: 10.0,
                            padding: EdgeInsetsDirectional.only(
                                top: 4.0, start: 5.0, end: 5.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.grey.withOpacity(0.6)),
                          ),
                        ),
                        Expanded(
                          //last Row
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: deviceWidth! / 20.0,
                                height: 20.0,
                                padding: EdgeInsetsDirectional.only(
                                    top: 4.0, start: 5.0, end: 5.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.grey.withOpacity(0.6)),
                              ),
                              SizedBox(width: deviceWidth! / 99.0),
                              Container(
                                width: deviceWidth! / 20.0,
                                height: 20.0,
                                padding: EdgeInsetsDirectional.only(
                                    top: 4.0, start: 5.0, end: 5.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.grey.withOpacity(0.6)),
                              ),
                              SizedBox(width: deviceWidth! / 99.0),
                              Container(
                                width: deviceWidth! / 20.0,
                                height: 20.0,
                                padding: EdgeInsetsDirectional.only(
                                    top: 4.0, start: 5.0, end: 5.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Colors.grey.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          itemCount: 6,
        ),
      ));
}

placeHolder() {
  return Image.asset("assets/images/placeholder.png");
}

//network image in error
errorWidget(double height, double width) {
  return Image.asset(
    "assets/images/placeholder.png",
    height: height,
    width: width,
  );
}

//set circular progress here
Widget showCircularProgress(bool _isProgress, Color color) {
  if (_isProgress) {
    return Center(
        child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(color),
    ));
  }
  return SizedBox.shrink();
  /* Container(
    height: 0.0,
    width: 0.0,
  ); */
}

showSnackBar(String msg, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      duration: const Duration(milliseconds: 1000), //bydefault 4000 ms
      backgroundColor: isDark! ? colors.tempdarkColor : colors.bgColor,
      elevation: 1.0,
    ),
  );
}

loginRequired(BuildContext context) {
  showSnackBar(getTranslated(context, 'login_req_msg')!, context);
  Future.delayed(Duration(milliseconds: 1000), () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  });
}

//set prefrence in user details
Future<void> saveUserDetail(String id, String name, String email, String mobile,
    String profile, String type, String status, String role) async {
  final waitList = <Future<void>>[];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  waitList.add(prefs.setString(ID, id));
  waitList.add(prefs.setString(NAME, name));
  waitList.add(prefs.setString(EMAIL, email));
  waitList.add(prefs.setString(MOBILE, mobile));
  waitList.add(prefs.setString(PROFILE, profile));
  waitList.add(prefs.setString(TYPE, type));
  waitList.add(prefs.setString(STATUS, status));
  waitList.add(prefs.setString(ROLE, role));
  await Future.wait(waitList);
}

//set language code
Future<Locale> setLocale(String? languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LANGUAGE_CODE, languageCode!);
  return _locale(languageCode);
}

//get language code
Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String? languageCode = _prefs.getString(LANGUAGE_CODE) == null
      ? "en"
      : _prefs.getString(LANGUAGE_CODE);
  return _locale(languageCode!);
}

//change language code from list
Locale _locale(String languageCode) {
  switch (languageCode) {
    case "en":
      return Locale("en", "US");
    case "es":
      return Locale("es", "ES");
    case "hi":
      return Locale("hi", "IN");
    case "tr":
      return Locale("tr", "TR");
    case "pt":
      return Locale("pt", "PT");
    case "ar":
      return Locale("ar", "DZ");
    case "he":
      return Locale("he", "HE");
    default:
      return Locale("en", "US");
  }
}

//create dynamic link that used in share specific news
Future<void> createDynamicLink(BuildContext context, String id, int index,
    String title, bool isVideoId, bool isBreakingNews) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: deepLinkUrlPrefix,
    link: Uri.parse(
        'https://$deepLinkName/?id=$id&index=$index&isVideoId=$isVideoId&isBreakingNews=$isBreakingNews'),
    androidParameters: AndroidParameters(
      packageName: packageName,
      minimumVersion: 1,
    ),
    iosParameters: IOSParameters(
      bundleId: iosPackage,
      minimumVersion: '1',
      appStoreId: appStoreId,
    ),
  );

  final ShortDynamicLink shortenedLink =
      await FirebaseDynamicLinks.instance.buildShortLink(parameters);
  var str =
      "$title\n\n$appName\n\n${getTranslated(context, 'share_msg')!}\n\nAndroid:\n"
      "$androidLink$packageName\n\n iOS:\n$iosLink";

  final Uri shortUrl = shortenedLink.shortUrl;

  Share.share(shortUrl.toString(), subject: str);
}

//translate string based on language code
String? getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context)!.translate(key);
}

//clear all prefrences
Future<void> clearUserSession() async {
  final waitList = <Future<void>>[];

  SharedPreferences prefs = await SharedPreferences.getInstance();

  waitList.add(prefs.remove(ID));
  waitList.add(prefs.remove(NAME));
  waitList.add(prefs.remove(EMAIL));
  CUR_USERID = "";
  CUR_USERNAME = "";
  CUR_USEREMAIL = "";
  CATID = "";

  await prefs.clear();
  setPrefrenceBool(ISFIRSTTIME, true); //for Intro Screens
}

//set convert date time
String? convertToAgo(BuildContext context, DateTime input, int from) {
  Duration diff = DateTime.now().difference(input);

  if (diff.inDays >= 1) {
    if (from == 0) {
      var newFormat = DateFormat("dd MMMM yyyy");
      final newsDate1 = newFormat.format(input);
      return newsDate1;
    } else if (from == 1) {
      return "${diff.inDays} ${getTranslated(context, 'days')} ${getTranslated(context, 'ago')}";
    } else if (from == 2) {
      var newFormat = DateFormat("dd MMMM yyyy HH:mm:ss");
      final newsDate1 = newFormat.format(input);
      return newsDate1;
    }
  } else if (diff.inHours >= 1) {
    if (input.minute == 00) {
      return "${diff.inHours} ${getTranslated(context, 'hours')} ${getTranslated(context, 'ago')}";
    } else {
      if (from == 2) {
        return "${getTranslated(context, 'about')} ${diff.inHours} ${getTranslated(context, 'hours')} ${input.minute} ${getTranslated(context, 'minutes')} ${getTranslated(context, 'ago')}";
      } else {
        return "${diff.inHours} ${getTranslated(context, 'hours')} ${input.minute} ${getTranslated(context, 'minutes')} ${getTranslated(context, 'ago')}";
      }
    }
  } else if (diff.inMinutes >= 1) {
    return "${diff.inMinutes} ${getTranslated(context, 'minutes')} ${getTranslated(context, 'ago')}";
  } else if (diff.inSeconds >= 1) {
    return "${diff.inSeconds} ${getTranslated(context, 'seconds')} ${getTranslated(context, 'ago')}";
  } else {
    return "${getTranslated(context, 'just_now')}";
  }
  return null;
}

//name validation check
String? nameValidation(String value, BuildContext context) {
  if (value.isEmpty) {
    return getTranslated(context, 'name_required')!;
  }
  if (value.length <= 1) {
    return getTranslated(context, 'name_length')!;
  }
  return null;
}

//email validation check
String? emailValidation(String value, BuildContext context) {
  if (value.length == 0) {
    return getTranslated(context, 'email_required')!;
  } else if (!RegExp(
          r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)"
          r"*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+"
          r"[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
      .hasMatch(value)) {
    return getTranslated(context, 'email_valid')!;
  } else {
    return null;
  }
}

//password validation check
String? passValidation(String value, BuildContext context) {
  if (value.length == 0)
    return getTranslated(context, 'pwd_required')!;
  else if (value.length <= 5)
    return getTranslated(context, 'pwd_length')!;
  else
    return null;
}

String? mobValidation(String value, BuildContext context) {
  if (value.isEmpty) {
    return getTranslated(context, 'mbl_required')!;
  }
  if (value.length < 9) {
    return getTranslated(context, 'mbl_valid')!;
  }
  return null;
}

String? titleValidation(String value, BuildContext context) {
  if (value.isEmpty) {
    return getTranslated(context, 'NEWS_TITLE_REQ_LBL')!;
  } else if (value.length < 2) {
    return getTranslated(context, 'PLZ_ADD_VALID_TITLE_LBL')!;
  }
  return null;
}

String? urlValidation(String value, BuildContext context) {
  bool? test;
  if (value.isEmpty) {
    return getTranslated(context, 'URL_REQ_LBL')!;
  } else {
    validUrl(value).then((result) {
      test = result;
      if (test!) {
        return getTranslated(context, 'PLZ_VALID_URL_LBL')!;
      }
    });
  }
  return null;
}

Future<bool> validUrl(String value) async {
  final response = await http.head(Uri.parse(value));

  if (response.statusCode == 200) {
    return false;
  } else {
    return true;
  }
}

//get token from admin side here to change your token details
String getToken() {
  final claimSet = new JwtClaim(
    issuedAt: DateTime.now(),
    issuer: 'NewsAPP',
    expiry: DateTime.now().add(Duration(minutes: 10)),
    subject: 'News APP Authentication',
  );

  String token = issueJwtHS256(claimSet, jwtKey);
  print("token****$token");
  return token;
}

Map<String, String> get headers => {
      "Authorization": 'Bearer ' + getToken(),
    };

Text setCoverageText(BuildContext context) {
  return Text(
    getTranslated(context, 'view_full_coverage')!,
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.subtitle1?.copyWith(
        color: Theme.of(context).colorScheme.fontColor.withOpacity(0.9),
        fontWeight: FontWeight.w600),
  );
}

Icon setCoverageIcon(BuildContext context) {
  return Icon(Icons.image,
      color: Theme.of(context).colorScheme.fontColor.withOpacity(0.9));
}

bool isRedundentClick(DateTime currentTime, int difference) {
  if (loginClickTime == null) {
    loginClickTime = currentTime;
    print("first click");
    return false;
  }
  print('diff is ${currentTime.difference(loginClickTime).inSeconds}');
  if (currentTime.difference(loginClickTime).inSeconds < difference) {
    //< 10
    //set this difference time in seconds
    return true;
  }

  loginClickTime = currentTime;
  return false;
}
