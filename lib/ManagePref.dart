import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Widgets.dart';

import 'Helper/Color.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Model/Category.dart';

class ManagePref extends StatefulWidget {
  final int? from;

  const ManagePref({Key? key, this.from}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateManagePref();
  }
}

class StateManagePref extends State<ManagePref> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isNetworkAvail = true;
  bool _isLoading = true;
  List<Category> catList = [];
  String catId = "";
  List<String> selectedChoices = [];
  String selCatId = "";

  static int _count = 0;
  List<bool> _checks = [];

  int offset = 0;
  int total = 0;
  ScrollController _scrlController = new ScrollController();

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getCat();
    _scrlController.addListener(_catScrlListener);
    getUserByCat();
    // print("Length of SelectedChoices - ${selectedChoices.length}");
  }

  void dispose() {
    _scrlController.removeListener(_catScrlListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey, appBar: getAppBar(), body: contentView());
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID) ?? "";
    setState(() {});
  }

  _catScrlListener() {
    if (_scrlController.offset >= _scrlController.position.maxScrollExtent &&
        !_scrlController.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          if (offset < total) getCat();
        });
      }
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
        // print("user data $data");

        for (int i = 0; i < data.length; i++) {
          catId = data[i]["category_id"];
        }
        setState(() {
          selectedChoices = catId == "" ? catId.split('') : catId.split(',');
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  Future<void> getCat() async {
    if (category_mode == "1") {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        var param = {
          ACCESS_KEY: access_key,
          OFFSET: offset.toString(),
          LIMIT: perPage.toString()
        };
        Response response =
            await post(Uri.parse(getCatApi), body: param, headers: headers)
                .timeout(Duration(seconds: timeOut));
        var getdata = json.decode(response.body);

        String error = getdata["error"];

        if (error == "false") {
          total = int.parse(getdata["total"]);
          var data = getdata["data"];
          var temp = (data as List)
              .map((data) => new Category.fromJson(data))
              .toList();
          if (catList.length < total) {
            catList.addAll(temp);
          }

          offset = offset + perPage;
          if (mounted)
            setState(() {
              _count = catList.length;
              _checks = List.generate(
                  _count,
                  (i) =>
                      (selectedChoices.contains(catList[i].id)) ? true : false);
              // print("value of Checks - SetState ${_checks.toList()}");
              _isLoading = false;
            });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      }
    } else {
      showSnackBar(getTranslated(context, 'disabled_category')!, context);
      setState(() {
        _isLoading = false;
      });
    }
  }

  //set skip login btn
  skipBtn() {
    return widget.from == 2 //@ Start
        ? Padding(
            padding: EdgeInsetsDirectional.only(end: 10.0),
            child: Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = false;
                  });
                  _setUserCat();
                },
                child: Text(getTranslated(context, 'skip')!),
                style: ButtonStyle(
                  overlayColor:
                      MaterialStateProperty.all(colors.transparentColor),
                  foregroundColor: MaterialStateProperty.all(
                      colors.darkColor1.withOpacity(0.4)),
                ),
              ),
            ))
        : SizedBox.shrink();
  }

  //set appbar
  getAppBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 85),
        child: AppBar(
          // systemOverlayStyle:
          //     !isDark! ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
          //leadingWidth: 25,
          // elevation: 0.0,
          centerTitle: false, //true,
          backgroundColor: Colors.transparent,
          title: Transform(
            transform: Matrix4.translationValues(
                (widget.from == 1) ? -20.0 : -50.0, 0.0, 0.0),
            child: Text(
              getTranslated(context, 'manage_prefrences')!,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: !isDark! ? colors.secondaryColor : colors.bgColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 10),
            child: selectCatTxt(),
          ),
          actions: [skipBtn()],
          leading: (widget.from == 1) //from Setting
              ? setBackButton(
                  context, !isDark! ? colors.secondaryColor : colors.bgColor)
              /* IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: !isDark! ? colors.secondaryColor : colors.bgColor),
                  onPressed: () => Navigator.of(context).pop(),
                  splashColor: Colors.transparent,
                ) */
              : SizedBox.shrink(),
        ));
  }

  contentView() {
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.only(
          start: 15.0, end: 15.0, bottom: 20.0), //top: 30.0,
      controller: _scrlController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [getBuilder(), if (!_isLoading) nxtBtn()],
      ),
    );
  }

  selectCatTxt() {
    return Transform(
      transform: Matrix4.translationValues(-50.0, 0.0, 0.0),
      child: Text(
        getTranslated(context, 'sel_pref_cat')!,
        style: Theme.of(context).textTheme.headline6?.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.w100,
            letterSpacing: 0.5),
      ),
    );
  }

  getBuilder() {
    return !_isLoading
        ? Padding(
            padding: EdgeInsetsDirectional.only(top: 25.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
              shrinkWrap: true,
              itemCount: catList.length,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return new Container(
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      /* image: DecorationImage(
                          image: Image.network(catList[index].image!).image,
                          fit: BoxFit.fill), */
                    ),
                    child: InkWell(
                      onTap: () {
                        _checks[index] = !_checks[index];
                        // print("Length of SelectedChoices - ${selectedChoices.length} -- ${_checks[index]} -- elements - ${selectedChoices.toList()}");
                        if (selectedChoices.contains(catList[index].id)) {
                          selectedChoices.remove(catList[index].id);
                          setState(() {});
                        } else {
                          selectedChoices.add(catList[index].id!);
                          setState(() {});
                        }
                        if (selectedChoices.length == 0) {
                          setState(() {
                            selectedChoices.add("0");
                          });
                        } else {
                          if (selectedChoices.contains("0")) {
                            selectedChoices = List.from(selectedChoices)
                              ..remove("0");
                          }
                        }
                        // print("value of Checks - @ end of Tap ${_checks.toList()}");
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            child: CachedNetworkImage(
                                fadeInDuration: Duration(milliseconds: 150),
                              imageUrl:
                                  catList[index].image!,
                              height: deviceHeight! / 2.9,
                              width: deviceWidth!,
                              fit: BoxFit.fill,
                              errorWidget: (context, error, stackTrace) =>
                                  errorWidget(
                                      deviceHeight! / 5.9, deviceWidth! / 2.2),
                              placeholder: (context,url) {return placeHolder();},
                            ),
                          ),
                          Column(
                            children: [
                              Align(
                                  //checkbox
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    margin: EdgeInsets.only(right: 10, top: 10),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: selectedChoices
                                              .contains(catList[index].id)
                                          ? colors.primary
                                          : colors.bgColor,
                                    ),
                                    child: selectedChoices
                                            .contains(catList[index].id)
                                        ? Icon(
                                            Icons.check_rounded,
                                            color: colors.bgColor,
                                            size: 20,
                                          )
                                        : null,
                                    /* InkWell(
                                      child: selectedChoices
                                              .contains(catList[index].id)
                                          ? Icon(
                                              Icons.check_rounded,
                                              color: colors.bgColor,
                                              size: 20,
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(5),
                                      onTap: () {
                                        _checks[index] = !_checks[index];
                                        // print("Length of SelectedChoices - ${selectedChoices.length} -- ${_checks[index]} -- elements - ${selectedChoices.toList()}");
                                        if (selectedChoices
                                            .contains(catList[index].id)) {
                                          selectedChoices
                                              .remove(catList[index].id);
                                          setState(() {});
                                        } else {
                                          selectedChoices.add(catList[index].id!);
                                          setState(() {});
                                        }
                                        if (selectedChoices.length == 0) {
                                          setState(() {
                                            selectedChoices.add("0");
                                          });
                                        } else {
                                          if (selectedChoices.contains("0")) {
                                            selectedChoices =
                                                List.from(selectedChoices)
                                                  ..remove("0");
                                          }
                                        }
                                        // print("value of Checks - @ end of Tap ${_checks.toList()}");
                                      },
                                      splashColor: Colors.transparent,
                                    ), */
                                  )),
                              Spacer(),
                              ClipRRect(
                                //Text with shadermask
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15.0),
                                    bottomRight: Radius.circular(15.0)),
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          /* Theme.of(context)
                                          .colorScheme
                                          .darkColor */
                                          colors.blackColor.withOpacity(0.7)
                                        ]).createShader(bounds);
                                  },
                                  blendMode: BlendMode.overlay,
                                  child: Container(
                                    height: 60,
                                    width: double.infinity,
                                    color: Colors.transparent,
                                    padding: EdgeInsets.only(top: 30),
                                    child: Padding(
                                      padding:  EdgeInsetsDirectional.only(start: 10),
                                      child: Text(
                                        catList[index].categoryName!,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: /*  isDark!
                                            ? Colors.black
                                            : */
                                                Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ));
              },
            ),
          )
        : Container(
            padding: EdgeInsetsDirectional.only(top: 25.0),
            alignment: Alignment.center,
            child: showCircularProgress(_isLoading, colors.primary),
          );
  }

  nxtBtn() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: InkWell(
          child: Container(
            height: 55.0,
            width: deviceWidth! * 0.95,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(15.0)),
            child: Text(
              (widget.from == 2) //@Start
                  ? getTranslated(context, 'nxt')!
                  : getTranslated(context, 'save_lbl')!, //from Settings
              style: Theme.of(this.context).textTheme.headline6?.copyWith(
                  color: colors.bgColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 21),
            ),
          ),
          onTap: () async {
            if (CUR_USERID != "") {
              _setUserCat();
            } else {
              // showSnackBar(getTranslated(context, 'login_req_msg')!, context);
              loginRequired(context);
            }
          }),
    );
  }

  _setUserCat() async {
    // print("Length of SelectedChoices @ Nxt button - ${selectedChoices.length}");
    if (selectedChoices.length == 0) {
      //no preference selected
      Navigator.of(context)
          .pushNamedAndRemoveUntil("/home", (Route<dynamic> route) => false);
      return;
    } else if (selectedChoices.length == 1) {
      setState(() {
        selCatId = selectedChoices.join();
      });
    } else {
      setState(() {
        selCatId = selectedChoices.join(',');
      });
    }

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        CATEGORY_ID: selCatId,
      };
      Response response =
          await post(Uri.parse(setUserCatApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      String error = getdata["error"];
      String msg = getdata["message"];
      showSnackBar(msg, context);

      if (error == "false") {
        showSnackBar(getTranslated(context, 'prefrence_save')!, context);

        if (selCatId == "0") {
          String catId = "";
          setPrefrence(cur_catId, catId);
        } else {
          String catId = selCatId;
          setPrefrence(cur_catId, catId);
        }
        Navigator.of(context)
            .pushNamedAndRemoveUntil("/home", (Route<dynamic> route) => false);
      } else {
        showSnackBar(getTranslated(context, 'prefrence_save')!, context);

        String catId = selCatId;
        setPrefrence(cur_catId, catId);

        Navigator.of(context)
            .pushNamedAndRemoveUntil("/home", (Route<dynamic> route) => false);
      }
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      });
    }
  }
}
