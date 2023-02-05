// ignore_for_file: unnecessary_null_comparison, must_be_immutable

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Widgets.dart';

import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
// import 'Login.dart';
import 'Model/News.dart';
import 'NewsDetails.dart';

class NewsTag extends StatefulWidget {
  String? tagId; //final
  String? tagName; //final
  Function? updateParent; //final

  NewsTag({Key? key, this.tagId, this.tagName, this.updateParent})
      : super(key: key);

  @override
  NewsTagState createState() => NewsTagState();
}

class NewsTagState extends State<NewsTag> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isNetworkAvail = true;
  List<News> tagNewsList = [];
  bool _isLoading = true;
  List bookMarkValue = [];
  List<News> bookmarkList = [];
  bool isFirst = false;

  @override
  void initState() {
    super.initState();
    callApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: getAppBar(),
      body: viewContent(),
    );
  }

  callApi() async {
    getNewsByTag();
    await _getBookmark();
  }

  Future<void> getNewsByTag() async {
    tagNewsList.clear();
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var param = {
          ACCESS_KEY: access_key,
          TAG_ID: widget.tagId,
          USER_ID: CUR_USERID != null && CUR_USERID != "" ? CUR_USERID : "0"
        };

        Response response = await post(Uri.parse(getNewsByTagApi),
                body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        String error = getdata["error"];
        if (error == "false") {
          var data = getdata["data"];
          // print("Tags response - ${data}");
          tagNewsList =
              (data as List).map((data) => new News.fromJson(data)).toList();
          // print("length of tagsList - ${tagNewsList.length} - widget tagID - ${widget.tagId} - widget Tagname - ${widget.tagName} ");
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  newsItem(int index) {
    List<String> tagList = [];
    List<String> tagId = [];

    /* var tagSs = {
      tagNewsList[index].tagId!.split(","):
          tagNewsList[index].tagName!.split(",")
    };
    print(tagSs.toString());
    tagSs.forEach((key, value) {
      print(key);
      tagList = value;
      print(value);
      tagId = key;
      /*   var res = key.takeWhile((value) => key.contains(widget.tagId));
      print(res); */
    });

    tagList.sort(((a, b) {
      return widget.tagName!.toLowerCase().compareTo(b);
    })); */
    print(
        "values of TagNames-${tagList} & TagIds-${tagId} & widgetValues-${widget.tagName}--${widget.tagId}");

    DateTime time1 = DateTime.parse(tagNewsList[index].date!);

    if (tagNewsList[index].tagName! != "") {
      final tagName = tagNewsList[index].tagName!;
      tagList = tagName.split(',');
    }

    if (tagNewsList[index].tagId! != "") {
      tagId = tagNewsList[index].tagId!.split(",");
    }
    // print( "values of TagNames-${tagList} & TagIds-${tagId} & widgetValues-${widget.tagName}--${widget.tagId}");

    //test sorting after API Solution
    /* tagId.sort((a, b) => widget.tagId!.compareTo(b));
    print("sorted tagIds B- ${tagId}");
   

    tagId.sort((a, b) => b.compareTo(widget.tagId!));
    print("sorted tagIds B -WidgetId - ${tagId}");
    tagId.sort((a, b) => a.compareTo(widget.tagId!));
    print("sorted tagIds A-WidgetId - ${tagId}"); */

    /*  tagList.sort((a, b) => widget.tagName!.compareTo(b));
    print("sorted tagList B- ${tagList}"); */

    /*  tagId.sort((a, b) => widget.tagId!.compareTo(a));
    print("sorted tagIds A- ${tagId}");

    tagList.sort((a, b) => widget.tagName!.compareTo(a));
    print("sorted tagList A- ${tagList}"); */

    /* tagList.sort((a, b) => b.compareTo(widget.tagName!));
    print("sorted tagList B-WidgetId- ${tagList}");
    tagList.sort(
        (a, b) => a.toLowerCase().compareTo(widget.tagName!.toLowerCase()));
    print("sorted tagList A-WidgetId- ${tagList}");
 */
    return Padding(
        padding: EdgeInsetsDirectional.only(
            top: index == 0 ? 0 : deviceHeight! / 25.0),
        child: Column(children: <Widget>[
          InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: ContainerHeight, // deviceHeight! / 4.2,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            fadeInDuration: Duration(milliseconds: 150),
                            imageUrl:
                                tagNewsList[index].image!,
                            height: ContainerHeight, // deviceHeight! / 4.2,
                            width: deviceWidth,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) =>
                                errorWidget(deviceHeight! / 7.2, deviceWidth!),
                            placeholder: (context,url) {return placeHolder();},
                          )),
                      /*  Positioned.directional(
                        textDirection: Directionality.of(context),
                        bottom: 7.0,
                        start: 7.0,
                        end: 0.0,
                        top: 110.0,
                        child: */
                      if (tagNewsList[index].tagName! != "")
                        Container(
                          margin: EdgeInsets.only(
                              bottom: 5.0, left: 5.0, right: 5.0),
                          child: SizedBox(
                              height: 16,
                              child: ListView.builder(
                                  //physics: const AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  //shrinkWrap: true,
                                  // clipBehavior: Clip.none,
                                  itemCount:
                                      /* tagList.length >= 2 ? 2 :  */ tagList
                                          .length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: index == 0 ? 0 : 5.5),
                                        child: InkWell(
                                          child: Container(
                                              /* height: 16.0,
                                              width: 45, */
                                              height: 20.0,
                                              width: 65,
                                              alignment: Alignment.center,
                                              padding:
                                                  EdgeInsetsDirectional.only(
                                                start: 3.0,
                                                end: 3.0,
                                                top: 1.0, //2.5,
                                                bottom: 1.0,
                                              ), //2.5),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10.0),
                                                    topRight:
                                                        Radius.circular(10.0)),
                                                color: colors.tempboxColor
                                                    .withOpacity(0.85),
                                              ),
                                              child: Text(
                                                tagList[index],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2
                                                    ?.copyWith(
                                                      color:
                                                          colors.secondaryColor,
                                                      fontSize: 9.5,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                              )),
                                          onTap: () async {
                                            /* print("tagname - ${tagList[index]} & total tagId - ${tagNewsList[index].tagId} & current tagId - ${tagId[index]} & indexValue is ${index}"); */
                                            widget.tagId = tagId[index];
                                            widget.tagName = tagList[index];
                                            widget.updateParent =
                                                updateHomePage();
                                            setState(() {
                                              callApi();
                                              viewContent();
                                            });
                                            /* Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => NewsTag(
                                                   tagId: tagId[index],
                                                    tagName: tagList[index],
                                                    updateParent:
                                                        updateHomePage,
                                                  ),
                                                )); */
                                          },
                                        ));
                                  })),
                        )
                      // : SizedBox.shrink(),
                      // ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsetsDirectional.only(
                      top: 4.0, start: 5.0, end: 5.0),
                  child: Text(
                    tagNewsList[index].title!,
                    style: Theme.of(context).textTheme.subtitle2?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .fontColor
                            .withOpacity(0.9)),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                            top: 4.0, start: 5.0, end: 5.0),
                        child: Text(convertToAgo(context, time1, 0)!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .agoLabel
                                        .withOpacity(0.8))),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(start: 13.0),
                          child: InkWell(
                            child: Icon(Icons.share_rounded),
                            onTap: () async {
                              if (isRedundentClick(DateTime.now(), diff)) {
                                //inBetweenClicks
                                print('hold on, processing');
                                /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                                return;
                              }
                              _isNetworkAvail = await isNetworkAvailable();
                              if (_isNetworkAvail) {
                                createDynamicLink(
                                    context,
                                    tagNewsList[index].id!,
                                    index,
                                    tagNewsList[index].title!,
                                    false,
                                    false);
                              } else {
                                showSnackBar(
                                    getTranslated(context, 'internetmsg')!,
                                    context);
                              }
                              diff = resetDiff;
                            },
                          ),
                        ),
                        SizedBox(width: deviceWidth! / 99.0),
                        InkWell(
                          child: bookMarkValue.contains(tagNewsList[index].id)
                              ? Icon(Icons.bookmark_added_rounded)
                              : Icon(Icons.bookmark_add_outlined),
                          onTap: () async {
                            if (isRedundentClick(DateTime.now(), diff)) {
                              //inBetweenClicks
                              print('hold on, processing');
                              /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                              return;
                            }
                            _isNetworkAvail = await isNetworkAvailable();
                            if (CUR_USERID != "") {
                              if (_isNetworkAvail) {
                                setState(() {
                                  bookMarkValue.contains(tagNewsList[index].id!)
                                      ? _setBookmark(
                                          "0", tagNewsList[index].id!)
                                      : _setBookmark(
                                          "1", tagNewsList[index].id!);
                                });
                              } else {
                                showSnackBar(
                                    getTranslated(context, 'internetmsg')!,
                                    context);
                              }
                            } else {
                              loginRequired(context);
                              /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  )); */
                            }
                            diff = resetDiff;
                          },
                        ),
                        SizedBox(width: deviceWidth! / 99.0),
                        InkWell(
                          child: tagNewsList[index].like == "1"
                              ? Icon(Icons.thumb_up_alt)
                              : Icon(Icons.thumb_up_off_alt),
                          onTap: () async {
                            if (isRedundentClick(DateTime.now(), diff)) {
                              //inBetweenClicks
                              print('hold on, processing');
                              /* showSnackBar(
                              getTranslated(context, 'processing')!, context); */
                              return;
                            }
                            _isNetworkAvail = await isNetworkAvailable();
                            if (CUR_USERID != "") {
                              if (_isNetworkAvail) {
                                if (!isFirst) {
                                  setState(() {
                                    isFirst = true;
                                  });
                                  if (tagNewsList[index].like == "1") {
                                    await _setLikesDisLikes(
                                        "0", tagNewsList[index].id!, index);

                                    setState(() {});
                                  } else {
                                    await _setLikesDisLikes(
                                        "1", tagNewsList[index].id!, index);

                                    setState(() {});
                                  }
                                }
                              } else {
                                showSnackBar(
                                    getTranslated(context, 'internetmsg')!,
                                    context);
                              }
                            } else {
                              loginRequired(context);
                              /* Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  )); */
                            }
                            diff = resetDiff;
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              News model = tagNewsList[index];
              List<News> tgList = [];
              tgList.addAll(tagNewsList);
              tgList.removeAt(index);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => NewsDetails(
                        model: model,
                        index: index,
                        updateParent: updateHomePage,
                        id: model.id,
                        // isFav: false,
                        isDetails: true,
                        news: tgList,
                      )));
            },
          ),
        ]));
  }

  //set likes of news using api
  _setLikesDisLikes(String status, String id, int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        NEWS_ID: id,
        STATUS: status,
      };

      Response response = await post(Uri.parse(setLikesDislikesApi),
              body: param, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      String error = getdata["error"];

      String msg = getdata["message"];
      print(msg);

      if (error == "false") {
        if (status == "1") {
          tagNewsList[index].like = "1";
          tagNewsList[index].totalLikes =
              (int.parse(tagNewsList[index].totalLikes!) + 1).toString();
          // showSnackBar(getTranslated(context, 'like_succ')!, context);
        } else if (status == "0") {
          tagNewsList[index].like = "0";
          tagNewsList[index].totalLikes =
              (int.parse(tagNewsList[index].totalLikes!) - 1).toString();
          // showSnackBar(getTranslated(context, 'dislike_succ')!, context);
        }
        setState(() {
          isFirst = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  //get bookmark news list id using api
  Future<void> _getBookmark() async {
    if (CUR_USERID != "") {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var param = {
            ACCESS_KEY: access_key,
            USER_ID: CUR_USERID,
          };
          Response response = await post(Uri.parse(getBookmarkApi),
                  body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

          var getdata = json.decode(response.body);

          String error = getdata["error"];
          if (error == "false") {
            bookmarkList.clear();
            var data = getdata["data"];

            bookmarkList =
                (data as List).map((data) => new News.fromJson(data)).toList();
            bookMarkValue.clear();

            for (int i = 0; i < bookmarkList.length; i++) {
              bookMarkValue.add(bookmarkList[i].newsId);
            }
          }
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
      }
    }
  }

  updateHomePage() {
    setState(() {
      bookmarkList.clear();
      bookMarkValue.clear();
      _getBookmark();
    });
  }

//set bookmark of news using api
  _setBookmark(String status, String id) async {
    if (bookMarkValue.contains(id)) {
      setState(() {
        bookMarkValue = List.from(bookMarkValue)..remove(id);
      });
    } else {
      setState(() {
        bookMarkValue = List.from(bookMarkValue)..add(id);
      });
    }

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID,
        NEWS_ID: id,
        STATUS: status,
      };

      Response response =
          await post(Uri.parse(setBookmarkApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      String error = getdata["error"];

      String msg = getdata["message"];
      print(msg);

      if (error == "false") {
        if (status == "0") {
          // showSnackBar(msg, context);
          widget.updateParent!();
        } else {
          // showSnackBar(msg, context);
          widget.updateParent!();
        }
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  viewContent() {
    return Padding(
        padding: EdgeInsetsDirectional.zero,
        child: _isLoading
            ? contentWithBottomTextShimmer(context)
            : tagNewsList.length == 0
                ? Center(
                    child:
                        CircularProgressIndicator()) /* Padding(
                    padding: EdgeInsetsDirectional.only(
                        top: 0.0, bottom: 10.0, start: 13.0, end: 13.0),
                    child: Center(
                        child: Text(getTranslated(context, 'no_news')!,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .fontColor
                                        .withOpacity(0.8)))),
                  ) */
                : Padding(
                    padding: EdgeInsetsDirectional.only(
                        top: 10.0, bottom: 10.0, start: 13.0, end: 13.0),
                    child: ListView.builder(
                      itemCount: tagNewsList.length,
                      itemBuilder: (context, index) {
                        return newsItem(index);
                      },
                    )));
  }

  //set appbar
  getAppBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 45),
        child: AppBar(
            // systemOverlayStyle: !isDark!
            //     ? SystemUiOverlayStyle.dark
            //     : SystemUiOverlayStyle.light,
            // leadingWidth: 50,
            // elevation: 0.0,
            centerTitle: false, //true,
            backgroundColor: Colors.transparent,
            title: Transform(
              transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
              child: Text(
                widget.tagName!,
                style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Theme.of(context).colorScheme.darkColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
              ),
            ),
            leading: setBackButton(
                context,
                Theme.of(context)
                    .colorScheme
                    .darkColor) /* IconButton(
            icon: Icon(Icons.arrow_back,
                color: Theme.of(context).colorScheme.darkColor),
            onPressed: () => Navigator.of(context).pop(),
            splashColor: Colors.transparent,
          ), */
            ));
  }
}
