import 'dart:async';
import 'dart:convert';

// import 'dart:ffi';
import 'dart:io';

// import 'dart:math';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';

// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:news/AddNews.dart';
import 'package:news/Bookmark.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/LanguageList.dart';

// import 'package:news/Home.dart';
import 'package:news/Login.dart';
import 'package:news/ManagePref.dart';
import 'package:permission_handler/permission_handler.dart';

// import 'package:news/languageList.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
// import 'package:flutter/scheduler.dart';

import 'Helper/String.dart';
import 'Helper/Theme.dart';
import 'Privacy.dart';
import 'ShowNews.dart';

class Setting extends StatefulWidget {
  @override
  SettingState createState() => SettingState();
}

class SettingState extends State<Setting> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String profile = "";
  String mobile = "";
  String? type, name, email, role;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? image;
  bool _isNetworkAvail = true;
  TextEditingController? nameC, monoC, emailC = TextEditingController();
  bool isEditName = false;
  bool isEditMono = false;
  bool isEditEmail = false;

  // final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formkey2 = GlobalKey<FormState>();
  final GlobalKey<FormState> _nameFormKey = GlobalKey<FormState>();
  ThemeNotifier? themeNotifier;
  String? theme;
  int? selectedIndex;
  List<String> languageList = [
    eng_lbl,
    span_lbl,
    hin_lbl,
    turk_lbl,
    port_lbl,
    arabic_lbl
  ];

  List<String> langCode = ["en", "es", "hi", "tr", "pt", "ar"];

  int? selectLan;
  final InAppReview _inAppReview = InAppReview.instance;
  bool isSwitched = false;
  bool isnotiEnabled = false;
  late final User? user;

  // late NavigatorState _navigator;
  bool isSaveClicked = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
    isnotiEnabled = notiEnable!;
    isSwitched = isDark!;
    user = _auth.currentUser; //final User?
  }

  @override
  void dispose() {
    // nameC!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          _showContent(),
          showCircularProgress(_isLoading, colors.primary)
        ],
      ),
    );
  }

  _updateState(int position) {
    setState(() {
      selectedIndex = position;
    });
    onThemeChanged(position);
  }

  Future<void> getCurrentUserDetails() async {
    CUR_USERID = (await getPrefrence(ID)) ?? "";
    CUR_USERNAME = (await getPrefrence(NAME)) ?? "";
    CUR_USEREMAIL = (await getPrefrence(EMAIL)) ?? "";
    profile = await getPrefrence(PROFILE) ?? "";
    mobile = await getPrefrence(MOBILE) ?? "";
    type = await getPrefrence(TYPE);
    role = await getPrefrence(ROLE);
    print("role*****$role");
    nameC = TextEditingController(text: CUR_USERNAME);
    name = CUR_USERNAME; //assign bydefault @ start
    monoC = TextEditingController(text: mobile);
    emailC = TextEditingController(text: CUR_USEREMAIL);
    // print("current user id is - ${CUR_USERID}");
    getLocale().then((locale) {
      selectLan = langCode.indexOf(locale.languageCode);
    });

    notiEnable = await getPrefrenceBool(NOTIENABLE);

    setState(() {});
  }

  //show header and drawer data shown
  _showContent() {
    return SingleChildScrollView(

        padding: EdgeInsetsDirectional.only(
            start: 15.0, end: 15.0, top: 45.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            setHeader(),
            setBody(),
          ],
        ));
  }

//set image camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
      setProfilePic(image!);
    }
  }

