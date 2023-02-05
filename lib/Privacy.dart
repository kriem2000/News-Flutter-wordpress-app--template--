import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Helper/Color.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

class PrivacyPolicy extends StatefulWidget {
  final String? title;
  final String? from;

  const PrivacyPolicy({Key? key, this.title, this.from}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StatePrivacy();
  }
}

class StatePrivacy extends State<PrivacyPolicy> with TickerProviderStateMixin {
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String? privacy;
  String url = "";
  bool _isNetworkAvail = true;

  @override
  void initState() {
    super.initState();
    getSetting();
  }

  @override
  Widget build(BuildContext context) {
    /*  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]); */
    return _isLoading
        ? Scaffold(
            key: _scaffoldKey,
            appBar: getAppBar(),
            body: Container(
              alignment: Alignment.center,
              child: showCircularProgress(_isLoading, colors.primary),
            ))
        : Scaffold(
            key: _scaffoldKey,
            appBar: getAppBar(),
            body: SingleChildScrollView(
              padding:
                  EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 5.0),
              child: HtmlWidget(
                privacy!,
                onTapUrl: (
                  String? url,
                ) async {
                  if (await canLaunchUrl(Uri.parse(url!))) {
                    await launchUrl(Uri.parse(url));
                    return true;
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
            ));
  }

  //set appbar
  getAppBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 45),
        child: AppBar(
          // systemOverlayStyle:
          //     !isDark! ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
          // leadingWidth: 50,
          // elevation: 0.0,
          centerTitle: false, //true,
          backgroundColor: Colors.transparent,
          leading: setBackButton(
              context, !isDark! ? colors.secondaryColor : colors.bgColor),
          /* IconButton(
            icon: Icon(Icons.arrow_back, color: !isDark! ? colors.secondaryColor : colors.bgColor),
            onPressed: () => Navigator.of(context).pop(),
            splashColor: Colors.transparent,
          ), */
          title: Transform(
            transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
            child: Text(
              widget.title!,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: !isDark! ? colors.secondaryColor : colors.bgColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5),
            ),
          ),
        ));
  }

  //get setting api in fetch privacy data
  Future<void> getSetting() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
      };
      Response response =
          await post(Uri.parse(getSettingApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      //  print("Response data - $getdata");
      String error = getdata["error"];
      if (error == "false") {
        if (widget.title == getTranslated(context, 'privacy_policy')!)
          privacy = getdata["data"][PRIVACY_POLICY].toString();
        else if (widget.title == getTranslated(context, 'term_cond')!)
          privacy = getdata["data"][TERMS_CONDITIONS].toString();
        else if (widget.title == getTranslated(context, 'about_us')!)
          privacy = getdata["data"][ABOUT_US].toString();
        else if (widget.title == getTranslated(context, 'contact_us')!)
          privacy = getdata["data"][CONTACT_US].toString();
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }
}
