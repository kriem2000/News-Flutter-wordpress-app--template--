import 'dart:async';
import 'dart:convert';
// import 'dart:ui';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Widgets.dart';
import 'package:news/Model/Category.dart';
import 'package:news/Model/News.dart';
// import 'package:news/NewsDetails.dart';
// import 'package:news/NewsTag.dart';

import 'package:news/SubHome.dart';
import 'package:shimmer/shimmer.dart';

import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:http/http.dart' as http;

class SubCategories extends StatefulWidget {
  final String? catId;
  final String? catName;

  final List<Category>? catList;
  final String? curTabId;
  final bool? isSubCat;
  final int? index;
  final String? subCatId;

  SubCategories({
    this.catId,
    this.catName,
    this.catList,
    this.curTabId,
    this.isSubCat,
    this.index,
    this.subCatId,
  });

  @override
  SubCategoriesState createState() => SubCategoriesState();
}

class SubCategoriesState extends State<SubCategories>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  bool isNetworkAvail = true;
  bool isLoadingMore = true;
  List<SubCategory> subcatData = [];
  List<Category> tempCatList = [];
  List<SubCategory> tempsubCatList = [];
  List<News> tempList = [];
  int offset = 0;
  int total = 0;

  List<News> bookmarkList = [];
  List bookMarkValue = [];

  List<Category> catList = [];
  List<News> newsList = [];
  int tcIndex = 0;
  int? selectSubCat = 0;

  // ScrollController _controller = new ScrollController();
  // bool enabled = true;
  bool isBookmark = false;
  bool isSubCatAvailable = true;
  var scrollController = ScrollController();
  String? subId = "0";

  @override
  void initState() {
    super.initState();
    getCat();
    getSubcategories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("issubcat - $isSubCatAvailable");
    return Scaffold(
      key: _scaffoldKey,
      appBar: titleSubCatTxt(),
      body: Stack(
        children: <Widget>[
          subcatData.length != 0 ? subTabData() : catShimmer(),
          Padding(
            padding: EdgeInsets.only(top: (isSubCatAvailable) ? 40.0 : 0.0),
            child: catList.length != 0
                ? SubHome(
                    curTabId: widget.curTabId,
                    isSubCat: false,
                    scrollController: scrollController,
                    catList: catList,
                    subCatId: subId,
                    index: 0,
                    newsList: this.newsList,
                  )
                : contentWithBottomTextShimmer(context),
            //  showCircularProgress(isLoading, colors.primary)
          ),
        ],
      ),
    );
  }

  catShimmer() {
    print("isSubCat Avail -  $isSubCatAvailable");
    return (isSubCatAvailable)
        ? Container(
            child: Shimmer.fromColors(
                baseColor: Colors.grey.withOpacity(0.4),
                highlightColor: Colors.grey.withOpacity(0.4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: [0, 1, 2, 3, 4, 5, 6]
                          .map((i) => Padding(
                              padding:
                                  EdgeInsetsDirectional.only(start: 15, top: 0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Color.fromARGB(255, 59, 49, 49)),
                                height: 32.0,
                                width: 70.0,
                              )))
                          .toList()),
                )))
        : SizedBox.shrink();
  }

  titleSubCatTxt() {
    return AppBar(
      // leadingWidth: 35, //25,
      /* elevation: 0.0,
      systemOverlayStyle:
          !isDark! ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light, */
      backgroundColor: Colors.transparent,
      leading: setBackButton(context, Theme.of(context).colorScheme.darkColor),
      //padding: EdgeInsets.only(left: 10.0),
      title: Transform(
        transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
        child: Text(widget.catName!,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: Theme.of(context).colorScheme.darkColor,
                  fontWeight: FontWeight.bold,
                )),
      ),
    );
  }

  //get all category using api
  Future<void> getCat() async {
    if (category_mode == "1") {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          var param = {
            ACCESS_KEY: access_key,
          };
          http.Response response = await http
              .post(Uri.parse(getCatApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));
          var getData = json.decode(response.body);

          String error = getData["error"];
          if (error == "false") {
            tempCatList.clear();
            var data = getData["data"];
            tempCatList = (data as List)
                .map((data) => new Category.fromJson(data))
                .toList();
            catList.addAll(tempCatList);
          }
          if (mounted)
            setState(() {
              isLoading = false;
            });
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          setState(() {
            isLoading = false;
            isLoadingMore = false;
          });
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'disabled_category')!, context);
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> getSubcategories() async {
    if (category_mode == "1") {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          var param = {
            ACCESS_KEY: access_key,
            CATEGORY_ID: widget.catId,
          };
          print("params - $param");
          http.Response response = await http
              .post(Uri.parse(getSubCategoryApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));
          var getData = json.decode(response.body);
          print("Response - ${getData}");
          String error = getData["error"];
          print("isError false or True - $error & response is ${getData}");
          if (error == "false") {
            tempsubCatList.clear();
            var data = getData["data"];
            tempsubCatList = (data as List)
                .map((data) => new SubCategory.fromJson(data))
                .toList();
            print(
                " response -   ${tempsubCatList} & length is ${tempsubCatList.length}");

            if (tempsubCatList.length != 0) {
              tempsubCatList.insert(
                  0,
                  SubCategory(
                      id: "0",
                      subCatName: "${getTranslated(context, 'all_lbl')!}"));
            }
            subcatData.addAll(tempsubCatList);
            print("Length of subcategory Data - ${subcatData.length}");
          } else {
            if (subcatData.length == 0) {
              setState(() {
                isSubCatAvailable = false;
              });
            } else {
              setState(() {
                isSubCatAvailable = true;
              });
            }
          }
          if (mounted)
            setState(() {
              isLoading = false;
            });
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          setState(() {
            isLoading = false;
            isLoadingMore = false;
          });
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'disabled_category')!, context);
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  subTabData() {
    return subCategory_mode == "1"
        ? catList.length != 0 && !isLoading
            ? subcatData.length != 0 && !isLoading
                ? Container(
                    height: 32,
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsetsDirectional.only(start: 16),
                    child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: (subcatData.length),
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: EdgeInsetsDirectional.only(
                                  start: index == 0 ? 0 : 10),
                              child: InkWell(
                                child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsetsDirectional.only(
                                        start: 7.0,
                                        end: 7.0,
                                        top: 2.5,
                                        bottom: 2.5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: (selectSubCat == index)
                                          ? Theme.of(context)
                                              .colorScheme
                                              .tabColor
                                          : Colors.transparent,
                                    ),
                                    child: Text(
                                      subcatData[index].subCatName!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2
                                          ?.copyWith(
                                              color: selectSubCat == index
                                                  ? colors.bgColor
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .skipColor,
                                              fontSize: 12,
                                              fontWeight: selectSubCat == index
                                                  ? FontWeight.w600
                                                  : FontWeight.normal),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                    )),
                                onTap: () async {
                                  this.setState(() {
                                    selectSubCat = index;
                                    subId = subcatData[index].id;
                                  });
                                },
                              ));
                        }))
                : SizedBox.shrink()
            //if Subcategory Length of Respected Category is 0
            : Container(
                height: 32,
                margin: EdgeInsetsDirectional.only(start: 16),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(getTranslated(context,
                        'cat_no_avail')!))) //if Category List is having 0 length
        : Container(
            height: 32,
            margin: EdgeInsetsDirectional.only(start: 16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(getTranslated(context,
                    'disabled_subcat')!))); //if SubCategory Mode is Disabled
  }

  /*  getDetails() {
    return ListView.builder(
        controller: _controller,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          DateTime time1 = DateTime.parse(newsList[index].date!);
          List<String> tagList = [];
          if (newsList[index].tagName! != "") {
            final tagName = newsList[index].tagName!;
            tagList = tagName.split(',');
          }

          List<String> tagId = [];

          if (newsList[index].tagId! != "") {
            tagId = newsList[index].tagId!.split(",");
          }

          return (index == newsList.length && isLoadingMore)
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsetsDirectional.only(top: 15.0),
                  child: AbsorbPointer(
                    absorbing: !enabled,
                    child: InkWell(
                      child: Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage.assetNetwork(
                                //image
                                image: newsList[index].image!,
                                height: 320.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: placeHolder,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return errorWidget(320, double.infinity);
                                },
                              )),
                          Positioned.directional(
                              textDirection: Directionality.of(context),
                              bottom: 0,
                              start: 0,
                              end: 0,
                              height: 123,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          colors.darkColor1.withOpacity(0.01),
                                          colors.darkColor1.withOpacity(0.75)
                                        ]).createShader(bounds);
                                  },
                                  blendMode: BlendMode.darken,
                                  child: Container(
                                    height: 60,
                                    width: double.infinity,
                                    color: Colors.transparent,
                                    padding: EdgeInsets.only(top: 30),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            convertToAgo(time1, 0)!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption
                                                ?.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 13.0,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  newsList[index].title!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1
                                                      ?.copyWith(
                                                          color: colors
                                                              .bgColor,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600,
                                                          fontSize: 15,
                                                          height: 1.0,
                                                          letterSpacing:
                                                              0.5),
                                                  maxLines: 3,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                          ),
                                          Padding(
                                              //tags
                                              padding:
                                                  EdgeInsets.only(top: 8.0),
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: <Widget>[
                                                  newsList[index]
                                                              .tagName! !=
                                                          ""
                                                      ? SizedBox(
                                                          height: 23.0,
                                                          child: ListView
                                                              .builder(
                                                                  physics:
                                                                      ClampingScrollPhysics(),
                                                                  scrollDirection:
                                                                      Axis
                                                                          .horizontal,
                                                                  shrinkWrap:
                                                                      true,
                                                                  controller:
                                                                      _controller,
                                                                  itemCount: tagList.length >=
                                                                          3
                                                                      ? 3
                                                                      : tagList
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Padding(
                                                                        padding:
                                                                            EdgeInsetsDirectional.only(start: index == 0 ? 0 : 4),
                                                                        child: InkWell(
                                                                          child: ClipRRect(
                                                                              child: BackdropFilter(
                                                                                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                                                                  child: Container(
                                                                                      height: 23.0,
                                                                                      width: 75,
                                                                                      alignment: Alignment.center,
                                                                                      padding: EdgeInsetsDirectional.fromSTEB(3.0, 2.5, 3.0, 2.5),
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(3.0),
                                                                                        color: colors.tempboxColor,
                                                                                      ),
                                                                                      child: Text(
                                                                                        tagList[index],
                                                                                        style: Theme.of(context).textTheme.bodyText2?.copyWith(
                                                                                              color: colors.primary,
                                                                                              fontSize: 12,
                                                                                            ),
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        softWrap: true,
                                                                                      )))),
                                                                          onTap: () {
                                                                            //tags
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => NewsTag(
                                                                                    tagId: tagId[index],
                                                                                    tagName: tagList[index],
                                                                                    updateParent: updateFav,
                                                                                  ),
                                                                                ));
                                                                          },
                                                                        ));
                                                                  }))
                                                      : SizedBox.shrink(),
                                                  Spacer(),
                                                ],
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      ),
                      onTap: () async {
                        setState(() {
                          enabled = false;
                        });
                        News model = newsList[index];
                        List<News> bookList = [];
                        bookList.addAll(newsList);
                        bookList.removeAt(index);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => NewsDetails(
                                  model: model,
                                  index: index,
                                  updateParent: updateFav,
                                  id: model.newsId,
                                  // isFav: true,
                                  isDetails: true,
                                  news: bookList,
                                )));
                        setState(() {
                          enabled = true;
                        });
                      },
                    ),
                  ));
        });
  }
 */
  /*  updateFav() {
    setState(() {
      offset = 0;
      total = 0;
      bookmarkList.clear();
      bookMarkValue.clear();
      _getBookmark();
    });
  } */