// set image gallery
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
      setProfilePic(image!);
    }
  }

  //set profile using api
  Future<void> setProfilePic(File _image) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setState(() {
        _isLoading = true;
      });
      try {
        var request = MultipartRequest('POST', Uri.parse(setProfileApi));
        request.headers.addAll(headers);
        request.fields[USER_ID] = CUR_USERID;
        request.fields[ACCESS_KEY] = access_key;
        var pic = await MultipartFile.fromPath(IMAGE, _image.path);
        request.files.add(pic);

        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        if (response.statusCode == 200) {
          var getdata = json.decode(responseString);

          String error = getdata["error"];
          String msg = getdata['message'];
          profile = getdata['file_path'];
          if (error == "false") {
            showSnackBar(getTranslated(context, 'profile_success')!, context);
            setState(() {
              setPrefrence(PROFILE, profile);
            });
          } else {
            showSnackBar(msg, context);
          }
          setState(() {
            _isLoading = false;
          });
        } else {
          return null;
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  //set user update their name using api
  _setUpdateProfile(String name, String mono, String email) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
      };
      if (name != "") {
        param[NAME] = name;
      }
      if (mono != "") {
        param[MOBILE] = mono;
      }
      if (email != "") {
        param[EMAIL] = email;
      }

      Response response = await post(Uri.parse(setUpdateProfileApi),
              body: param, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      String error = getdata["error"];

      if (error == "false") {
        if (mounted) {
          setState(() {
            _isLoading = false;
            if (name != "") {
              isEditName = false;
              CUR_USERNAME = name;
              setPrefrence(NAME, name);
            }
            if (email != "") {
              isEditEmail = false;
              CUR_USEREMAIL = email;
              setPrefrence(EMAIL, email);
            }
            if (mono != "") {
              isEditMono = false;
              setPrefrence(MOBILE, mono);
            }
          });
        }
        if (mounted) {
          showSnackBar(getTranslated(context, 'profile_update_msg')!, context);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      }
    }
  }

  //user profile upload function
  void _showPicker() {
    //Image Picker Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            backgroundColor: Theme.of(context).colorScheme.fontColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
                height: 130,
                width: 80,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                      start: 50.0, end: 50.0, top: 10.0, bottom: 10.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                            icon: Icon(
                              Icons.photo_library,
                              color: Theme.of(context)
                                  .colorScheme
                                  .controlBGColor //fontColor
                                  .withOpacity(0.7),
                            ),
                            label: Text(
                              getTranslated(context, 'photo_lib_lbl')!,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .controlBGColor //fontColor
                                      .withOpacity(0.7),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              Center(
                                  child: showCircularProgress(
                                      true, colors.primary));

                              _getFromGallery();

                              Navigator.of(context).pop();
                            }),
                        TextButton.icon(
                          icon: Icon(
                            Icons.photo_camera,
                            color: Theme.of(context)
                                .colorScheme
                                .controlBGColor //fontColor
                                .withOpacity(0.7),
                          ),
                          label: Text(
                            getTranslated(context, 'camera_lbl')!,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .controlBGColor //fontColor
                                    .withOpacity(0.7),
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            _getFromCamera();

                            Navigator.of(context).pop();
                          },
                        )
                      ]),
                )));
      },
    );
  }

  setHeader() {
    double width = MediaQuery.of(context).size.width;
    return CUR_USERID != ""
        ? Stack(children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: profile == ""
                    ? Container(
                        height: 340.0,
                        width: width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: !isDark!
                                ? colors.secondaryColor
                                : colors.primary),
                      )
                    : Image.network(
                        profile,
                        height: 340.0,
                        width: width,
                        fit: BoxFit.cover,
                        // scale: 0.8,
                        filterQuality: FilterQuality.high,
                      )),
            Positioned.directional(
              textDirection: Directionality.of(context),
              bottom: 0,
              start: 0,
              end: 0,
              height: CUR_USEREMAIL != ""
                  ? 130
                  : CUR_USERNAME != ""
                      ? 130
                      : 100,
              child: ClipRRect(
                  //User Image
                  borderRadius: BorderRadius.circular(20.0),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            colors.secondaryColor.withOpacity(0.6)
                          ]).createShader(bounds);
                    },
                    blendMode: BlendMode.overlay,
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      color: Colors.transparent,
                      padding: EdgeInsets.only(top: 30),
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(start: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (CUR_USERNAME != "") userNameContainer(),
                            if (mobile != "") userMobileContainer(),
                            // : SizedBox.shrink(),
                            if (CUR_USEREMAIL != "") userEmailContainer(),
                            // : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  )),
            ),
            Positioned.directional(
                textDirection: Directionality.of(context),
                end: 13,
                top: 10,
                height: 35,
                width: 35,
                child: InkWell(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(35.0),
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35.0),
                              color: colors.tempboxColor.withOpacity(0.9),
                            ),
                            child: Icon(
                              Icons.add_circle_outline,
                              color: colors.darkColor1,
                              size: 22,
                            ),
                          ))),
                  onTap: () async {
                    final status = await Permission.storage.request();
                    print("status11****$status");
                    if (status == PermissionStatus.granted) {
                      _showPicker();
                    }
                  },
                ))
          ])
        : Stack(children: <Widget>[
            //For Guest User
            Container(
              height: 340,
              width: width,
              decoration: BoxDecoration(
                  color: !isDark! ? colors.primary : colors.darkColor1,
                  borderRadius: BorderRadius.circular(20)),
            ),
            Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: 12.0,
                start: 12,
                end: 12,
                height: 136,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(25.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: colors.tempboxColor.withOpacity(0.94),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              //text
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    getTranslated(context, 'auth_required')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        ?.copyWith(
                                            color: colors.tempdarkColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 19),
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                      padding: EdgeInsets.only(top: 13.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            getTranslated(context, 'plz_lbl')!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                ?.copyWith(
                                                  color: colors.tempdarkColor,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                          ),
                                          InkWell(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              child: Text(
                                                getTranslated(
                                                    context, 'login_btn')!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1
                                                    ?.copyWith(
                                                        color: colors.primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                              ),
                                            ),
                                            onTap: () {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 500), () {
                                                setState(() {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext
                                                                context) =>
                                                            Login()),
                                                  );
                                                  /* .pushAndRemoveUntil(
                                                          MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  Login()),
                                                          (route) => false); */
                                                });
                                              });
                                            },
                                          ),
                                          Text(
                                            getTranslated(
                                                context, 'first_acc_lbl')!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2
                                                ?.copyWith(
                                                  color: colors.tempdarkColor,
                                                ),
                                          ),
                                        ],
                                      )),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    getTranslated(context, 'all_fun_lbl')!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        ?.copyWith(
                                          color: colors.tempdarkColor,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  ),
                                ),
                              ],
                            ))))),
            Padding(
                //sample Img without user Login
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Center(
                  child: Icon(
                    Icons.person_outline,
                    size: 160.0,
                    color: colors.tempboxColor,
                  ),
                ))
          ]);
  }

  userNameContainer() {
    return Padding(
      padding: EdgeInsets.only(top: (CUR_USEREMAIL != "") ? 0.0 : 30.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 20,
            width: 20,
            child: Icon(Icons.person_rounded, color: colors.tempboxColor),
          ),
          Padding(
              padding: EdgeInsetsDirectional.only(start: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(getTranslated(context, 'name_lbl')!,
                      style: Theme.of(context).textTheme.subtitle2?.copyWith(
                            color: colors.tempboxColor,
                          )),
                  if (name != null)
                    Text(name!,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(color: colors.tempboxColor)),
                  /*   Form(
                      key: _formkey,
                      child: Container(
                          width: deviceWidth! / 1.7,
                          child: TextFormField(
                            readOnly: true,
                            cursorColor: colors.tempboxColor,
                            validator: (val) => nameValidation(val!, context),
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.all(0),
                            ),
                            controller: nameC,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                ?.copyWith(color: colors.tempboxColor),
                          ))), */
                ],
              )),
          Spacer(),
          Padding(
            padding: EdgeInsetsDirectional.only(end: 15),
            child: InkWell(
              child: Icon(Icons.edit_rounded, color: colors.tempboxColor),
              onTap: () {
                //show bottomsheet to edit name
                editNameBottomSheet();
              },
            ),
          )
        ],
      ),
    );
  }

  editNameBottomSheet() {
    showModalBottomSheet<dynamic>(
        context: context,
        elevation: 3.0,
        // isDismissible: false,
        //it will be closed only when user click On Save button & not by clicking anywhere else in screen
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        enableDrag: false,
        // useRootNavigator: ,
        builder: (BuildContext context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
                padding: EdgeInsetsDirectional.only(
                    bottom: 20.0, top: 5.0, start: 20.0, end: 20.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: Theme.of(context).colorScheme.boxColor),
                child: Form(
                    key: _nameFormKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                              padding: EdgeInsetsDirectional.all(10.0),
                              child: Text(
                                getTranslated(context, 'update_name')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                    ),
                              )),
                          Padding(
                              padding: EdgeInsetsDirectional.only(top: 10.0),
                              child: TextFormField(
                                autofocus: true,
                                textInputAction: TextInputAction.done,
                                controller: nameC,
                                validator: (val) =>
                                    nameValidation(val!, context),
                                style: Theme.of(this.context)
                                    .textTheme
                                    .subtitle1
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                                /*  onChanged: (String value) {
                                  setState(() {
                                    name = value;
                                  });
                                }, */
                                decoration: InputDecoration(
                                  hintText: getTranslated(context, 'name_lbl'),
                                  hintStyle: Theme.of(this.context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(color: colors.tempBorderColor),
                                  filled: true,
                                  fillColor:
                                      Theme.of(context).colorScheme.boxColor,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 17),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .borderColor
                                            .withOpacity(0.7)),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .borderColor
                                            .withOpacity(0.7),
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              )),
                          SizedBox(height: 10),
                          Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: colors.primary, //bgColor
                                  // onPrimary: colors.tempboxColor,
                                  //foregroundColor/TextColor
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7.0)),
                                ),
                                child: Container(
                                  height: 55.0, //48.0,
                                  width: deviceWidth! * 0.3,
                                  alignment: Alignment.center,
                                  /* decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(7.0)), */
                                  child: Text(
                                    getTranslated(context, 'save_lbl')!,
                                    // textAlign: TextAlign.center,
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .headline6
                                        ?.copyWith(
                                            color: colors.tempboxColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16, //21,
                                            letterSpacing: 0.6),
                                  ),
                                ),
                                onPressed: () async {
                                  if (!isSaveClicked) {
                                    isSaveClicked = true;
                                    //allow to click only once
                                    final form = _nameFormKey.currentState;
                                    if (form!.validate()) {
                                      form.save();
                                      _isNetworkAvail =
                                          await isNetworkAvailable();
                                      if (_isNetworkAvail) {
                                        Future.delayed(Duration(seconds: 1))
                                            .then((_) async {
                                          setState(() {
                                            name = nameC!.text;
                                          });
                                          //call name updt API
                                          _setUpdateProfile(name!, "", "");
                                          Navigator.pop(context);
                                        });
                                      } else {
                                        Future.delayed(Duration(seconds: 1))
                                            .then((_) async {
                                          showSnackBar(
                                              getTranslated(
                                                  context, 'internetmsg')!,
                                              context);
                                        });
                                      }
                                    }
                                  } else {
                                    print("tapped Twice");
                                    if (nameC!.text != "")
                                      Navigator.pop(context);
                                  }
                                },
                              )
                              /* InkWell(
                              focusColor: colors.secondaryColor,
                              child: Container(
                                height: 48.0,
                                width: deviceWidth! * 0.3,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: colors.primary,
                                    borderRadius: BorderRadius.circular(7.0)),
                                child: Text(
                                  getTranslated(context, 'save_lbl')!,
                                  style: Theme.of(this.context)
                                      .textTheme
                                      .headline6
                                      ?.copyWith(
                                          color: colors.tempboxColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 21,
                                          letterSpacing: 0.6),
                                ),
                              ),
                              onTap: () async {
                                final form = _nameFormKey.currentState;
                                if (form!.validate()) {
                                  form.save();
                                  _isNetworkAvail = await isNetworkAvailable();
                                  if (_isNetworkAvail) {
                                    Future.delayed(Duration(seconds: 1))
                                        .then((_) async {
                                      setState(() {
                                        name = nameC!.text;
                                      });
                                      //call name updt API
                                      _setUpdateProfile(name!, "", "");
                                      Navigator.pop(context);
                                    });
                                  } else {
                                    Future.delayed(Duration(seconds: 1))
                                        .then((_) async {
                                      showSnackBar(
                                          getTranslated(
                                              context, 'internetmsg')!,
                                          context);
                                    });
                                  }
                                }
                              },
                            ), */
                              )
                        ],
                      ),
                    )))));
  }

  userMobileContainer() {
    return Padding(
        padding: EdgeInsets.only(top: 7.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 20,
              width: 20,
              child:
                  Icon(Icons.phone_iphone_rounded, color: colors.tempboxColor),
            ),
            Padding(
                padding: EdgeInsetsDirectional.only(start: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(getTranslated(context, 'mobile_lbl')!,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(color: colors.tempboxColor)),
                    Form(
                        key: _formkey1,
                        child: Container(
                            width: deviceWidth! / 1.7,
                            child: TextFormField(
                              readOnly: isEditMono ? false : true,
                              onSaved: (newValue) {
                                setState(() {
                                  mobile = newValue!;
                                });
                              },
                              validator: (val) => mobValidation(val!, context),
                              decoration: new InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.all(0),
                              ),
                              controller: monoC,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(color: colors.tempboxColor),
                            ))),
                  ],
                )),
            Spacer(),
            if (type != login_mbl)
              !isEditMono
                  ? InkWell(
                      child: Icon(Icons.edit_rounded, color: colors.bgColor),
                      onTap: () {
                        setState(() {
                          isEditMono = true;
                        });
                      },
                    )
                  : InkWell(
                      child: Icon(
                        Icons.check_box,
                        size: 20,
                        color: colors.tempboxColor,
                      ),
                      onTap: () {
                        final form = _formkey1.currentState;
                        if (form!.validate()) {
                          form.save();
                          setState(() {
                            mobile = monoC!.text;
                          });
                          _setUpdateProfile("", mobile, "");
                        }
                      },
                    )
            // : SizedBox.shrink(),
          ],
        ));
  }

  userEmailContainer() {
    return Padding(
        padding: EdgeInsets.only(top: 7.0),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
            height: 20,
            width: 20,
            child: Icon(Icons.email_rounded, color: colors.tempboxColor),
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(start: 20.0),
            child: Form(
                key: _formkey2,
                child: Container(
                    width: deviceWidth! / 1.7,
                    child: TextFormField(
                      readOnly: isEditEmail ? false : true,
                      onSaved: (newValue) {
                        setState(() {
                          email = newValue!;
                        });
                      },
                      validator: (val) => emailValidation(val!, context),
                      decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.all(0),
                      ),
                      controller: emailC,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          ?.copyWith(color: colors.tempboxColor),
                    ))),
          ),
          Spacer(),
          if (type != login_email && type != login_fb && type != login_gmail)
            !isEditEmail
                ? InkWell(
                    child: Icon(Icons.edit_rounded, color: colors.tempboxColor),
                    onTap: () {
                      setState(() {
                        isEditEmail = true;
                      });
                    },
                  )
                : InkWell(
                    child: Icon(
                      Icons.check_box,
                      size: 20,
                      color: colors.tempboxColor,
                    ),
                    onTap: () {
                      final form = _formkey2.currentState;
                      if (form!.validate()) {
                        form.save();
                        setState(() {
                          email = emailC!.text;
                        });
                        _setUpdateProfile("", "", email!);
                      }
                    },
                  )
          // : SizedBox.shrink(),
        ]));
  }

  void onThemeChanged(int value) async {
    if (value == 1) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      themeNotifier!.setThemeMode(ThemeMode.light);
      setState(() {
        isDark = false;
      });
      setPrefrence(APP_THEME, LIGHT);
    } else if (value == 2) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
      themeNotifier!.setThemeMode(ThemeMode.dark);
      setState(() {
        isDark = true;
      });
      setPrefrence(APP_THEME, DARK);
    }
    theme = await getPrefrence(APP_THEME);
  }

  /* defaultFunction(bool? value) {
    // value ? SizedBox.shrink() : SizedBox.shrink();
    print("passed value is $value");
  } */

  /* defaultClickFunction() {
    return Setting();
    //print("default Function");
  } */

  setBody() {
    themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: EdgeInsets.only(top: 20.0, bottom: 80.0),
      child: Container(
          padding: EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Theme.of(context).colorScheme.controlSettings),
          child: ListView(
            padding: EdgeInsetsDirectional.only(top: 10.0),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: <Widget>[
              setDrawerItem(getTranslated(context, 'darkmode_lbl')!,
                  Icons.swap_horizontal_circle, true, false, isSwitched, 0
                  // defaultClickFunction()
                  /*  boolFunc: () {
                  toggleSwitch(isSwitched);
                  return null;
                }, */
                  ),
              setDrawerItem(getTranslated(context, 'notification_lbl')!,
                  Icons.notifications_rounded, true, false, isnotiEnabled, 1
                  // notiStatus(),
                  /* boolFunc: () {
                toggleNotification(isnotiEnabled);
                return null;
              } */
                  ),
              setDrawerItem(getTranslated(context, 'change_lang')!,
                  Icons.g_translate_rounded, false, true, false, 2
                  // LanguageList(),
                  /*  boolFunc: () {
                return null;
              } */
                  ),
              setDrawerItem(getTranslated(context, 'bookmark_lbl')!,
                  Icons.bookmarks_rounded, false, true, false, 3
                  // Bookmark(),
                  /* boolFunc: () {
                return null;
              } */
                  ),
              if (CUR_USERID != "" && role != "0")
                setDrawerItem(
                    getTranslated(context, 'CREATE_NEWS_LBL')!, Icons.add_box_outlined, false, true, false, 4
                    /* ManagePref(
                          from:
                              1), */ /*  boolFunc: () {
                      return null;
                    } */
                    ),
              if (CUR_USERID != "" && role != "0")
                setDrawerItem(
                    getTranslated(context, 'MANAGE_NEWS_LBL')!, Icons.edit_note, false, true, false, 5
                    /* ManagePref(
                          from:
                              1), */ /*  boolFunc: () {
                      return null;
                    } */
                    ),
              if (CUR_USERID != "")
                setDrawerItem(getTranslated(context, 'manage_prefrences')!,
                    Icons.thumbs_up_down_rounded, false, true, false, 6
                    /* ManagePref(
                          from:
                              1), */ /*  boolFunc: () {
                      return null;
                    } */
                    ),
              // : SizedBox.shrink(),

              setDrawerItem(getTranslated(context, 'contact_us')!,
                  Icons.contacts_rounded, false, true, false, 7
                  /* PrivacyPolicy(
                  title: getTranslated(context, 'contact_us')!,
                  from: "home",
                ), */
                  /*   boolFunc: () {
                return null;
              } */
                  ),
              setDrawerItem(getTranslated(context, 'about_us')!,
                  Icons.info_rounded, false, true, false, 8
                  /* PrivacyPolicy(
                  title: getTranslated(context, 'about_us')!,
                  from: "home",
                ), */
                  /*   boolFunc: () {
                return null;
              } */
                  ),
              setDrawerItem(getTranslated(context, 'term_cond')!,
                  Icons.chrome_reader_mode_outlined, false, true, false, 9
                  /* PrivacyPolicy(
                  title: getTranslated(context, 'term_cond')!,
                  from: "home",
                ), */
                  /*  boolFunc: () {
                return null;
              } */
                  ),
              setDrawerItem(getTranslated(context, 'privacy_policy')!,
                  Icons.security_rounded, false, true, false, 10
                  /* PrivacyPolicy(
                  title: getTranslated(context, 'privacy_policy')!,
                  from: "home",
                ), */
                  /* boolFunc: () {
                return null;
              } */
                  ),
              setDrawerItem(getTranslated(context, 'rate_us')!,
                  Icons.stars_sharp, false, true, false, 11
                  //defaultClickFunction(),
                  /*  boolFunc: () {
                return null;
              } */
                  ), // _openStoreListing()
              setDrawerItem(getTranslated(context, 'share_app')!,
                  Icons.share_rounded, false, true, false, 12
                  // defaultClickFunction(),
                  /*  boolFunc: () {
                return null;
              } */
                  ),
              /* "$appName\n\n$APPFIND$androidLink$packageName\n\n $IOSLBL\n$iosLink"*/
              if (CUR_USERID != "")
                setDrawerItem(getTranslated(context, 'logout_lbl')!,
                    Icons.logout_rounded, false, true, false, 13
                    // logOutDailog(),
                    /* boolFunc: () {
                      return null;
                    } */
                    ),
              if (CUR_USERID != "")
                setDrawerItem(getTranslated(context, 'delete_acc')!,
                    Icons.delete_forever_rounded, false, true, false, 14
                    // deleteAccount(),
                    /*   boolFunc: () {
                      return null;
                    } */
                    ),
              // : SizedBox.shrink(),
            ],
          )),
    );
  }

  /*  notiStatus() {
    print("notification bool Prefs set !!!");
    if (notiEnable!) {
      notiEnable = false;
      setPrefrenceBool(NOTIENABLE, false);
    } else {
      notiEnable = true;
      setPrefrenceBool(NOTIENABLE, true);
    }
    setState(() {});
  } */

  //rate app function
  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: appStoreId,
        microsoftStoreId: 'microsoftStoreId',
      );

  //set drawer item list press
  setDrawerItem(String title, IconData icon, bool isTrailing, bool isNavigate,
      bool isSwitch, int id) {
    // {required Function(bool)? boolFunc()}
    // Widget builderRoute,
    return ListTile(
      // key: ,
      dense: true,
      leading: Icon(icon),
      //isDark! ? icon : icon
      iconColor: Theme.of(context).colorScheme.settingIconColor,
      //colors.bgColor,
      trailing: (isTrailing)
          ? SizedBox(
              height: 45,
              width: 55,
              child: FittedBox(
                child: Switch.adaptive(
                  onChanged: (id == 0) ? toggleSwitch : toggleNotification,
                  value: (id == 0) ? isSwitched : isnotiEnabled,
                  activeColor: /* Theme.of(context).colorScheme.settingIconColor, */
                      colors.primary,
                  activeTrackColor: /*  Theme.of(context)
                      .colorScheme
                      .settingIconColor, */
                      colors.primary,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey,
                ),
                fit: BoxFit.fill,
              ))
          : SizedBox.shrink(),
      /* title == getTranslated(context, 'darkmode_lbl')! ||
              title == getTranslated(context, 'notification_lbl')!
          ? title == getTranslated(context, 'darkmode_lbl')!
              ? SizedBox(
                  height: 45,
                  width: 55,
                  child: FittedBox(
                    child: Switch.adaptive(
                      onChanged: toggleSwitch,
                      value: isSwitched,
                      activeColor:
                          Theme.of(context).colorScheme.settingIconColor,
                      activeTrackColor:
                          Theme.of(context).colorScheme.settingIconColor,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey,
                    ),
                    fit: BoxFit.fill,
                  ))
              : SizedBox(
                  height: 45,
                  width: 55,
                  child: FittedBox(
                    child: Switch.adaptive(
                      onChanged: toggleNotification,
                      value: isnotiEnabled,
                      activeColor:
                          Theme.of(context).colorScheme.settingIconColor,
                      activeTrackColor:
                          Theme.of(context).colorScheme.settingIconColor,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey,
                    ),
                    fit: BoxFit.fill,
                  ))
          : null, */
      title: Text(title,
          textScaleFactor: 1.07,
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
              color: Theme.of(context).colorScheme.settingIconColor)),
      //colors.bgColor)),
      onTap: () {
        //async
        if (isNavigate) {
          switch (id) {
            /* case 1:
              notiStatus();
              break; */
            case 2:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => LanguageList()));
              break;
            case 3:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Bookmark()));
              break;
            case 4:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AddNews()));
              break;
            case 5:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ShowNews()));
              break;
            case 6:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ManagePref(from: 1)));
              break;
            case 7:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PrivacyPolicy(
                            title: getTranslated(context, 'contact_us')!,
                            from: "setting",
                          )));
              break;
            case 8:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PrivacyPolicy(
                            title: getTranslated(context, 'about_us')!,
                            from: "setting",
                          )));
              break;
            case 9:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PrivacyPolicy(
                            title: getTranslated(context, 'term_cond')!,
                            from: "setting",
                          )));
              break;
            case 10:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => PrivacyPolicy(
                            title: getTranslated(context, 'privacy_policy')!,
                            from: "setting",
                          )));
              break;
            case 11:
              _openStoreListing();
              break;
            case 12:
              if (isRedundentClick(DateTime.now(), diff)) {
                //inBetweenClicks
                print('hold on, processing');
                /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                return;
              }
              var str =
                  "$appName\n\n$APPFIND$androidLink$packageName\n\n $IOSLBL\n$iosLink";
              Share.share(str);
              diff = resetDiff;
              break;
            case 13:
              logOutDailog();
              break;
            case 14:
              deleteAccount();
              break;
            default:
              break;
          }
          /* Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => builderRoute));
           } else {
          builderRoute; //call function */
        }

        /*  if (title == getTranslated(context, 'darkmode_lbl')!) { //0
        } else if (title == getTranslated(context, 'notification_lbl')!) {//1
          notiStatus();
        } else if (title == getTranslated(context, 'change_lang')!) {//2
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => LanguageList()));
        } else if (title == getTranslated(context, 'bookmark_lbl')!) {//3
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => Bookmark()));
        } else if (title == getTranslated(context, 'manage_prefrences')!) {//4
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => ManagePref(from: 1)));
        } else if (title == getTranslated(context, 'contact_us')!) {//5
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => PrivacyPolicy(
                        title: getTranslated(context, 'contact_us')!,
                        from: "home",
                      )));
        } else if (title == getTranslated(context, 'about_us')!) {//6
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => PrivacyPolicy(
                        title: getTranslated(context, 'about_us')!,
                        from: "home",
                      )));
        } else if (title == getTranslated(context, 'term_cond')!) {//7
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => PrivacyPolicy(
                        title: getTranslated(context, 'term_cond')!,
                        from: "home",
                      )));
        } else if (title == getTranslated(context, 'rate_us')!) {//8
          _openStoreListing();
        } else if (title == getTranslated(context, 'privacy_policy')!) {//9
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => PrivacyPolicy(
                        title: getTranslated(context, 'privacy_policy')!,
                        from: "home",
                      )));
        } else if (title == getTranslated(context, 'share_app')!) {//10
          var str =
              "$appName\n\n$APPFIND$androidLink$packageName\n\n $IOSLBL\n$iosLink";
          Share.share(str);
        } else if (title == getTranslated(context, 'logout_lbl')!) {//11
          logOutDailog();
        } else if (title == getTranslated(context, 'delete_acc')!) {//12
          deleteAccount();
        } */
      },
    );
  }

  toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
      _updateState(2);
    } else {
      setState(() {
        isSwitched = false;
      });
      _updateState(1);
    }
  }

  toggleNotification(bool value) {
    if (isnotiEnabled == false) {
      setState(() {
        isnotiEnabled = true;
        notiEnable = true;
        setPrefrenceBool(NOTIENABLE, true);
      });
    } else {
      setState(() {
        isnotiEnabled = false;
        notiEnable = false;
        setPrefrenceBool(NOTIENABLE, false);
      });
    }
    // notiStatus();
  }

  //google sign out function
