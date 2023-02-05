// ignore_for_file: non_constant_identifier_names, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';

// import 'dart:html';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart'; //fbAud
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:news/ForgotPassword.dart';
import 'package:crypto/crypto.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/ManagePref.dart';
import 'package:news/Helper/String.dart';
import 'package:news/RequestOtp.dart';
import 'package:news/main.dart';
import 'Privacy.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isNetworkAvail = true;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? id, name, email, pass, mobile, type, status, profile, confpass, role;
  String? uid;
  String? userEmail;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  TabController? _tabController;

  bool isChecked = false;

  FocusNode nameFocus = FocusNode();
  FocusNode emailSFocus = FocusNode();
  FocusNode passSFocus = FocusNode();
  FocusNode confPassFocus = FocusNode();
  TextEditingController s_emailC = TextEditingController();
  TextEditingController s_passC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController confPassC = TextEditingController();

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    new Future.delayed(Duration.zero, () {
      isChecked = false;
    });

    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    //hide keyboard
    _tabController!.addListener(() {
      FocusScope.of(context).unfocus();
      clearLoginTextFields();
      clearSignUpTextFields();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool _isToggle = true;
  bool _isObsecure = true;

  bool _issToggle = true;
  bool _issObsecure = true;

  bool _isReToggle = true;
  bool _isReObsecure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            showContent(),
            showCircularProgress(isLoading, colors.primary)
          ],
        ));
  }

  void _toggle() {
    setState(() {
      _isToggle = !_isToggle;
      //secure entered text
      _isObsecure = !_isObsecure;
    });
  }

  void _stoggle() {
    //SignUp Toggle
    setState(() {
      _issToggle = !_issToggle;
      //secure entered text
      _issObsecure = !_issObsecure;
    });
  }

  void _reToggle() {
    setState(() {
      _isReToggle = !_isReToggle;
      //secure entered text
      _isReObsecure = !_isReObsecure;
    });
  }

  //show form content
  showContent() {
    return Container(
        /*    controller: scrollController,
        padding: EdgeInsetsDirectional.only(
            top: 35.0, bottom: 20.0, start: 20.0, end: 20.0),*/
        child: Form(
            key: _formkey,
            child: Container(
              padding: EdgeInsetsDirectional.only(
                  top: 35.0, bottom: 20.0, start: 20.0, end: 20.0),
              width: MediaQuery.of(context).size.width,
              //  height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    skipBtn(),
                    showTabs(),
                    showTabBarView(),
                  ]),
            )));
  }

  showTabs() {
    return Align(
        alignment: Alignment.centerLeft,
        child: DefaultTabController(
          length: 2,
          child: Container(
              padding: EdgeInsetsDirectional.only(start: 10.0),
              width: deviceWidth! / 1.7,
              child: TabBar(
                  overlayColor:
                      MaterialStateProperty.all(colors.transparentColor),
                  controller: _tabController,
                  labelStyle: Theme.of(context).textTheme.subtitle2?.copyWith(
                      fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  labelPadding: EdgeInsets.zero,
                  labelColor: colors.bgColor,
                  unselectedLabelColor: Theme.of(context).colorScheme.fontColor,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Theme.of(context).colorScheme.tabColor),
                  tabs: [
                    Tab(text: getTranslated(context, 'signin_tab')!),
                    Tab(text: getTranslated(context, 'signup_btn')!)
                  ])),
        ));
  }

  showTabBarView() {
    return Expanded(
      child: Container(
          padding: EdgeInsets.only(top: 10.0),
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 1.0,
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: TabBarView(
              controller: _tabController,
              dragStartBehavior: DragStartBehavior.start,
              children: [
                //Login
                ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(children: [
                      loginTxt(),
                      emailSet(),
                      passSet(),
                      forgotPassSet(),
                      loginBtn(),
                      dividerOr(),
                      bottomBtn(),
                      termPolicyTxt(),
                    ]),
                  )),
                ),
                //SignUp
                ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: SingleChildScrollView(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      children: [
                        signUpTxt(),
                        nameSet(),
                        emailSignupSet(),
                        passSignupSet(),
                        confPassSignupSet(),
                        signUpBtn(),
                      ],
                    ),
                  )),
                )
              ],
            ),
          )),
    );
  }

  //set skip login btn
  skipBtn() {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(colors.transparentColor),
            foregroundColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.skipColor.withOpacity(0.4)),
          ),
          onPressed: () {
            setPrefrenceBool(ISFIRSTTIME, true);
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                Navigator.of(_scaffoldKey.currentContext!)
                    .pushNamedAndRemoveUntil(
                        "/home", (Route<dynamic> route) => false);
              });
            });
          },
          child: Text(getTranslated(context, 'skip')!)),
    );
  }

  loginTxt() {
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsetsDirectional.only(top: 35.0, start: 10.0),
          child: Text(
            getTranslated(context, 'login_descr')!,
            style: Theme.of(context).textTheme.headline5?.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5),
            textAlign: TextAlign.left,
          ),
        ));
  }

  signUpTxt() {
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsetsDirectional.only(top: 35.0, start: 10.0),
          child: Text(
            getTranslated(context, 'signup_descr')!,
            style: Theme.of(context).textTheme.headline5?.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5),
            textAlign: TextAlign.left,
          ),
        ));
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  nameSet() {
    //signUp User
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: TextFormField(
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        controller: nameC,
        style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
            ),
        validator: (val) => nameValidation(val!, context),
        onChanged: (String value) {
          setState(() {
            name = value;
          });
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, nameFocus, emailSFocus);
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "${getTranslated(context, 'name_lbl')}",
          hintStyle: Theme.of(this.context).textTheme.subtitle1?.copyWith(
              color: Theme.of(context).colorScheme.darkColor.withOpacity(0.5)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.boxColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 17),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color:
                    Theme.of(context).colorScheme.borderColor.withOpacity(0.6)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  emailSignupSet() {
    //signUp User
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: TextFormField(
        focusNode: emailSFocus,
        textInputAction: TextInputAction.next,
        controller: s_emailC,
        style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
            ),
        validator: (val) => emailValidation(val!, context),
        onChanged: (String value) {
          setState(() {
            email = value;
          });
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailSFocus, passSFocus);
        },
        decoration: InputDecoration(
          hintText: "${getTranslated(context, 'email_lbl')}",
          hintStyle: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                color: Theme.of(context).colorScheme.darkColor.withOpacity(0.5),
              ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.boxColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 17),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color:
                    Theme.of(context).colorScheme.borderColor.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  passSignupSet() {
    //signUp User
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
          focusNode: passSFocus,
          textInputAction: TextInputAction.next,
          obscureText: _issObsecure,
          controller: s_passC,
          style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
              ),
          validator: (val) => passValidation(val!, context),
          onChanged: (String value) {
            setState(() {
              pass = value;
            });
          },
          onFieldSubmitted: (v) {
            _fieldFocusChange(context, passSFocus, confPassFocus);
          },
          decoration: InputDecoration(
            hintText: "${getTranslated(context, 'pass_lbl')}",
            hintStyle: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                  color:
                      Theme.of(context).colorScheme.darkColor.withOpacity(0.5),
                ),
            suffixIcon: Padding(
                padding: EdgeInsetsDirectional.only(end: 12.0),
                child: IconButton(
                  icon: _issToggle
                      ? Icon(Icons.visibility_rounded, size: 20)
                      : Icon(Icons.visibility_off_rounded, size: 20),
                  splashColor: colors.clearColor,
                  onPressed: () {
                    _stoggle();
                  },
                )),
            filled: true,
            fillColor: Theme.of(context).colorScheme.boxColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 17),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .borderColor
                      .withOpacity(0.7)),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  confPassSignupSet() {
    //signUp User
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
          focusNode: confPassFocus,
          textInputAction: TextInputAction.done,
          obscureText: _isReObsecure,
          controller: confPassC,
          style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
              ),
          validator: (value) {
            if (value?.length == 0)
              return getTranslated(context, 'confpass_required')!;
            if (value != pass) {
              return getTranslated(context, 'confpass_not_match')!;
            } else {
              return null;
            }
          },
          onChanged: (String value) {
            setState(() {
              confpass = value;
            });
          },
          onFieldSubmitted: (value) {
            scrollController.animateTo(0,
                duration: Duration(seconds: 1), curve: Curves.easeIn);
          },
          decoration: InputDecoration(
            hintText: "${getTranslated(context, 'confpass_lbl')}",
            hintStyle: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                  color:
                      Theme.of(context).colorScheme.darkColor.withOpacity(0.5),
                ),
            suffixIcon: Padding(
                padding: EdgeInsetsDirectional.only(end: 12.0),
                child: IconButton(
                  icon: _isReToggle
                      ? Icon(Icons.visibility_rounded, size: 20)
                      : Icon(Icons.visibility_off_rounded, size: 20),
                  splashColor: colors.clearColor,
                  onPressed: () {
                    _reToggle();
                  },
                )),
            filled: true,
            fillColor: Theme.of(context).colorScheme.boxColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 17),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .borderColor
                      .withOpacity(0.7)),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  emailSet() {
    //Login User
    return Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: TextFormField(
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        controller: emailC,
        style: Theme.of(this.context)
            .textTheme
            .subtitle1
            ?.copyWith(color: Theme.of(context).colorScheme.fontColor),
        validator: (val) => emailValidation(val!, context),
        onChanged: (String value) {
          setState(() {
            email = value;
          });
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus, passFocus);
        },
        decoration: InputDecoration(
          hintText: getTranslated(context, 'email_lbl')!,
          hintStyle: Theme.of(this.context).textTheme.subtitle1?.copyWith(
              color: Theme.of(context).colorScheme.darkColor.withOpacity(0.5)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.boxColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 17),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color:
                    Theme.of(context).colorScheme.borderColor.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  passSet() {
    //Login User
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
          focusNode: passFocus,
          textInputAction: TextInputAction.done,
          controller: passC,
          obscureText: _isObsecure,
          style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
              ),
          validator: (val) => passValidation(val!, context),
          onChanged: (String value) {
            setState(() {
              pass = value;
            });
          },
          decoration: InputDecoration(
            hintText: getTranslated(context, 'pass_lbl'),
            hintStyle: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                  color:
                      Theme.of(context).colorScheme.darkColor.withOpacity(0.5),
                ),
            suffixIcon: Padding(
                padding: EdgeInsetsDirectional.only(end: 12.0),
                child: IconButton(
                  icon: _isToggle
                      ? Icon(Icons.visibility_rounded, size: 20)
                      : Icon(Icons.visibility_off_rounded, size: 20),
                  splashColor: colors.clearColor,
                  onPressed: () {
                    _toggle();
                  },
                )),
            filled: true,
            fillColor: Theme.of(context).colorScheme.boxColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 17),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .borderColor
                      .withOpacity(0.6)),
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  forgotPassSet() {
    //Login User
    return Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: Align(
          alignment: Alignment.topRight,
          child: TextButton(
            child: Text(
              getTranslated(context, 'forgot_pass_lbl')!,
            ),
            onPressed: () {
              //goto ForgotPswd screen
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ForgotPassword()));
            },
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(colors.transparentColor),
              foregroundColor:
                  MaterialStateProperty.all(colors.tempBorderColor),
            ),
          ),
        ));
  }

  //sign in with email and password in firebase
  signInWithEmailPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // checking if uid or email is null
        assert(user.uid != null);
        assert(user.email != null);

        uid = user.uid;
        userEmail = user.email;

        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final User? currentUser = _auth.currentUser;
        assert(user.uid == currentUser?.uid);

        String? name = user.displayName;

        if (name == null || name.trim().length == 0) {
          name = email.split("@")[0];
        }

        setState(() {
          isLoading = false;
        });
        if (userCredential.user!.emailVerified) {
          getLoginUser(user.uid, name, login_email, email, "", "", false);
        } else {
          showSnackBar(getTranslated(context, 'verify_email_msg')!, context);
        }
      }
    } on FirebaseAuthException catch (authError) {
      setState(() {
        isLoading = false;
      });
      print(
          "Firebase AuthException - ${authError.code} & ${authError.message}");
      if (authError.code == 'user-not-found') {
        print('No user found for that email.');
        showSnackBar(getTranslated(context, 'user-not-found')!, context);
      } else if (authError.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        showSnackBar(getTranslated(context, 'wrong-password')!, context);
      } else {
        showSnackBar(authError.message!, context);
      }
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Firebase Exception - ${e.code}");
      showSnackBar(e.toString(), context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('**Error: $e');
      String _errorMessage = e.toString();
      showSnackBar(_errorMessage, context);
    }
  }

