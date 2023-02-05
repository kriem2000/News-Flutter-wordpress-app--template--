import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';

class ForgotPassword extends StatefulWidget {
  @override
  FrgtPswdState createState() => FrgtPswdState();
}

class FrgtPswdState extends State<ForgotPassword> {
  TextEditingController emailC = TextEditingController();
  String? email;
  bool _isNetworkAvail = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  // int duration = 0; //10;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    /*  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]); */
    return Scaffold(
        body: Stack(
      children: <Widget>[
        SafeArea(child: screenContent()),
      ],
    ));
  }

  screenContent() {
    return Container(
        // height: MediaQuery.of(context).size.height,
        padding: EdgeInsetsDirectional.all(20.0),
        child: SingleChildScrollView(
            child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                  //backButton
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.keyboard_backspace_rounded),
                    splashColor: colors.transparentColor,
                  )),
              SizedBox(height: 50),
              Container(
                padding: EdgeInsets.all(20.0),
                // alignment: Alignment(0.0, -1.0),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/images/forgot.svg",
                    semanticsLabel: 'forgot pswd icon',
                    width: 150, //91, //300
                    height: 150, //120, //300
                    fit: BoxFit.fill,
                    color: Theme.of(context).colorScheme.skipColor,
                  ),
                ),
              ),
              Center(
                //forgot_pass_Title
                child: Text(
                  getTranslated(context, 'forgot_pass_lbl')!,
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                ),
              ),
              Padding(
                  //forgt_pass_head
                  padding: EdgeInsetsDirectional.only(top: 20.0),
                  child: Text(
                    getTranslated(context, 'forgt_pass_head')!,
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                  )),
              Padding(
                  //forgot_pass_sub
                  padding: EdgeInsetsDirectional.only(top: 30.0),
                  child: Text(
                    getTranslated(context, 'forgot_pass_sub')!,
                    style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          fontWeight: FontWeight.normal,
                          fontSize: 16.0,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                  )),
              Padding(
                  //email TextformField
                  padding: EdgeInsetsDirectional.only(top: 25.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: emailC,
                    style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                        color: colors
                            .darkColor1), //Theme.of(context).colorScheme.fontColor),
                    validator: (val) => emailValidation(val!, context),
                    onChanged: (String value) {
                      setState(() {
                        email = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: getTranslated(context, 'email_enter_lbl'),
                      hintStyle:
                          Theme.of(this.context).textTheme.subtitle1?.copyWith(
                              color: /* Theme.of(context)
                                  .colorScheme
                                  .darkColor */
                                  colors.tempdarkColor.withOpacity(0.5)),
                      filled: true,
                      fillColor: colors.tempboxColor,
                      //Theme.of(context).colorScheme.boxColor,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 25, vertical: 17),
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
                  )),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 30.0), //65.0
                child: ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus(); //dismiss keyboard
                    if (isRedundentClick(DateTime.now(), diff)) {
                      //duration
                      print('hold on, processing');
                      /* showSnackBar(
                          getTranslated(context, 'processing')!, context); */
                      return;
                    }
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Future.delayed(Duration(seconds: 1)).then((_) async {
                        // print("val of EMAIL String $email");
                        if (email == null || email!.isEmpty) {
                          /* ScaffoldMessenger.of(context)
                              .showSnackBar(new SnackBar(
                            content: new Text(
                              getTranslated(context, 'email_valid')!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.fontColor),
                            ),
                            duration: const Duration(
                                milliseconds: 1000), //bydefault 4000 ms
                            backgroundColor:
                                isDark! ? colors.tempdarkColor : colors.bgColor,
                            elevation: 1.0,
                            behavior: SnackBarBehavior.floating,
                          )); */
                          showSnackBar(
                              getTranslated(context, 'email_valid')!, context);
                        } else {
                          try {
                            await _auth.sendPasswordResetEmail(
                                email: email!.trim());
                            final form = _formkey.currentState;
                            form!.save();
                            if (form.validate()) {
                              showSnackBar(
                                  getTranslated(context, 'pass_reset')!,
                                  context);
                              Navigator.pop(context);
                            }
                          } on FirebaseAuthException catch (e) {
                            print(e.code);
                            print(e.message);
                            if (e.code == "user-not-found") {
                              showSnackBar(
                                  getTranslated(context, 'user-not-found')!,
                                  context);
                              // } else if (e.code == "invalid-email") {
                              //   showSnackBar(e.message!, context);
                            } else {
                              showSnackBar(e.message!, context);
                            }
                          }
                          /* try {
                            _auth
                                .sendPasswordResetEmail(email: email!.trim())
                                .onError((error, stackTrace) {
                              print("reset error - ${error.toString()}");
                            }).whenComplete(() {
                              final form = _formkey.currentState;
                              form!.save();
                              if (form.validate()) {
                                /* ScaffoldMessenger.of(context)
                                .showSnackBar(new SnackBar(
                              content: new Text(
                                getTranslated(context, 'pass_reset')!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              ),
                              backgroundColor: isDark!
                                  ? colors.tempdarkColor
                                  : colors.bgColor,
                              elevation: 1.0,
                              behavior: SnackBarBehavior.floating,
                            )); */
                                showSnackBar(
                                    getTranslated(context, 'pass_reset')!,
                                    context);
                                // Navigator.pop(context);
                              }
                            });
                          } on FirebaseAuthException catch (authError) {
                            print(
                                "Pswd reset error --  ${authError.code} - ${authError.message} ");
                            if (authError.code == "user-not-found") {}
                            if (authError.code == "invalid-email") {}
                          } */
                        }
                      });
                    } else {
                      /*  Future.delayed(Duration(seconds: 1)).then((_) async {
                        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                          content: new Text(
                            getTranslated(context, 'internetmsg')!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor),
                          ),
                          backgroundColor:
                              isDark! ? colors.tempdarkColor : colors.bgColor,
                          elevation: 1.0,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }); */
                      showSnackBar(
                          getTranslated(context, 'internetmsg')!, context);
                    }
                    diff = resetDiff;
                    //duration = 2;
                  },
                  style: ElevatedButton.styleFrom(
                    primary: colors.primary,
                    onPrimary: colors.bgColor,
                    fixedSize: Size(deviceWidth! * 0.9, 55),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    // minimumSize: Size(335, 55), //Size(182, 50)
                  ),
                  child: Text(
                    getTranslated(context, 'submit_btn')!,
                    style: Theme.of(this.context).textTheme.headline6?.copyWith(
                        color: colors.tempboxColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 21,
                        letterSpacing: 0.6),
                  ),
                ),
              )
            ],
          ),
        )));
  }
}
