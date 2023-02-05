import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:news/VerifyOtp.dart';
// import 'Privacy.dart';

class RequestOtp extends StatefulWidget {
  @override
  RequestOtpState createState() => RequestOtpState();
}

class RequestOtpState extends State<RequestOtp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController phoneC = TextEditingController();
  String? phone, conCode, conName;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _isNetworkAvail = true;
  bool isLoading = false;
  CountryCode? code;
  String? verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            SafeArea(
              child: showContent(),
            ),
            showCircularProgress(isLoading, colors.primary)
          ],
        ));
  }

  //show form content
  showContent() {
    return Container(
      padding: EdgeInsetsDirectional.all(20.0),
      child: SingleChildScrollView(
          /*padding:  EdgeInsetsDirectional.only(
              top: 80.0, bottom: 20.0, start: 20.0, end: 20.0), */
          child: Form(
              key: _formkey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                    otpVerifySet(),
                    enterMblSet(),
                    receiveDigitSet(),
                    setCodeWithMono(),
                    reqOtpBtn(),
                  ]))),
    );
  }

  otpVerifySet() {
    return Center(
        // alignment: Alignment.center,
        child: Text(
      getTranslated(context, 'login_lbl')!, //'otpVerify_lbl'
      style: Theme.of(context).textTheme.headline5?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5),
      textAlign: TextAlign.center,
    ));
  }

  enterMblSet() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 35.0),
        child: Text(
          getTranslated(context, 'enterMbl_lbl')!,
          style: Theme.of(context).textTheme.headline6?.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  receiveDigitSet() {
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      alignment: Alignment.center,
      child: Text(
        getTranslated(context, 'receiveDigit_lbl')!,
        style: Theme.of(context).textTheme.subtitle2?.copyWith(
            color: Theme.of(context).colorScheme.fontColor.withOpacity(0.8),
            fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  setCodeWithMono() {
    return Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.boxColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                setCountryCode(),
                setMono(),
              ],
            )));
  }

  setCountryCode() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
        height: 55,
        child: CountryCodePicker(
            boxDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.boxColor,
            ),
            searchDecoration: InputDecoration(
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.fontColor),
              fillColor: Theme.of(context).colorScheme.fontColor,
            ),
            initialSelection: yourCountryCode,
            dialogSize: Size(width - 50, height - 50),
            builder: (CountryCode? code) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsetsDirectional.only(
                          top: 10.0, bottom: 10.0, start: 10.0, end: 4.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Image.asset(
                            code!.flagUri.toString(),
                            package: 'country_code_picker',
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          ))),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 21,
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withOpacity(0.7),
                  ),
                  Container(
                      //divider
                      width: 5.0,
                      height: 35.0,
                      child: VerticalDivider(
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.7),
                        thickness: 2.0,
                      )),
                  Container(
                      //CountryCode
                      width: 55.0,
                      height: 55.0,
                      padding: EdgeInsetsDirectional.only(start: 5.0),
                      alignment: Alignment.center,
                      child: Text(
                        code.dialCode.toString(),
                        style: Theme.of(this.context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .fontColor
                                  .withOpacity(0.7),
                            ),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      )),
                ],
              );
            },
            onChanged: (CountryCode countryCode) {
              conCode = countryCode.dialCode;
              conName = countryCode.name;
            },
            onInit: (CountryCode? code) {
              conCode = code?.dialCode;
            }));
  }

  setMono() {
    // double width = MediaQuery.of(context).size.width;
    return Expanded(
      child: Padding(
        padding: EdgeInsetsDirectional.only(top: 10.0, bottom: 10.0),
        child: Container(
            height: 55,
            width: deviceWidth! * 0.57, //width - 245,
            alignment: Alignment.center, //centerLeft,
            // padding: EdgeInsetsDirectional.only(start: 10.0), //2.0
            child: TextFormField(
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              controller: phoneC,
              style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .fontColor
                        .withOpacity(0.7),
                  ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (val) => mobValidation(val!, context),
              onSaved: (String? value) {
                phone = value;
              },
              decoration: InputDecoration(
                hintText: '999-999-9999',
                hintStyle: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .fontColor
                          .withOpacity(0.5),
                    ),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            )),
      ),
    );
  }

  Future<void> verifyPhone(BuildContext context) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+$conCode${phoneC.text.trim()}",
        verificationCompleted: (AuthCredential phoneAuthCredential) {
          showSnackBar(phoneAuthCredential.toString(), context);
          print("Sucess !!!!");
        },
        verificationFailed: (FirebaseAuthException exception) {
          setState(() {
            isLoading = false;
          });
          print("${exception.code} -- ${exception.message}");
          // showSnackBar('${exception.message}', context);
          if (exception.code == "invalid-phone-number") {
            print(exception.message);
            showSnackBar(
                getTranslated(context, 'invalid-phone-number')!, context);
          } else {
            showSnackBar('${exception.message}', context);
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
        codeSent: processCodeSent(), //smsOTPSent,
        timeout: const Duration(seconds: 60),
      );
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
      showSnackBar(e.toString(), context);
    }
  }

  processCodeSent() {
    final PhoneCodeSent smsOTPSent =
        (String? verId, [int? forceCodeResend]) async {
      this.verificationId = verId;
      setState(() {
        isLoading = false;
      });

      showSnackBar(getTranslated(context, 'code_sent')!, context);

      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => VerifyOtp(
                    verifyId: verificationId,
                    countryCode: conCode,
                    mono: phoneC.text.trim(),
                  )));
    };
    return smsOTPSent;
  }

  reqOtpBtn() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 60.0), //top: 120.0
      child: InkWell(
        child: Container(
          height: 55.0, //48.0,
          width: deviceWidth! * 0.9,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: colors.primary, borderRadius: BorderRadius.circular(7.0)),
          child: Text(
            getTranslated(context, 'reqOtp_lbl')!,
            style: Theme.of(this.context).textTheme.headline6?.copyWith(
                color: colors.tempboxColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                fontSize: 21),
          ),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus(); //dismiss keyboard
          if (validateAndSave()) {
            if (isRedundentClick(DateTime.now(), diff)) {
              //inBetweenClicks
              print('hold on, processing');
              /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
              return;
            }
            _isNetworkAvail = await isNetworkAvailable();
            if (_isNetworkAvail) {
              setState(() {
                isLoading = true;
              });
              verifyPhone(context);
            } else {
              showSnackBar(getTranslated(context, 'internetmsg')!, context);
            }
            diff = resetDiff;
          }
        },
      ),
    );
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
                                  from: getTranslated(context, 'reqOtp_lbl')!,
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
                                  from: getTranslated(context, 'reqOtp_lbl')!,
                                )));
                  },
                ),
              ])
        ]));
  }
 */
}
