import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:news/EditNews.dart';
import 'package:news/Helper/Color.dart';
import 'package:shimmer/shimmer.dart';

import 'AddNews.dart';
import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'Model/News.dart';
import 'NewsDetails.dart';
import 'NewsTag.dart';

class ShowNews extends StatefulWidget {
  @override
  ShowNewsState createState() => ShowNewsState();
}

class ShowNewsState extends State<ShowNews> {
  bool _isNetworkAvail = true;
  bool _isButtonExtended = true;
  bool isLoading = true;
  bool isCenterLoading = false;
  List<News> newsList = [];
  int offset = 0;
  int total = 0;
  bool isLoadingMore = true;
  ScrollController controller = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    controller.addListener(_scrollListener);
    getNews();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    // controller.disable();

    super.dispose();
  }

  Future<void> getNews() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        ACCESS_KEY: access_key,
        OFFSET: offset.toString(),
        LIMIT: perPage.toString(),
        USER_NEWS: CUR_USERID,
        USER_ID: CUR_USERID
      };
      print("param*****$param");
      Response response =
          await post(Uri.parse(getNewsApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print("getdata*****$getdata");
      String error = getdata["error"];
      // String msg = getdata["message"];
      if (error == "false") {
        var data = getdata["data"];

        total = int.parse(getdata["total"]);

        if (offset < total) {
          List<News> temp =
              (data as List).map((data) => News.fromJson(data)).toList();

          offset = offset + perPage;

          newsList.addAll(temp);
        }
      } else {
        isLoadingMore = false;
        // showSnackBar(msg, context);
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(getTranslated(context, 'internetmsg')!, context)!;
      }
    }

    return;
  }

  //set appbar
  getAppBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 45),
        child: AppBar(
          centerTitle: false,
          //true,
          backgroundColor: Colors.transparent,
          title: Transform(
            transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
            child: Text(
              getTranslated(context, 'news_lbl')!,
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
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.darkColor),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),
        ));
  }

  floatingBtn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          isExtended: _isButtonExtended,
          backgroundColor: Theme.of(context).colorScheme.boxColor,
          child: Icon(
            Icons.add,
            size: 32,
            color: Theme.of(context).colorScheme.darkColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<String>(
                builder: (context) => AddNews(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget newsItem(int index) {
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

    String contType = "";
    if (newsList[index].contentType == "standard_post") {
      contType = getTranslated(context, 'STANDARD_POST_LBL')!;
    } else if (newsList[index].contentType == "video_youtube") {
      contType = getTranslated(context, 'VIDEO_YOUTUBE_LBL')!;
    } else if (newsList[index].contentType == "video_other") {
      contType = getTranslated(context, 'VIDEO_OTHER_URL_LBL')!;
    } else if (newsList[index].contentType == "video_upload") {
      contType = getTranslated(context, 'VIDEO_UPLOAD_LBL')!;
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => NewsDetails(
                  model: newsList[index],
                  index: index,
                  //int.parse(id),
                  id: newsList[index].id,
                  // isFav: false,
                  isDetails: true,
                  news: [],
                )));
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Theme.of(context).colorScheme.boxColor),
        padding: EdgeInsetsDirectional.all(15),
        margin: EdgeInsets.only(top: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: deviceWidth! * 0.24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      fadeInDuration: Duration(milliseconds: 150),
                      imageUrl: newsList[index].image!,
                      height: deviceWidth! * 0.23,
                      width: deviceWidth! * 0.23,
                      fit: BoxFit.fill,
                      errorWidget: (context, error, stackTrace) =>
                          errorWidget(deviceWidth! * 0.23, deviceWidth! * 0.23),
                      placeholder: (context, url) {
                        return placeHolder();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(newsList[index].categoryName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .darkColor
                                  .withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                            )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(convertToAgo(context, time1, 0)!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .darkColor
                                .withOpacity(0.8))),
                  )
                ],
              ),
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsetsDirectional.only(start: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(newsList[index].title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          color: Theme.of(context).colorScheme.darkColor)),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (newsList[index].subCatName != "")
                                  Padding(
                                    padding: EdgeInsets.only(top: 7),
                                    child: Text(
                                        getTranslated(context, 'SUBCAT_LBL')!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .darkColor
                                                    .withOpacity(0.8))),
                                  ),
                                if (newsList[index].contentType != "")
                                  Padding(
                                    padding: EdgeInsets.only(top: 7),
                                    child: Text(
                                        getTranslated(
                                            context, 'CONTENT_TYPE_LBL')!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .darkColor
                                                    .withOpacity(0.8))),
                                  ),
                              ]),
                        ),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (newsList[index].subCatName != "")
                                  Padding(
                                    padding: EdgeInsets.only(top: 7),
                                    child: Text(newsList[index].subCatName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .darkColor
                                                    .withOpacity(0.8))),
                                  ),
                                if (newsList[index].contentType != "")
                                  Padding(
                                    padding: EdgeInsets.only(top: 7),
                                    child: Text(contType,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .darkColor
                                                    .withOpacity(0.8))),
                                  ),
                              ]),
                        )
                      ]),

                    newsList[index].tagName! != ""
                        ? Container(
                            margin: EdgeInsets.only(top: 7),
                            height: 18.0,
                            child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount:
                                    tagList.length >= 2 ? 2 : tagList.length,
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
                                            padding: EdgeInsetsDirectional.only(
                                                start: 3.0, end: 3.0),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .lightColor),
                                            child: Text(
                                              tagList[index],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .darkColor,
                                                    fontSize: 9.5,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            )),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => NewsTag(
                                                  tagId: tagId[index],
                                                  tagName: tagList[index],
                                                ),
                                              ));
                                        },
                                      ));
                                }))
                        : SizedBox.shrink(),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            width: deviceWidth! * 0.20,
                            height: 25,
                            padding:
                                EdgeInsetsDirectional.only(top: 3, bottom: 3),
                            decoration: new BoxDecoration(
                                color: Theme.of(context).colorScheme.darkColor,
                                borderRadius: BorderRadius.circular(3)),
                            child: Text(getTranslated(context, 'EDIT_LBL')!,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightColor,
                                        fontWeight: FontWeight.w600)),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => EditNews(
                                      model: newsList[index], // widget.model,
                                    )));
                          },
                        ),
                        InkWell(
                          child: Container(
                            width: deviceWidth! * 0.20,
                            height: 25,
                            padding:
                                EdgeInsetsDirectional.only(top: 3, bottom: 3),
                            alignment: Alignment.center,
                            decoration: new BoxDecoration(
                                color: Theme.of(context).colorScheme.darkColor,
                                borderRadius: BorderRadius.circular(3)),
                            child: Text(getTranslated(context, 'delete_txt')!,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightColor,
                                        fontWeight: FontWeight.w600)),
                          ),
                          onTap: () {
                            deleteNewsDialogue(newsList[index].id!, index);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  //set Delete dialogue
  deleteNewsDialogue(String id, int index) async {
    // print("current User - ${_auth.currentUser} -- local prefs - ${user}");
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.boxColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Text(
                getTranslated(context, 'DO_YOU_REALLY_DEL_NEWS_LBL')!,
                style: Theme.of(this.context).textTheme.subtitle1?.copyWith(
                    color:
                        Theme.of(context).colorScheme.fontColor), //fontColor),
              ),
              title: Text(getTranslated(context, 'DEL_NEWS_LBL')!),

              titleTextStyle: Theme.of(this.context)
                  .textTheme
                  .headline6
                  ?.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.w600),
              //fontColor),
              actions: <Widget>[
                new TextButton(
                    child: Text(
                      getTranslated(context, 'NO')!,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .fontColor, //fontColor,
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .fontColor, //fontColor,
                              fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop(false);
                      deleteNews(id, index);
                    })
              ],
            );
          });
        });
  }

  Future<void> deleteNews(String id, int index) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (!isCenterLoading)
        setState(() {
          isCenterLoading = true;
        });

      var param = {ACCESS_KEY: access_key, ID: id};
      print("Param value - $param");

      Response response =
          await post(Uri.parse(setDeleteNewsApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));
      var getdata = json.decode(response.body);

      String error = getdata["error"];
      if (error == "false") {
        print("response from APi - $getdata");
        showSnackBar(getdata["message"], context);
        newsList.removeAt(index);
      } else {
        //show error message
        showSnackBar(getdata["message"], context);
      }
      if (isCenterLoading)
        setState(() {
          isCenterLoading = false;
        });
    } else {
      setState(() {
        isCenterLoading = false;
      });
      showSnackBar(getTranslated(context, 'internetmsg')!, context)!;
    }
  }

  _scrollListener() {
    setState(() {
      _isButtonExtended =
          controller.position.userScrollDirection == ScrollDirection.forward;
    });
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(() {
            isLoadingMore = true;
            if (offset < total) getNews();
          });
        }
      }
    }
  }

  //refresh function to refresh page
  Future _refresh() async {
    setState(() {
      isLoading = true;
      offset = 0;
      total = 0;
      newsList.clear();
    });
    return getNews();
  }

  contentShimmer(BuildContext context) {
    //bookmarks
    return Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: Colors.grey,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.only(start: 20, end: 20),
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey.withOpacity(0.6)),
            margin: EdgeInsets.only(top: 20),
            height: 170.0,
          ),
          itemCount: 6,
        ));
  }

  singleContentShimmer(BuildContext context) {
    //bookmarks
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: Colors.grey,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.grey.withOpacity(0.6)),
        margin: EdgeInsets.only(top: 20),
        height: 170.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(),
        floatingActionButton: floatingBtn(),
        body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refresh,
            child: Stack(children: [
              if (isCenterLoading)
                Center(
                    child: CircularProgressIndicator(
                  color: colors.primary,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                )),
              isLoading
                  ? contentShimmer(context)
                  : newsList.isNotEmpty
                      ? ListView.builder(
                          controller: controller,
                          padding:
                              EdgeInsetsDirectional.only(start: 20, end: 20),
                          itemCount: (offset < total)
                              ? newsList.length + 1
                              : newsList.length,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return (index == newsList.length && isLoadingMore)
                                ? singleContentShimmer(context)
                                : newsItem(index);
                          },
                        )
                      : Center(child: Text(getTranslated(context, 'no_news')!)),
            ])));
  }
}
