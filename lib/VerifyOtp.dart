// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison, must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'ManagePref.dart';
// import 'Privacy.dart';

class VerifyOtp extends StatefulWidget {
  String? verifyId, countryCode, mono;

  VerifyOtp({Key? key, this.verifyId, this.countryCode, this.mono})
      : super(key: key);

  @override
  VerifyOtpState createState() => VerifyOtpState();
}

class VerifyOtpState extends State<VerifyOtp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController phoneC = TextEditingController();
  String? phone, otp;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isNetworkAvail = true;
  bool isLoading = false;
  int secondsRemaining = 60;
  bool enableResend = false;
  Timer? timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? id,
      name,
      email,
      pass,
      mobile,
      type,
      status,
      profile,
      confpass,
      // ignore: unused_field
      _verificationId;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _resendCode() {
    otp = "";
    _onVerifyCode();
    setState(() {
      secondsRemaining = 60;
      enableResend = false;
    });
  }

  void _onVerifyCode() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth
          .signInWithCredential(phoneAuthCredential)
          .then((UserCredential value) {
        if (value.user != null) {
          showSnackBar(getTranslated(context, 'OTPMSG')!, context);
        } else {
          showSnackBar(getTranslated(context, 'OTPERROR')!, context);
        }
      }).catchError((error) {
        showSnackBar(error.toString(), context);
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      if (authException.code == 'invalid-verification-code') {
        showSnackBar(
            getTranslated(context, 'invalid-verification-code')!, context);
      } else {
        showSnackBar(authException.message.toString(), context);
      }
      print(authException.message);
    };

    final PhoneCodeSent codeSent =
        (String? verificationId, [int? forceResendingToken]) async {
      _verificationId = verificationId;
      if (mounted)
        setState(() {
          _verificationId = verificationId;
        });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
      showSnackBar(getTranslated(context, 'otp_timeout_lbl')!, context);
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: "+${widget.countryCode}${widget.mono}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  signIn() async {
    String code = otp!.trim();

    if (code.length == 6) {
      try {
        final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verifyId!,
          smsCode: otp!,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          showSnackBar(getTranslated(context, 'OTPMSG')!, context);
          assert(!user.isAnonymous);

          assert(await user.getIdToken() != null);

          final User? currentUser = _auth.currentUser;
          assert(user.uid == currentUser?.uid);

          String? name = user.displayName != null ? user.displayName : "";

          String? mobile = user.phoneNumber != null ? user.phoneNumber : "";

          String? profile = user.photoURL != null ? user.photoURL : "";

          String? email = user.email != null ? user.email : "";
          setState(() {
            isLoading = false;
          });
          getLoginUser(
              user.uid, name!, login_mbl, email!, mobile!, profile!, true);
        } else {
          showSnackBar(getTranslated(context, 'OTPERROR')!, context);
        }
      } on FirebaseAuthException catch (authError) {
        setState(() {
          isLoading = false;
        });
        print(
            "Firebase AuthException - ${authError.code} & ${authError.message}");
        // showSnackBar(authError.message!, context);
        if (authError.code == 'invalid-verification-code') {
          showSnackBar(
              getTranslated(context, 'invalid-verification-code')!, context);
        } else {
          showSnackBar(authError.message.toString(), context);
        }
      } on FirebaseException catch (e) {
        setState(() {
          isLoading = false;
        });
        print("Firebase Exception - ${e.code}");
        showSnackBar(e.message.toString(), context);
      } catch (e) {
        showSnackBar(e.toString(), context);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'enter_otp_txt')!, context);
      setState(() {
        isLoading = false;
      });
    }
  }

  //login user using api
  Future<void> getLoginUser(String firebase_id1, String name1, String type1,
      String email1, String mobile1, String profile1, bool loading) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        FIREBASE_ID: firebase_id1,
        NAME: name1,
        EMAIL: email1,
        TYPE: type1,
        ACCESS_KEY: access_key,
      };

      setState(() {
        isLoading = true;
      });

      if (mobile1 != "") {
        param[MOBILE] = mobile1;
      }
      if (profile1 != "") {
        param[PROFILE] = profile1;
      }

      Response response =
          await post(Uri.parse(getUserSignUpApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getData = json.decode(response.body);

      String error = getData["error"];
      String msg = getData["message"];

      if (error == "false") {
        var i = getData["data"];
        id = i[ID];
        name = i[NAME];
        email = i[EMAIL];
        mobile = i[MOBILE];
        profile = i[PROFILE];
        type = i[TYPE];
        status = i[STATUS];
        String isFirstLogin = i["is_login"];
        String role = i[ROLE];
        CUR_USERID = id!;
        CUR_USERNAME = name!;
        CUR_USEREMAIL = email!;
        saveUserDetail(
            id!, name!, email!, mobile!, profile!, type!, status!, role);

        if (status == "0") {
          showSnackBar(getTranslated(context, 'deactive_msg')!, context);
          clearUserSession();
        } else {
          showSnackBar(getTranslated(context, 'login_msg')!, context);
          if (isFirstLogin == "1") {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => ManagePref(
                          from: 2,
                        )),
                (Route<dynamic> route) => false);
          } else {
            getUserByCat().whenComplete(() {
              FirebaseMessaging.instance.getToken().then((token) async {
                updateFCM(token);
              });
              setPrefrenceBool(ISFIRSTTIME, true);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  "/home", (Route<dynamic> route) => false);
            });
          }
        }
      } else {
        if (_auth != null) _auth.signOut();
        showSnackBar(msg, context);
      }
      setState(() {
        isLoading = false;
      });
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      });
    }
  }

  void updateFCM(String? token) async {
    if (CUR_USERID != null && CUR_USERID != "") {
      try {
        Map<String, String> body = {
          ACCESS_KEY: access_key,
          USER_ID: CUR_USERID,
          "fcm_id": token!,
        };
        Response response =
            await post(Uri.parse(updateFCMIdApi), body: body, headers: headers)
                .timeout(Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        print("$getdata");
        token1 = token;
      } on Exception catch (_) {}
    }
  }

  Future<void> getUserByCat() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
      };
      Response response =
          await post(Uri.parse(getUserByIdApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      String error = getdata["error"];
      if (error == "false") {
        var data = getdata["data"];
        setState(() {
          String catId = data[0]["category_id"];
          setPrefrence(cur_catId, catId);
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            SafeArea(child: showContent()),
            Center(child: showCircularProgress(isLoading, colors.primary))
          ],
        ));
  }

  //show form content
  showContent() {
    return Container(
      padding: EdgeInsetsDirectional.all(20.0),
      child: SingleChildScrollView(
          /* padding: EdgeInsetsDirectional.only(
              top: 80.0, bottom: 20.0, start: 50.0, end: 50.0), */
          child: Form(
              key: _formkey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 50),
                    otpVerifySet(),
                    otpSentSet(),
                    mblSet(),
                    otpFillSet(),
                    buildTimer(),
                    submitBtn(),
                  ]))),
    );
  }

  otpVerifySet() {
    return Align(
        alignment: Alignment.center,
        child: Text(
          getTranslated(context, 'otpVerify_lbl')!,
          style: Theme.of(context).textTheme.headline5?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5),
          textAlign: TextAlign.center,
        ));
  }

  otpSentSet() {
    return Padding(
      padding: EdgeInsets.only(top: 55.0),
      child: Text(
        getTranslated(context, 'otpSent_lbl')!,
        style: Theme.of(context).textTheme.headline6?.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  mblSet() {
    return Padding(
      padding: EdgeInsets.only(top: 7.0),
      child: Text(
        "${widget.countryCode} ${widget.mono}",
        style: Theme.of(context).textTheme.subtitle2?.copyWith(
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.8),
            ),
      ),
    );
  }

  otpFillSet() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 30.0, left: 15, right: 15),
        child: PinFieldAutoFill(
            decoration: BoxLooseDecoration(
                strokeColorBuilder: PinListenColorBuilder(
                    Theme.of(context).colorScheme.boxColor,
                    Theme.of(context).colorScheme.boxColor),
                bgColorBuilder: PinListenColorBuilder(
                    Theme.of(context).colorScheme.boxColor,
                    Theme.of(context).colorScheme.boxColor),
                gapSpace: 4.0),
            //3.8
            currentCode: otp,
            codeLength: 6,
            keyboardType:
                TextInputType.numberWithOptions(signed: true, decimal: true),
            onCodeChanged: (String? code) {
              otp = code;
            },
            onCodeSubmitted: (String code) {
              otp = code;
            }));
  }

  buildTimer() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 60.0), //100.0
      child: secondsRemaining != 0
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(getTranslated(context, 'resendCode_lbl')!,
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .fontColor
                              .withOpacity(0.8),
                        )),
                Text(' 00:$secondsRemaining',
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                          color: colors.primary,
                        )),
              ],
            )
          : TextButton(
              child: Text(getTranslated(context, 'resend_lbl')!,
                  style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      )),
              onPressed: enableResend ? _resendCode : null,
            ),
    );
  }

  submitBtn() {
    return Container(
        // alignment: Alignment.center,
        padding: EdgeInsets.only(top: 30.0), //20.0
        child: InkWell(
            child: Container(
              height: 55.0,
              //48.0,
              width: deviceWidth! * 0.9,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(7.0)),
              child: Text(
                getTranslated(context, 'submit_btn')!,
                style: Theme.of(this.context).textTheme.headline6?.copyWith(
                    color: colors.tempboxColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 21,
                    letterSpacing: 0.6),
              ),
            ),
            onTap: () async {
              FocusScope.of(context).unfocus(); //dismiss keyboard
              if (isRedundentClick(DateTime.now(), diff)) {
                //inBetweenClicks
                print('hold on, processing');
                /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                return;
              }
              if (validateAndSave()) {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  setState(() {
                    isLoading = true;
                  });
                  signIn();
                } else {
                  showSnackBar(getTranslated(context, 'internetmsg')!, context);
                }
              }
              diff = resetDiff;
            }));
  }

  //check validation of form data
  bool validateAndSave() {
    final form = _formkey.currentState;
    form!.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

//set term and policy text
/*   termPolicyTxt() {
    return Padding(
        padding: EdgeInsets.only(bottom: 30.0, top: 45.0),
        child: Column(children: <Widget>[
          Text(
            getTranslated(context, 'agreeTermPolicy_lbl')!,
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  child: Text(
                    getTranslated(context, 'term_lbl')!,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: colors.primary,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => PrivacyPolicy(
                                  title: getTranslated(context, 'term_cond')!,
                                  from:
                                      getTranslated(context, 'otpVerify_lbl')!,
                                )));
                  },
                ),
                Text(
                  getTranslated(context, 'and_lbl')!,
                  style: Theme.of(context).textTheme.bodyText1?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                      ),
                ),
                InkWell(
                  child: Text(
                    getTranslated(context, 'pri_policy')!,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: colors.primary,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => PrivacyPolicy(
                                  title:
                                      getTranslated(context, 'privacy_policy')!,
                                  from:
                                      getTranslated(context, 'otpVerify_lbl')!,
                                )));
                  },
                ),
              ])
        ]));
  }
 */
}