/*  //get latest news data list
  Future<void> getNewsBySubCatID() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var param = {
          ACCESS_KEY: access_key,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          USER_ID: CUR_USERID != "" ? CUR_USERID : "0",
        };

        if (subcatData.length != 0) {
          if (widget.subCatId == "0") {
            param[CATEGORY_ID] = widget.curTabId!;
          } else {
            param[SUBCAT_ID] = widget.subCatId!;
          }
        } else {
          param[CATEGORY_ID] = widget.curTabId!;
        }
        http.Response response = await http
            .post(Uri.parse(getNewsByCatApi), body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));
        if (response.statusCode == 200) {
          var getData = json.decode(response.body);
          String error = getData["error"];
          if (error == "false") {
            total = int.parse(getData["total"]);
            if ((offset) < total) {
              tempList.clear();
              var data = getData["data"];
              tempList = (data as List)
                  .map((data) => new News.fromJson(data))
                  .toList();
              newsList.addAll(tempList);

              offset = offset + perPage;
            }
          } else {
            if (this.mounted)
              setState(() {
                isLoadingMore = false;
                isLoading = false;
              });
          }
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }
 */
/*   //get bookmark api here
  _getBookmark() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      if (CUR_USERID != "") {
        try {
          var param = {
            ACCESS_KEY: access_key,
            USER_ID: CUR_USERID,
            LIMIT: perPage.toString(),
            OFFSET: offset.toString(),
          };
          http.Response response = await http
              .post(Uri.parse(getBookmarkApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          String error = getdata["error"];
          if (error == "false") {
            total = int.parse(getdata["total"]);

            if ((offset) < total) {
              var data = getdata["data"];
              print("bookmark data -- $data");
              tempList.clear();
              tempList = (data as List)
                  .map((data) => new News.fromJson(data))
                  .toList();
              if (offset == 0) bookmarkList.clear();
              bookmarkList.addAll(tempList);
              bookMarkValue.clear();
              for (int i = 0; i < bookmarkList.length; i++) {
                bookMarkValue.add(bookmarkList[i].newsId);
              }
              offset = offset + perPage;
            }

            if (this.mounted)
              setState(() {
                isLoading = false;
              });
          } else {
            setState(() {
              isLoadingMore = false;
              isLoading = false;
            });
          }
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        }
      } else {
        setState(() {
          isLoadingMore = false;
          isLoading = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }
 */
}
