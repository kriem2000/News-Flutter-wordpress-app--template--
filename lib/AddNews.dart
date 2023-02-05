import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' as fo;
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:news/EditNews.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:news/Helper/Widgets.dart';
import 'package:news/Helper/dashedRect.dart';
import 'package:news/Model/TagModel.dart';
import 'package:news/NewsDescription.dart';
import 'package:file_picker/file_picker.dart';
import 'package:news/ShowNews.dart';
import 'Helper/Constant.dart';
import 'Model/Category.dart';
import 'Model/News.dart';

class AddNews extends StatefulWidget {
  @override
  AddNewsState createState() => AddNewsState();
}

class AddNewsState extends State<AddNews> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<Category> catList = [];
  List<TagModel> tagList = [];
  bool _isNetworkAvail = true;
  bool catLoading = false;
  bool tagLoading = false;
  String catSel = "";
  String subCatSel = "";
  String conType = "";
  String conTypeId = "standard_post";
  String? title;
  String? catSelId, subSelId, showTill, url, desc;
  int? catIndex;
  List<String> tagsName = [];
  List<String> tagsId = [];
  Map<String, String> contentType = {};
  List<File> otherImage = [];
  File? image;
  bool isNext = false;
  bool isCheck = false;

  //String result = '';
  // HtmlEditorController controller = HtmlEditorController();
  TextEditingController titleC = TextEditingController();
  TextEditingController urlC = TextEditingController();
  bool isLoading = false;
  File? videoUpload;
  bool isDescLoading = true;

  clearText() {
    setState(() {
      catSel = "";
      subCatSel = "";
      conType = getTranslated(context, 'STANDARD_POST_LBL')!;
      title = null;
      catSelId = null;
      subSelId = null;
      showTill = null;
      conTypeId = 'standard_post';
      url = null;
      catIndex = null;
      tagsName = [];
      tagsId = [];
      otherImage = [];
      image = null;
      isNext = false;
      //  result = '';
      // controller.clear();
      titleC.clear();
      urlC.clear();
      videoUpload = null;
      desc = null;
      // result = '';
      isCheck = false;
    });
  }

  @override
  void initState() {
    getCurrentUserDetails();
    getCat();
    getTag();
    super.initState();
  }

  @override
  void dispose() {
    // controller.disable();
    titleC.dispose();
    urlC.dispose();
    super.dispose();
  }

  Future<void> getCurrentUserDetails() async {
    CUR_USERID = (await getPrefrence(ID)) ?? "";
    conType = getTranslated(context, 'STANDARD_POST_LBL')!;
    setState(() {});
  }

  Future<void> getCat() async {
    if (catList.isEmpty) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        if (!catLoading && mounted)
          setState(() {
            catLoading = true;
          });
        var param = {
          ACCESS_KEY: access_key,
        };
        Response response =
            await post(Uri.parse(getCatApi), body: param, headers: headers)
                .timeout(Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        String error = getdata["error"];
        if (error == "false") {
          catList.clear();

          var data = getdata["data"];
          // print("data subcat - cat -- $data");
          var tempCategories = (data as List)
              .map((data) => new Category.fromJson(data))
              .toList();

          catList.addAll(tempCategories);
        }
        if (catLoading && mounted)
          setState(() {
            catLoading = false;
          });
      } else {
        setState(() {
          catLoading = false;
        });
        showSnackBar(getTranslated(context, 'internetmsg')!, context)!;
      }
    }
  }

  Future<void> getTag() async {
    if (tagList.isEmpty) {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        if (!tagLoading && mounted)
          setState(() {
            tagLoading = true;
          });
        var param = {
          ACCESS_KEY: access_key,
        };
        Response response =
            await post(Uri.parse(getTagsApi), body: param, headers: headers)
                .timeout(Duration(seconds: timeOut));
        var getdata = json.decode(response.body);
        String error = getdata["error"];
        if (error == "false") {
          tagList.clear();

          var data = getdata["data"];

          var tempTags = (data as List)
              .map((data) => new TagModel.fromJson(data))
              .toList();

          tagList.addAll(tempTags);
          print("tagList len****${tagList.length}");
        }
        if (tagLoading && mounted)
          setState(() {
            tagLoading = false;
          });
      } else {
        setState(() {
          tagLoading = false;
        });
        showSnackBar(getTranslated(context, 'internetmsg')!, context)!;
      }
    }
  }

  //set appbar
  getAppBar() {
    if (!isNext)
      return PreferredSize(
          preferredSize: Size(double.infinity, 45),
          child: AppBar(
            // systemOverlayStyle: !isDark!
            //     ? SystemUiOverlayStyle.dark
            //     : SystemUiOverlayStyle.light,
            // leadingWidth: 50,
            // elevation: 0.0,
            centerTitle: false,
            //true,
            backgroundColor: Colors.transparent,
            title: Transform(
              transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
              child: Text(
                getTranslated(context, 'CREATE_NEWS_LBL')!,
                style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Theme.of(context).colorScheme.darkColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
            ),
            leading: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: InkWell(
                onTap: () {
                  if (!isNext) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      isNext = false;
                    });
                  }
                },
                child: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.darkColor),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ),

            actions: [
              Container(
                padding: EdgeInsetsDirectional.only(end: 20),
                alignment: Alignment.center,
                child: Text(getTranslated(context, 'STEP1TO2_LBL')!,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .darkColor
                            .withOpacity(0.6))),
              )
            ],
          ));
  }

  Widget catSelectionName() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: InkWell(
        onTap: () {
          catListBottomSheet();
        },
        child: Container(
          // height: 55,
          width: deviceWidth!,
          alignment: Alignment.centerLeft,
          // margin: EdgeInsetsDirectional.only(: 7),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          //  padding: EdgeInsetsDirectional.only(
          //   /* top: 10.0, bottom: 10.0, */ start: 10, end: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.boxColor,
            borderRadius: BorderRadius.circular(10.0),
            /* border:
                  Border.all(color: Theme.of(context).colorScheme.borderColor */
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                catSel == "" ? getTranslated(context, 'CAT_LBL')! : catSel,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: catSel == ""
                          ? Theme.of(context)
                              .colorScheme
                              .darkColor
                              .withOpacity(0.6)
                          : Theme.of(context).colorScheme.darkColor,
                    ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.keyboard_arrow_down_outlined,
                    color: Theme.of(context).colorScheme.darkColor),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget subCatSelectionName() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: InkWell(
        onTap: () {
          if (catSel == "") {
            showSnackBar(getTranslated(context, 'PLZ_SEL_CAT_LBL')!, context);
          } else if (catList[catIndex!].subData!.isEmpty) {
            showSnackBar(
                getTranslated(context, 'SUBCAT_NOT_AVAIL_LBL')!, context);
          } else {
            subCatListBottomSheet();
          }
        },
        child: Container(
          // height: 55,
          width: deviceWidth!,
          alignment: Alignment.centerLeft,
          // margin: EdgeInsetsDirectional.only(: 7),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          //  padding: EdgeInsetsDirectional.only(
          //   /* top: 10.0, bottom: 10.0, */ start: 10, end: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.boxColor,
            borderRadius: BorderRadius.circular(10.0),
            /* border:
                  Border.all(color: Theme.of(context).colorScheme.borderColor */
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subCatSel == ""
                    ? getTranslated(context, 'SUBCAT_LBL')!
                    : subCatSel,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: subCatSel == ""
                          ? Theme.of(context)
                              .colorScheme
                              .darkColor
                              .withOpacity(0.6)
                          : Theme.of(context).colorScheme.darkColor,
                    ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.keyboard_arrow_down_outlined,
                    color: Theme.of(context).colorScheme.darkColor),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget contentTypeSelName() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: InkWell(
        onTap: () {
          contentTypeBottomSheet();
        },
        child: Container(
          // height: 55,
          width: deviceWidth!,
          alignment: Alignment.centerLeft,
          // margin: EdgeInsetsDirectional.only(: 7),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          //  padding: EdgeInsetsDirectional.only(
          //   /* top: 10.0, bottom: 10.0, */ start: 10, end: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.boxColor,
            borderRadius: BorderRadius.circular(10.0),
            /* border:
                  Border.all(color: Theme.of(context).colorScheme.borderColor */
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                conType == ""
                    ? getTranslated(context, 'CONTENT_TYPE_LBL')!
                    : conType,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    color: conType == ""
                        ? Theme.of(context)
                            .colorScheme
                            .darkColor
                            .withOpacity(0.6)
                        : Theme.of(context).colorScheme.darkColor),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.keyboard_arrow_down_outlined,
                    color: Theme.of(context).colorScheme.darkColor),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget contentVideoUpload() {
    return conType == getTranslated(context, 'VIDEO_UPLOAD_LBL')!
        ? Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: InkWell(
              onTap: () {
                _getFromGalleryVideo();
              },
              child: Container(
                //height: 80,
                width: deviceWidth!,
                alignment: Alignment.centerLeft,
                /*   margin: EdgeInsetsDirectional.only(
                    top: 7, bottom: 7, start: 7, end: 7), */
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                //  padding: EdgeInsetsDirectional.only(
                //   /* top: 10.0, bottom: 10.0, */ start: 10, end: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.boxColor,
                  borderRadius: BorderRadius.circular(10.0),
                  /* border:
                  Border.all(color: Theme.of(context).colorScheme.borderColor */
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        videoUpload == null
                            ? getTranslated(context, 'UPLOAD_VIDEO_LBL')!
                            : videoUpload!.path.split('/').last,
                        maxLines: 2,
                        softWrap: true,
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              overflow: TextOverflow.ellipsis,
                              color: videoUpload == null
                                  ? Theme.of(context)
                                      .colorScheme
                                      .darkColor
                                      .withOpacity(0.6)
                                  : Theme.of(context).colorScheme.darkColor,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 20.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.file_upload_outlined,
                            color: Theme.of(context).colorScheme.darkColor),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : SizedBox.shrink();
  }

  Widget contentUrlSet() {
    if (conType == getTranslated(context, 'VIDEO_YOUTUBE_LBL')! ||
        conType == getTranslated(context, 'VIDEO_OTHER_URL_LBL')!) {
      return Container(
          width: deviceWidth!,
          margin: EdgeInsetsDirectional.only(top: 18),
          /*  padding: EdgeInsetsDirectional.only(
            top: 7.0, bottom: 7.0, start: 10, end: 10), */
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.boxColor),
          child: TextFormField(
            textInputAction: TextInputAction.next,
            maxLines: 1,
            controller: urlC,
            style: Theme.of(this.context)
                .textTheme
                .subtitle1
                ?.copyWith(color: Theme.of(context).colorScheme.darkColor),
            validator: (val) => urlValidation(val!, context),
            onChanged: (String value) {
              setState(() {
                url = value;
              });
            },
            decoration: InputDecoration(
              hintText: conType == getTranslated(context, 'VIDEO_YOUTUBE_LBL')!
                  ? getTranslated(context, 'YOUTUBE_URL_LBL')!
                  : getTranslated(context, 'OTHER_URL_LBL')!,
              hintStyle: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                  color:
                      Theme.of(context).colorScheme.darkColor.withOpacity(0.6)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.boxColor,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 25, vertical: 17),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ));
    } else {
      return SizedBox.shrink();
    }
  }

  contentTypeBottomSheet() {
    showModalBottomSheet<dynamic>(
        context: context,
        elevation: 3.0,
        isScrollControlled: true,
        // isDismissible: false,
        //it will be closed only when user click On Save button & not by clicking anywhere else in screen
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        enableDrag: false,
        // useRootNavigator: ,
        builder: (BuildContext context) => Container(
            padding: EdgeInsetsDirectional.only(
                bottom: 15.0, top: 15.0, start: 20.0, end: 20.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: Theme.of(context).colorScheme.boxColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(context, 'SEL_CONTENT_TYPE_LBL')!,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.darkColor,
                      ),
                ),
                Padding(
                    padding:
                        EdgeInsetsDirectional.only(top: 10.0, bottom: 15.0),
                    child: Column(
                        children: contentType.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: InkWell(
                          onTap: () {
                            if (conType != entry.value) {
                              urlC.text = "";
                              conType = entry.value;
                              conTypeId = entry.key;
                            }
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: conType != ""
                                    ? conType == entry.value
                                        ? colors.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .lightColor
                                    : Theme.of(context).colorScheme.lightColor),
                            padding: const EdgeInsets.all(10.0),
                            alignment: Alignment.center,
                            child: Text(entry.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor)),
                          ),
                        ),
                      );
                      ;
                    }).toList())),
              ],
            )));
  }

  Widget newsTitleName() {
    return Container(
        width: deviceWidth!,
        margin: EdgeInsetsDirectional.only(top: 7),
        /*  padding: EdgeInsetsDirectional.only(
            top: 7.0, bottom: 7.0, start: 10, end: 10), */
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Theme.of(context).colorScheme.boxColor),
        child: TextFormField(
          textInputAction: TextInputAction.next,
          maxLines: 1,
          controller: titleC,
          style: Theme.of(this.context)
              .textTheme
              .subtitle1
              ?.copyWith(color: Theme.of(context).colorScheme.darkColor),
          validator: (val) => titleValidation(val!, context),
          onChanged: (String value) {
            setState(() {
              title = value;
            });
          },
          decoration: InputDecoration(
            hintText: getTranslated(context, 'TITLE_LBL')!,
            hintStyle: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                color:
                    Theme.of(context).colorScheme.darkColor.withOpacity(0.6)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.boxColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 17),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ));
  }

  Widget tagSelectionName() {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: InkWell(
        onTap: () {
          tagListBottomSheet();
        },
        child: Container(
          width: deviceWidth!,
          height: 55,
          alignment: Alignment.centerLeft,
          //margin: EdgeInsetsDirectional.only(top: 7),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 7),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.boxColor),
          child: tagsId.isEmpty
              ? Text(
                  getTranslated(context, 'TAG_LBL')!,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .darkColor
                            .withOpacity(0.6),
                      ),
                )
              : Container(
                  height: deviceHeight! * 0.05,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: tagsName.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsetsDirectional.only(
                            start: index != 0 ? 10.0 : 0),
                        child: Container(
                          margin: EdgeInsets.only(left: 0.0, right: 0.0),
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsetsDirectional.only(
                                    end: 7.5, top: 7.5),
                                padding: EdgeInsetsDirectional.all(7.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .darkColor),
                                alignment: Alignment.center,
                                child: Text(
                                  tagsName[index],
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .boxColor,
                                      ),
                                ),
                              ),
                              Positioned.directional(
                                  textDirection: Directionality.of(context),
                                  end: 0,
                                  child: Container(
                                      height: 15,
                                      width: 15,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.all(3.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background),
                                      child: InkWell(
                                        // backgroundColor:
                                        //     Theme.of(context).colorScheme.boxColor,
                                        child: Icon(
                                          Icons.close,
                                          size: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .boxColor,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            tagsName.remove(tagsName[index]);
                                            tagsId.remove(tagsId[index]);
                                          });
                                        },
                                      )))
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget showTilledSelDate() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: InkWell(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(Duration(days: 0)),
              //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2100));

          if (pickedDate != null) {
            print(
                pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

            setState(() {
              showTill = formattedDate; //set output date to TextField value.
            });
          } else {}
        },
        child: Container(
          width: deviceWidth!,
          // height: 55,
          margin: EdgeInsetsDirectional.only(top: 7),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 17),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).colorScheme.boxColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                showTill == null
                    ? getTranslated(context, 'SHOW_TILLED_DATE')!
                    : showTill!,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: showTill == null
                          ? Theme.of(context)
                              .colorScheme
                              .darkColor
                              .withOpacity(0.6)
                          : Theme.of(context).colorScheme.darkColor,
                    ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.calendar_month_outlined,
                    color: Theme.of(context).colorScheme.darkColor),
              )
            ],
          ),
        ),
      ),
    );
  }

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
    }
  }

  // set image gallery
  _getFromGalleryOther() async {
    List<XFile>? pickedFileList = await ImagePicker().pickMultiImage(
      maxWidth: 1800,
      maxHeight: 1800,
    );
    otherImage.clear();
    for (int i = 0; i < pickedFileList.length; i++) {
      otherImage.add(File(pickedFileList[i].path));
    }

    setState(() {});
  }

  // set image gallery
  _getFromGalleryVideo() async {
    final XFile? file = await ImagePicker().pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(seconds: 10));
    if (file != null) {
      setState(() {
        videoUpload = File(file.path);
      });
    }
  }

  Widget uploadMainImage() {
    return InkWell(
      onTap: () {
        _showPicker();
      },
      child: image == null
          ? Container(
              height: 125,
              width: deviceWidth!,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.only(top: 25),
              child: DashedRect(
                color: Theme.of(context).colorScheme.darkColor,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                    Icons.image,
                    color: Theme.of(context)
                        .colorScheme
                        .darkColor
                        .withOpacity(0.7),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10),
                    child: Text(
                      getTranslated(context, 'UPLOAD_MAIN_IMAGE_LBL')!,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .darkColor
                              .withOpacity(0.5)),
                    ),
                  )
                ]),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 25),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  image!,
                  height: 125,
                  width: deviceWidth,
                  fit: BoxFit.fill,
                ),
              ),
            ),
    );
  }

  Widget uploadOtherImage() {
    return otherImage.isEmpty
        ? InkWell(
            onTap: () {
              _getFromGalleryOther();
            },
            child: Container(
              height: 125,
              width: deviceWidth!,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.only(top: 25),
              child: DashedRect(
                color: Theme.of(context).colorScheme.darkColor,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                    Icons.image,
                    color: Theme.of(context)
                        .colorScheme
                        .darkColor
                        .withOpacity(0.7),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10),
                    child: Text(
                      getTranslated(context, 'UPLOAD_OTHER_IMAGE_LBL')!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .darkColor
                              .withOpacity(0.5)),
                    ),
                  )
                ]),
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.only(top: 25),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFromGalleryOther();
                  },
                  child: Container(
                    height: 125,
                    width: 95,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: DashedRect(
                      color: Theme.of(context).colorScheme.darkColor,
                      child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image,
                                size: 15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .darkColor
                                    .withOpacity(0.7),
                              ),
                              Text(
                                getTranslated(
                                    context, 'UPLOAD_OTHER_IMAGE_LBL')!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .darkColor
                                            .withOpacity(0.5)),
                              )
                            ]),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                      height: 125,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: otherImage.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsetsDirectional.only(start: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                otherImage[index],
                                height: 125,
                                width: 95,
                                fit: BoxFit.fill,
                              ),
                            ),
                          );
                        },
                      )),
                )
              ],
            ),
          );
  }

  Widget nextBtn() {
    return Padding(
      padding: EdgeInsetsDirectional.all(20),
      child: InkWell(
        splashColor: Colors.transparent,
        child: Container(
          height: 55.0,
          //48.0,
          width: deviceWidth! * 0.9,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.darkColor,
              borderRadius: BorderRadius.circular(7.0)),
          child: Text(
            getTranslated(context, 'nxt')!, //login_btn
            style: Theme.of(this.context).textTheme.headline6?.copyWith(
                color: Theme.of(context).colorScheme.lightColor,
                fontWeight: FontWeight.w600,
                fontSize: 21,
                letterSpacing: 0.6),
          ),
        ),
        onTap: () async {
          print("isNext****$isNext");
          final form = _formkey.currentState;
          form!.save();
          if (form.validate()) {
            if (catSelId == null) {
              showSnackBar(getTranslated(context, 'PLZ_SEL_CAT_LBL')!, context);
            } else if (conType == getTranslated(context, 'VIDEO_UPLOAD_LBL')!) {
              if (videoUpload == null) {
                showSnackBar(
                    getTranslated(context, 'PLZ_UPLOAD_VIDEO_LBL')!, context);
              }
            } else if (image == null) {
              showSnackBar(
                  getTranslated(context, 'PLZ_ADD_MAIN_IMAGE_LBL')!, context);
            } else {
              setState(() {
                isNext = true;
              });
            }
          }

          // testFunc(false,description: desc);
        },
      ),
    );
  }

  validateFunc(String description) {
    desc = description;

    validateForm();
  }

  tagListBottomSheet() {
    showModalBottomSheet<dynamic>(
        context: context,
        elevation: 3.0,
        isScrollControlled: true,
        // isDismissible: false,
        //it will be closed only when user click On Save button & not by clicking anywhere else in screen
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        enableDrag: false,
        // useRootNavigator: ,
        builder: (BuildContext context) => Container(
            padding: EdgeInsetsDirectional.only(
                bottom: 15.0, top: 15.0, start: 20.0, end: 20.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: Theme.of(context).colorScheme.boxColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(context, 'SEL_TAG_LBL')!,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.darkColor,
                      ),
                ),
                Padding(
                    padding:
                        EdgeInsetsDirectional.only(top: 10.0, bottom: 15.0),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: tagList.length,
                      itemBuilder: (context, index) {
                        return tagListItem(index);
                      },
                    )),
              ],
            )));
  }

  subCatListBottomSheet() {
    showModalBottomSheet<dynamic>(
        context: context,
        elevation: 3.0,
        isScrollControlled: true,
        // isDismissible: false,
        //it will be closed only when user click On Save button & not by clicking anywhere else in screen
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        enableDrag: false,
        // useRootNavigator: ,
        builder: (BuildContext context) => Container(
            padding: EdgeInsetsDirectional.only(
                bottom: 15.0, top: 15.0, start: 20.0, end: 20.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: Theme.of(context).colorScheme.boxColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(context, 'SEL_SUB_CAT_LBL')!,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.darkColor,
                      ),
                ),
                Padding(
                    padding:
                        EdgeInsetsDirectional.only(top: 10.0, bottom: 15.0),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: catList[catIndex!].subData!.length,
                      itemBuilder: (context, index) {
                        return subCatListItem(index);
                      },
                    )),
              ],
            )));
  }

  catListBottomSheet() {
    showModalBottomSheet<dynamic>(
        context: context,
        elevation: 3.0,
        isScrollControlled: true,
        // isDismissible: false,
        //it will be closed only when user click On Save button & not by clicking anywhere else in screen
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        enableDrag: false,
        // useRootNavigator: ,
        builder: (BuildContext context) => Container(
            padding: EdgeInsetsDirectional.only(
                bottom: 15.0, top: 15.0, start: 20.0, end: 20.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                color: Theme.of(context).colorScheme.boxColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getTranslated(context, 'SEL_CAT_LBL')!,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.darkColor,
                      ),
                ),
                Padding(
                    padding:
                        EdgeInsetsDirectional.only(top: 10.0, bottom: 15.0),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: catList.length,
                      itemBuilder: (context, index) {
                        return catListItem(index);
                      },
                    )),
              ],
            )));
  }

  Widget tagListItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: InkWell(
        onTap: () {
          if (!tagsId.contains(tagList[index].id!)) {
            setState(() {
              tagsName.add(tagList[index].tagName!);
              tagsId.add(tagList[index].id!);
            });
          } else {
            setState(() {
              tagsName.remove(tagList[index].tagName!);
              tagsId.remove(tagList[index].id!);
            });
          }
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: tagsId.isNotEmpty
                  ? tagsId.contains(tagList[index].id!)
                      ? colors.primary
                      : Theme.of(context).colorScheme.lightColor
                  : Theme.of(context).colorScheme.lightColor),
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: Text(tagList[index].tagName!,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor)),
        ),
      ),
    );
  }

  Widget subCatListItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: InkWell(
        onTap: () {
          setState(() {
            subCatSel = catList[catIndex!].subData![index].subCatName!;
            subSelId = catList[catIndex!].subData![index].id!;
          });
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: subCatSel != ""
                  ? subCatSel == catList[catIndex!].subData![index].subCatName!
                      ? colors.primary
                      : Theme.of(context).colorScheme.lightColor
                  : Theme.of(context).colorScheme.lightColor),
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: Text(catList[catIndex!].subData![index].subCatName!,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor)),
        ),
      ),
    );
  }

  Widget catListItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: InkWell(
        onTap: () {
          setState(() {
            subSelId = null;
            subCatSel = "";
            catSel = catList[index].categoryName!;
            catSelId = catList[index].id!;
            catIndex = index;
          });
          Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: catSel != ""
                  ? catSel == catList[index].categoryName!
                      ? colors.primary
                      : Theme.of(context).colorScheme.lightColor
                  : Theme.of(context).colorScheme.lightColor),
          padding: const EdgeInsets.all(10.0),
          alignment: Alignment.center,
          child: Text(catList[index].categoryName!,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    contentType = {
      "standard_post": getTranslated(context, 'STANDARD_POST_LBL')!,
      "video_youtube": getTranslated(context, 'VIDEO_YOUTUBE_LBL')!,
      "video_other": getTranslated(context, 'VIDEO_OTHER_URL_LBL')!,
      "video_upload": getTranslated(context, 'VIDEO_UPLOAD_LBL')!,
    };

    return Scaffold(
        /* resizeToAvoidBottomInset: false,
        extendBody: true,*/
        bottomNavigationBar: !isNext ? nextBtn() : null,
        key: _scaffoldKey,
        appBar: getAppBar(),
        body: Form(
            key: _formkey,
            child: Stack(children: [
              if (isLoading)
                Center(
                    child: CircularProgressIndicator(
                  color: colors.primary,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                )),
              !isNext
                  ? WillPopScope(
                      onWillPop: () {
                        if (!isNext) {
                          return Future.value(true);
                        } else {
                          setState(() {
                            isNext = false;
                          });

                          return Future.value(false);
                        }
                      },
                      child: SingleChildScrollView(
                          padding: const EdgeInsetsDirectional.only(
                              top: 20, start: 20, end: 20, bottom: 20),
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              newsTitleName(),
                              catSelectionName(),
                              subCatSelectionName(),
                              contentTypeSelName(),
                              contentVideoUpload(),
                              contentUrlSet(),
                              tagSelectionName(),
                              showTilledSelDate(),
                              uploadMainImage(),
                              uploadOtherImage(),
                            ],
                          )),
                    )
                  : NewsDescription(desc ?? "", updateParent, validateFunc, 1)
            ])));
  }

  updateParent(String description, bool next) {
    print("description****$description");
    setState(() {
      desc = description;
      isNext = next;
    });
  }

  Future<void> setNewsAdd() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(() {
          isLoading = true;
        });
        var request = MultipartRequest('POST', Uri.parse(setNewsApi));
        request.headers.addAll(headers);

        request.fields[USER_ID] = CUR_USERID;
        request.fields[ACCESS_KEY] = access_key;
        request.fields[CATEGORY_ID] = catSelId!;
        if (subSelId != null) {
          request.fields[SUBCAT_ID] = subSelId!;
        }

        request.fields[TITLE] = title!;
        request.fields[CONTENT_TYPE] = conTypeId;
        if (showTill != null) {
          request.fields[SHOW_TILL] = showTill!;
        }

        if (tagsId.isNotEmpty) {
          request.fields[TAG_ID] = tagsId.join(',');
        }

        if (conType == getTranslated(context, 'VIDEO_YOUTUBE_LBL')!) {
          request.fields["youtube_url"] = urlC.text;
        }
        if (conType == getTranslated(context, 'VIDEO_OTHER_URL_LBL')!) {
          if (urlC.text.isNotEmpty) {
            request.fields[OTHER_URL] = urlC.text;
          }
        } else if (conType == getTranslated(context, 'VIDEO_UPLOAD_LBL')!) {
          if (videoUpload != null) {
            var videoPath =
                await MultipartFile.fromPath("video_file", videoUpload!.path);
            request.files.add(videoPath);
          }
        }

        if (desc != null) {
          request.fields[DESCRIPTION] = desc!;
        }

        if (otherImage.isNotEmpty) {
          for (var i = 0; i < otherImage.length; i++) {
            var image =
                await MultipartFile.fromPath("ofile[$i]", otherImage[i].path);
            request.files.add(image);
          }
        }

        var pic = await MultipartFile.fromPath(IMAGE, image!.path);
        request.files.add(pic);

        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);

        print("request file${request.fields}*****${request.files}");
        print("request statuscode${response.statusCode}");
        if (response.statusCode == 200) {
          var getdata = json.decode(responseString);

          print("getdata*****$getdata");

          String error = getdata["error"];
          String msg = getdata['message'];

          if (error == "false") {
            showSnackBar(msg, context);

            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (BuildContext context) => ShowNews()))
                .then((value) {
              clearText();
            });
            //clearText();
          } else {
            showSnackBar(msg, context);
          }
          setState(() {
            isLoading = false;
          });
        } else {
          return null;
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  /* bool validateAndSave() {
    final form = _formkey.currentState;
    form!.save();
    if (form.validate()) {
      if (catSelId == null) {
        showSnackBar(getTranslated(context, 'PLZ_SEL_CAT_LBL')!, context);
      } else if (conType == getTranslated(context, 'VIDEO_UPLOAD_LBL')!) {
        if (videoUpload == null) {
          showSnackBar(
              getTranslated(context, 'PLZ_UPLOAD_VIDEO_LBL')!, context);
        }
      } else if (image == null) {
        showSnackBar(getTranslated(context, 'PLZ_ADD_MAIN_IMAGE_LBL')!, context);
      } else {
        return true;
      }
    }
    return false;
  }*/

  validateForm() async {
    //  if (validateAndSave()) {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setNewsAdd();
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }
//}
}