//fbAud
  Future<String?> _SignInWithFB() async {
    FacebookLogin _login = FacebookLogin();
    if (await _login.isLoggedIn) _login.logOut();

    final result = await _login.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    switch (result.status) {
      case FacebookLoginStatus.success:
        final FacebookAccessToken accessToken = result.accessToken!;

        AuthCredential authCredential =
            FacebookAuthProvider.credential(accessToken.token);
        User? mainuser =
            (await _auth.signInWithCredential(authCredential)).user;

        if (mainuser != null) {
          assert(mainuser.uid != null);
          assert(mainuser.displayName != null);

          String? name =
              mainuser.displayName != null ? mainuser.displayName : "";

          String? mobile =
              mainuser.phoneNumber != null ? mainuser.phoneNumber : "";

          String? profile = mainuser.photoURL != null ? mainuser.photoURL : "";

          String? email = mainuser.email != null ? mainuser.email : "";

          getLoginUser(
              mainuser.uid, name!, login_fb, email!, mobile!, profile!, true);
        }
        break;
      case FacebookLoginStatus.error:
        setState(() {
          isLoading = false;
        });
        showSnackBar(result.error.toString(), context);
        break;
      case FacebookLoginStatus.cancel:
        setState(() {
          isLoading = false;
        });
        showSnackBar(getTranslated(context, 'cancel_login')!, context);
        break;
    }
    return null;
  }

  //fbAud
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
        token1 = token;
        print("response ${getdata} & token ${token1}");
      } on Exception catch (_) {}
    }
  }

  //login user using api
  Future<void> getLoginUser(String firebaseId1, String name1, String type1,
      String email1, String mobile1, String profile1, bool loading) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        FIREBASE_ID: firebaseId1,
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

      print("param**login***$param");

      Response response =
          await post(Uri.parse(getUserSignUpApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getData = json.decode(response.body);
      print(" getData For login user - $getData");

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
        role = i[ROLE];
        String isFirstLogin = i["is_login"];
        CUR_USERID = id!;
        CUR_USERNAME = name!;
        CUR_USEREMAIL = email!;
        saveUserDetail(
            id!, name!, email!, mobile!, profile!, type!, status!, role!);

        if (status == "0") {
          showSnackBar(getTranslated(context, 'deactive_msg')!, context);
          clearUserSession();
        } else {
          showSnackBar(getTranslated(context, 'login_msg')!, context);
          FirebaseMessaging.instance.getToken().then((token) async {
            if (token != token1) {
              updateFCM(token);
            }
            print("FCM Token - ${token} -- ${token1}");
          });
          if (isFirstLogin == "1") {
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                Navigator.of(_scaffoldKey.currentContext!).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => ManagePref(
                              from: 2,
                            )),
                    (Route<dynamic> route) => false);
              });
            });
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, "/home", (Route<dynamic> route) => false);
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

  //check validation of form data
  bool validateAndSave() {
    final form = _formkey.currentState;
    form!.save();
    if (isChecked) {
      //checkbox value should be 1 before Login/SignUp
      if (form.validate()) {
        return true;
      }
    } else {
      showSnackBar(getTranslated(context, 'agreeTCFirst')!, context);
    }
    return false;
  }

  //set login with email and password btn
  loginBtn() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: InkWell(
        splashColor: Colors.transparent,
        child: Container(
          height: 55.0,
          //48.0,
          width: deviceWidth! * 0.9,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: colors.primary, borderRadius: BorderRadius.circular(7.0)),
          child: Text(
            getTranslated(context, 'login_txt')!, //login_btn
            style: Theme.of(this.context).textTheme.headline6?.copyWith(
                color: colors.tempboxColor,
                fontWeight: FontWeight.w600,
                fontSize: 21,
                letterSpacing: 0.6),
          ),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus(); //dismiss keyboard
          if (validateAndSave()) {
            _isNetworkAvail = await isNetworkAvailable();
            if (_isNetworkAvail) {
              setState(() {
                isLoading = true;
              });
              signInWithEmailPassword(email!.trim(), pass!);
            } else {
              showSnackBar(getTranslated(context, 'internetmsg')!, context);
            }
          }
        },
      ),
    );
  }