/*   void signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Signed Out");
  } */

  //set logout dialogue
  logOutDailog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.fontColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Text(
                getTranslated(context, 'LOGOUTTXT')!,
                style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .controlBGColor), //fontColor),
              ),
              actions: <Widget>[
                new TextButton(
                    child: Text(
                      getTranslated(context, 'NO')!,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.controlBGColor,
                              //fontColor,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                new TextButton(
                    child: Text(
                      getTranslated(context, 'YES')!,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.controlBGColor,
                              //fontColor,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      await googleSignIn.signOut();
                      // await facebookSignIn.logOut(); //fbAud
                      await _auth.signOut();
                      clearUserSession();
                      redirectToLogin();
                      /*  Future.delayed(const Duration(milliseconds: 500), () {
                        setState(() {
                          Navigator.of(_scaffoldKey.currentContext!)
                              .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Login()),
                                  (Route<dynamic> route) => false);
                        });
                      }); */
                    })
              ],
            );
          });
        });
  }

  //set Delete dialogue
  deleteAccount() async {
    // print("current User - ${_auth.currentUser} -- local prefs - ${user}");
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.fontColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Text(
                (_auth.currentUser != null)
                    ? getTranslated(context, 'delete_confirm')!
                    : getTranslated(context, 'delete_relogin')!,
                style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .controlBGColor), //fontColor),
              ),
              title: (_auth.currentUser != null)
                  ? Text(getTranslated(context, 'delete_acc')!)
                  : Text(getTranslated(context, 'delete_alert_title')!),
              titleTextStyle: Theme.of(this.context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(
                      color: Theme.of(context).colorScheme.controlBGColor),
              //fontColor),
              actions: <Widget>[
                new TextButton(
                    child: Text(
                      (_auth.currentUser != null)
                          ? getTranslated(context, 'NO')!
                          : getTranslated(context, 'cancel_btn')!,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .controlBGColor, //fontColor,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                new TextButton(
                    child: Text(
                      (_auth.currentUser != null)
                          ? getTranslated(context, 'YES')!
                          : getTranslated(context, 'logout_lbl')!,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .controlBGColor, //fontColor,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      (_auth.currentUser != null && user != null)
                          ? ProceedToDeleteProfile() //deleteUserFromDatabase() //
                          : askToLoginAgain();
                      /*  Future.delayed(const Duration(milliseconds: 500), () {
                        setState(() {
                          Navigator.of(_scaffoldKey.currentContext!)
                              .pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Login()),
                                  (Route<dynamic> route) => false);
                        });
                      }); */
                      // final User? user = _auth.currentUser;
                      /*  print("Current user id before deletion $CUR_USERID");
                      if (user != null) {
                        if (CUR_USERID != "") {
                          //delete user from firebase
                          // user.delete();
                          //delete user from Admin panel
                          //add APi code here
                          deleteUserFromDatabase();
                          //delete user prefs from App-local
                          // clearUserSession();
                          Future.delayed(const Duration(milliseconds: 500), () {
                            setState(() {
                              Navigator.of(_scaffoldKey.currentContext!)
                                  .pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              Login()),
                                      (Route<dynamic> route) => false);
                            });
                          });
                        } else {
                          print("Please Login first !!");
                        }
                      } else {
                        print("please Login again !!");
                        showSnackBar('login_req_msg', context);
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setState(() {
                            Navigator.of(_scaffoldKey.currentContext!)
                                .pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            Login()),
                                    (Route<dynamic> route) => false);
                          });
                        });
                      } */
                      // print("User Details $user");
                    })
              ],
            );
          });
        });
  }

  redirectToLogin() {
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        Navigator.of(_scaffoldKey.currentContext!).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Login()),
            (Route<dynamic> route) => false);
      });
    });
  }

  askToLoginAgain() {
    print("please Login again !!");
    showSnackBar(getTranslated(context, 'login_req_msg')!, context);
    redirectToLogin();
  }

  /*  ProceedToDeleteProfile() {
    //delete user from firebase
    // if (user != null) {
    try {
      user!.delete().then((value) {
        print("user deleted from Firebase");
        deleteUserFromDatabase();
        //delete user prefs from App-local
        // clearUserSession();
        redirectToLogin();
      });
    } catch (e) {
      showSnackBar(e.toString(), context);
      // askToLoginAgain();
    }
    /* } else {
      askToLoginAgain();
    } */
  } */

  ProceedToDeleteProfile() async {
    //delete user from firebase
    try {
      await user!.delete().then((value) {
        print("user deleted from Firebase");
        //delete user prefs from App-local
        deleteUserFromDatabase();
      });
    } on FirebaseAuthException catch (error) {
      if (error.code == "requires-recent-login") {
        clearUserSession();
        askToLoginAgain();
      } else {
        throw showSnackBar('${error.message}', context);
      }
      // print("unable to delete user - ${error.message} - ${error.code}");
    } catch (e) {
      print("unable to delete user - ${e.toString()}");
    }
  }

  Future<void> deleteUserFromDatabase() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (!_isLoading)
        setState(() {
          _isLoading = true;
        });
      //  if (CUR_USERID == "") return;
      // showSnackBar('please login again !!', context);
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
      };
      print("Param value - $param");

      Response response =
          await post(Uri.parse(userDeleteApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));
      var getdata = json.decode(response.body);

      String error = getdata["error"];
      if (error == "false") {
        print("response from APi - $getdata");
        showSnackBar(getdata["message"], context);
        //Success !!!
        //User deleted
        clearUserSession();
        redirectToLogin();
        await googleSignIn.signOut();
        await _auth.signOut();
      } else {
        //show error message
        showSnackBar(getdata["message"], context);
      }
      if (_isLoading)
        setState(() {
          _isLoading = false;
        });
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(getTranslated(context, 'internetmsg')!, context)!;
    }
  }
}