//set signUp btn
  signUpBtn() {
    return Padding(
      padding: EdgeInsets.only(top: 25.0),
      child: InkWell(
        splashColor: Colors.transparent,
        child: Container(
          height: 55.0,
          //48.0,
          width: deviceWidth! * 0.9,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: colors.primary, borderRadius: BorderRadius.circular(7.0)),
          child: Text(
            getTranslated(context, 'signup_btn')!,
            style: Theme.of(this.context).textTheme.headline6?.copyWith(
                color: colors.tempboxColor,
                fontWeight: FontWeight.w600,
                fontSize: 21,
                letterSpacing: 0.6),
          ),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus(); //dismiss keyboard
          final form = _formkey.currentState;
          if (form!.validate()) {
            form.save();
            _isNetworkAvail = await isNetworkAvailable();
            if (_isNetworkAvail) {
              setState(() {
                isLoading = true;
              });
              registerWithEmailPassword(email!.trim(), pass!);
            } else {
              setState(() {
                isLoading = false;
              });
              showSnackBar(getTranslated(context, 'internetmsg')!, context);
            }
          }
        },
      ),
    );
  }

  //sign in with google
  signInWithGoogle() async {
    try {
      await Firebase.initializeApp();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);

      final User? user = authResult.user;

      if (user != null) {
        assert(!user.isAnonymous);

        assert(await user.getIdToken() != null);

        final User? currentUser = _auth.currentUser;
        assert(user.uid == currentUser?.uid);

        String? name = user.displayName != null ? user.displayName : "";

        String? mobile = user.phoneNumber != null ? user.phoneNumber : "";

        String? profile = user.photoURL != null ? user.photoURL : "";

        String? email = user.email != null ? user.email : "";

        getLoginUser(
            user.uid, name!, login_gmail, email!, mobile!, profile!, true);
      }
    } on FirebaseAuthException catch (authError) {
      setState(() {
        isLoading = false;
      });
      print(
          "Firebase AuthException - ${authError.code} & ${authError.message}");
      showSnackBar(authError.message!, context);
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Firebase Exception - ${e.code}");
      showSnackBar(e.toString(), context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      String _errorMessage = e.toString();
      print(_errorMessage);
      if (_errorMessage == "Null check operator used on a null value") {
        //if user goes back from selecting Account
        //in case of User gmail not selected & back to Login screen
        showSnackBar(getTranslated(context, 'cancel_login')!, context);
      } else {
        showSnackBar(_errorMessage, context);
      }
    }
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      if (authResult != null) {
        final User? currentUser = _auth.currentUser;
        assert(authResult.user!.uid == currentUser?.uid);

        String? name = authResult.user!.displayName != null
            ? authResult.user!.displayName
            : "";

        String? mobile = authResult.user!.phoneNumber != null
            ? authResult.user!.phoneNumber
            : "";

        String? profile =
            authResult.user!.photoURL != null ? authResult.user!.photoURL : "";

        String? email =
            authResult.user!.email != null ? authResult.user!.email : "";
        getLoginUser(authResult.user!.uid, name!, login_gmail, email!, mobile!,
            profile!, true);
      }
    } on FirebaseAuthException catch (authError) {
      setState(() {
        isLoading = false;
      });
      print(
          "Firebase AuthException - ${authError.code} & ${authError.message}");
      showSnackBar(authError.message!, context);
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Firebase Exception - ${e.code}");
      showSnackBar(e.toString(), context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      String _errorMessage = e.toString();
      print(_errorMessage);
      if (_errorMessage == "Null check operator used on a null value") {
        //if user goes back from selecting Account
        //in case of User gmail not selected & back to Login screen
        showSnackBar(getTranslated(context, 'cancel_login')!, context);
      } else {
        showSnackBar(_errorMessage, context);
      }
    }
    return null;
  }

  registerWithEmailPassword(String email, String password) async {
    // final FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential != null) {
        User? user = credential.user;
        user!
            .updateDisplayName(name?.trim())
            .then((value) => print("updated name is - ${user.displayName}"));
        // print("User details - $user & email is $email");
        user.reload();
        User? userNew = await _auth.currentUser;
        print(userNew);
        setState(() {
          isLoading = false;
        });
        user.sendEmailVerification().then((value) => showSnackBar(
            '${getTranslated(context, 'verif_sent_mail')} $email', context));
        clearSignUpTextFields();
        _tabController!.animateTo(0);
        FocusScope.of(context).requestFocus(emailFocus);
      }
      /*  _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).then((result) {
        User? user = result.user;
        user!
            .updateDisplayName(name?.trim())
            .then((value) => print("updated name is - ${user.displayName}"));
        print("User details - $user & email is $email");
        user.reload();
        setState(() {
          isLoading = false;
        });
        user.sendEmailVerification().then((value) => showSnackBar(
            getTranslated(context,
                '${getTranslated(context, 'verif_sent_mail')}+$email')!,
            context));
        clearSignUpTextFields();
        _tabController!.animateTo(0);
        FocusScope.of(context).requestFocus(emailFocus);
      }); */
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'weak-password') {
        showSnackBar(getTranslated(context, 'weak-password')!, context);
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(getTranslated(context, 'email-already-in-use')!, context);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    }
    /*  .catchError((e) {
      print("${e.code} ${e.toString()}");
      setState(() {
        isLoading = false;
      });
      showSnackBar(e.toString(), context);
      clearSignUpTextFields();
      _tabController!.animateTo(0);
      FocusScope.of(context).requestFocus(emailFocus);
    }); */
  }

  clearSignUpTextFields() {
    setState(() {
      nameC.clear();
      s_emailC.clear();
      s_passC.clear();
      confPassC.clear();
    });
  }

  clearLoginTextFields() {
    setState(() {
      emailC.clear();
      passC.clear();
    });
  }

  //set divider on text
  dividerOr() {
    return Padding(
        padding: EdgeInsetsDirectional.only(top: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getTranslated(context, 'or_lbl')!,
              style: Theme.of(context).textTheme.subtitle1?.merge(TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .skipColor
                        .withOpacity(0.7),
                    fontSize: 12.0,
                  )),
            ),
          ],
        ));
  }

  googleBtn() {
    return InkWell(
      splashColor: Colors.transparent,
      child: Container(
        height: 54,
        width: 54,
        padding: EdgeInsets.all(9.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: colors.tempboxColor,
        ),
        child: SvgPicture.asset(
          "assets/images/google_button.svg",
          semanticsLabel: 'Google Btn',
        ),
      ),
      onTap: () {
        if (isChecked) {
          //checkbox value should be 1 before Login/SignUp
          signInWithGoogle();
        } else {
          showSnackBar(getTranslated(context, 'agreeTCFirst')!, context);
        }
      },
    );
  }

  fbBtn() {
    return Padding(
        padding: EdgeInsetsDirectional.only(start: 10.0),
        child: InkWell(
          splashColor: Colors.transparent,
          child: Container(
            height: 54,
            width: 54,
            padding: EdgeInsets.all(9.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: colors.tempboxColor,
            ),
            child: SvgPicture.asset(
              "assets/images/facebook_button.svg",
              semanticsLabel: 'facebook Btn',
            ),
          ),
          onTap: () {
            if (isRedundentClick(DateTime.now(), diff)) {
              //duration
              print('hold on, processing');
              /* showSnackBar(
                          getTranslated(context, 'processing')!, context); */
              return;
            }
            if (isChecked) {
              //checkbox value should be 1 before Login/SignUp
              _SignInWithFB(); //fbAud
            } else {
              showSnackBar(getTranslated(context, 'agreeTCFirst')!, context);
            }
            diff = resetDiff;
          },
        ));
  }

  appleBtn() {
    return Padding(
        padding: EdgeInsetsDirectional.only(start: 10.0),
        child: InkWell(
          splashColor: Colors.transparent,
          child: Container(
            height: 54,
            width: 54,
            padding: EdgeInsets.all(9.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: colors.tempboxColor,
            ),
            child: SvgPicture.asset(
              "assets/images/apple_logo.svg",
              semanticsLabel: 'apple logo',
            ),
          ),
          onTap: () {
            if (isChecked) {
              //checkbox value should be 1 before Login/SignUp
              signInWithApple();
            } else {
              showSnackBar(getTranslated(context, 'agreeTCFirst')!, context);
            }
          },
        ));
  }

  phoneBtn() {
    return Padding(
        padding: EdgeInsetsDirectional.only(start: 10.0),
        child: InkWell(
          splashColor: Colors.transparent,
          child: Container(
            height: 54,
            width: 54,
            padding: EdgeInsets.all(9.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: colors.tempboxColor,
            ),
            child: SvgPicture.asset(
              "assets/images/phone_button.svg",
              semanticsLabel: 'phone Btn',
              color: Theme.of(context).colorScheme.tabColor,
            ),
          ),
          onTap: () {
            if (isChecked) {
              //checkbox value should be 1 before Login/SignUp
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => RequestOtp()));
            } else {
              showSnackBar(getTranslated(context, 'agreeTCFirst')!, context);
            }
          },
        ));
  }

  // }

  bottomBtn() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0, left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          googleBtn(),
          fbBtn(),
          if (Platform.isIOS) appleBtn(),
          phoneBtn()
        ],
      ),
    );
  }

//set terms and policy text
  termPolicyTxt() {
    return Container(
      alignment: AlignmentDirectional.bottomCenter,
      padding: EdgeInsets.only(top: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
            value: this.isChecked,
            checkColor: Theme.of(context).colorScheme.boxColor,
            activeColor: Theme.of(context).colorScheme.skipColor,
            onChanged: (bool? value) {
              setState(() {
                this.isChecked = value!;
              });
            },
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(children: [
              TextSpan(
                text: getTranslated(context, 'agreeTermPolicy_lbl')! + "\n",
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.7),
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
              TextSpan(
                text: getTranslated(context, 'term_lbl')!,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: colors.primary,
                      decoration: TextDecoration.underline,
                      overflow: TextOverflow.ellipsis,
                    ),
                recognizer: TapGestureRecognizer()
                  ..onTap = (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => PrivacyPolicy(
                                  title: getTranslated(context, 'term_cond')!,
                                  from: getTranslated(context, 'login_lbl'),
                                )));
                  }),
              ),
              TextSpan(
                text: getTranslated(context, 'and_lbl')!,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.7),
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
              TextSpan(
                text: getTranslated(context, 'pri_policy')!,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: colors.primary,
                      decoration: TextDecoration.underline,
                      overflow: TextOverflow.ellipsis,
                    ),
                recognizer: TapGestureRecognizer()
                  ..onTap = (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => PrivacyPolicy(
                                  title:
                                      getTranslated(context, 'privacy_policy')!,
                                  from: getTranslated(context, 'login_lbl'),
                                )));
                  }),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
