// ignore_for_file: must_be_immutable

// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/Helper/Constant.dart';
// import 'package:news/Helper/Widgets.dart';
import 'package:news/Model/BreakingNews.dart';

// import 'Helper/Constant.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
// import 'Login.dart';
import 'Model/News.dart';
import 'NewsDetails.dart';
// import 'NewsTag.dart';
import 'package:news/Helper/apiConnection.dart';

int total = 10; //used in apiConnection
List<News> newssList = []; //used in apiConnection

class ShowMoreNewsList extends StatefulWidget {
  final News? model;
  final int? index;
  Function? updateParent;
  final String? id;
  // final bool? isFav;
  final bool? isDetails;
  final List<News>? news;
  final BreakingNewsModel? model1;
  final List<BreakingNewsModel>? news1;
  final String? newsType;
  final bool? fromNewsDetails;

  ShowMoreNewsList({
    Key? key,
    this.model,
    this.index,
    this.updateParent,
    this.id,
    // this.isFav,
    this.isDetails,
    this.news,
    this.model1,
    this.news1,
    this.newsType,
    this.fromNewsDetails,
  }) : super(key: key);

  @override
  ShowMoreNewsListState createState() => ShowMoreNewsListState();
}

class ShowMoreNewsListState extends State<ShowMoreNewsList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // bool _isNetworkAvail = true;
  List<News> tempList = [];
  ScrollController _controller = new ScrollController();
  // bool enabled = true;

  List newsValue = [];
  List likeDisLikeValue = [];
  List<BreakingNewsModel> breakingNewssList = [];
  int offset = 0;
  bool _isLoadingmore = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    _isLoading = true;
    if (widget.newsType == getTranslated(context, 'breakingNews_lbl')) {
      breakingNewssList = widget.news1!;
    } else {
      newssList = widget.news!;
    }
    _isLoading = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onBackPress,
        child: Scaffold(
            key: _scaffoldKey,
            appBar: appBar(),
            body: Padding(
                padding: EdgeInsetsDirectional.only(
                    top: 0.0, bottom: 10.0, start: 13.0, end: 13.0),
                child: _isLoading
                    ? contentShimmer(context)
                    : (widget.newsType ==
                            getTranslated(context, 'breakingNews_lbl'))
                        ? getBreakingNewssList()
                        : getNewssList())));
  }

  appBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 45),
        child: AppBar(
          // leadingWidth: 25,
          // elevation: 0.0,
          backgroundColor: Colors.transparent,
          title: Transform(
            transform: Matrix4.translationValues(-20.0, 0.0, 0.0),
            child: Text(
              widget.newsType!,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                  color: isDark! ? colors.bgColor : colors.secondaryColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5),
            ),
          ),
          leading: /* setBackButton(
              context, isDark! ? colors.bgColor : colors.secondaryColor), */
              IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDark! ? colors.bgColor : colors.secondaryColor),
            onPressed: () {
              if (widget.fromNewsDetails == true) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                Navigator.pop(context);
              }
            } /* => Navigator.of(context).popUntil(
                (route) => route.isFirst) */
            , //Navigator.of(context).pop(),
            splashColor: Colors.transparent,
          ),
          // systemOverlayStyle:
          //     !isDark! ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
          /* SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,), */
        ));
  }

  Future<bool> onBackPress() {
    // Navigator.of(context).popUntil((route) => route.isFirst);
    //Navigator.pop(context);
    if (widget.fromNewsDetails == true) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  callApi() async {
    //add refresh code here
    offset = offset + perPage;
    // total = 0;
    //all APIs except Breaking News
    (widget.newsType != getTranslated(context, 'forYou_lbl'))
        ? ApiConnection.getAllNews(offset.toString())
            .then((value) => setState(() {
                  // newssList = allNewsList;
                  // _isLoading = false;
                  _isLoadingmore = false;
                }))
        : ApiConnection.getForYoulNews(offset.toString())
            .then((value) => setState(() {
                  // _isLoading = false;
                  _isLoadingmore = false;
                }));

    print("length of updated newssList - ${newssList.length}");
    // _getAllNews();
  }

//show newssList
  getNewssList() {
    return ListView.builder(
        controller: _controller,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: newssList.length,
        itemBuilder: (context, index) {
          DateTime time1 = DateTime.parse(newssList[index].date!);
          return (index == newssList.length && _isLoadingmore)
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsetsDirectional.only(top: 15.0),
                  child: /* AbsorbPointer(
                    absorbing: !enabled,
                    child: */
                      InkWell(
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              //image
                              imageUrl: newssList[index].image!,
                              height: 215.0, //320.0,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context,url) {return placeHolder();},
                              errorWidget: (context, error, stackTrace) {
                                return errorWidget(215, double.infinity);
                              },
                            )),
                        Positioned.directional(
                            textDirection: Directionality.of(context),
                            bottom: 0, //10.0,
                            start: 0, //10,
                            end: 0, //10,
                            height: 95, //123,
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
                                blendMode: BlendMode.overlay,
                                child: Container(
                                  // height: 60,
                                  width: double.infinity,
                                  color: Colors.transparent,
                                  // padding:
                                  //     EdgeInsets.only(bottom: 10), //top: 30
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        //.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              convertToAgo(context,time1, 0)!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  ?.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.w600),
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  newssList[index].title!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1
                                                      ?.copyWith(
                                                          color: colors.bgColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 15,
                                                          height: 1.0,
                                                          letterSpacing: 0.5),
                                                  maxLines: 3,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                            )),
                      ],
                    ),
                    onTap: () async {
                      /*  setState(() {
                        enabled = false;
                      }); */
                      // newssList.remove(index);
                      /* print(
                            "index OnTap --  $index & Id -- ${newssList[index].id} & model id is -- ${widget.model?.id}"); */
                      News model = newssList[index];
                      List<News> newList = [];
                      newList.addAll(newssList);
                      newList.removeAt(index);
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (BuildContext context) => NewsDetails(
                                    model: model, // widget.model,
                                    index: index,
                                    // updateParent: updateFav,
                                    id: newssList[index].id, //widget.model?.id,
                                    // isFav: true,
                                    isDetails: true,
                                    news: newList, //widget.news,
                                    fromShowMoreList: true,
                                  )))
                          .then(
                            (value) => setState(
                                () {}), //to reload it when resume screen /get focus again
                          );
                      /* setState(() {
                        enabled = true;
                      }); */
                    },
                  ),
                  // )//AbsorbPointer
                );
        });
  }

//show BreakingNewssList
  getBreakingNewssList() {
    print("length of array -- ${breakingNewssList.length}");
    return ListView.builder(
        controller: _controller,
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: breakingNewssList.length,
        itemBuilder: (context, index) {
          return (index == breakingNewssList.length)
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: EdgeInsetsDirectional.only(top: 15.0),
                  child: /*  AbsorbPointer(
                    absorbing: !enabled,
                    child: */
                      InkWell(
                    child: Stack(
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              //image
                              imageUrl: breakingNewssList[index].image!,
                              height: 215.0, //320.0,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context,url) {return placeHolder();},
                              errorWidget: (context, error, stackTrace) {
                                return errorWidget(215, double.infinity);
                              },
                            )),
                        Positioned.directional(
                            textDirection: Directionality.of(context),
                            bottom: 0, //10.0,
                            start: 0, //10,
                            end: 0, //10,
                            height: 95, //123,
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
                                blendMode: BlendMode.overlay,
                                child: Container(
                                  height: 60,
                                  width: double.infinity,
                                  color: Colors.transparent,
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        //.center,
                                        child: Padding(
                                            padding: EdgeInsets.only(top: 30.0),
                                            child: Text(
                                              breakingNewssList[index].title!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1
                                                  ?.copyWith(
                                                      color: colors.bgColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                      height: 1.0,
                                                      letterSpacing: 0.5),
                                              maxLines: 3,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                      )),
                                ),
                              ),
                            )),
                      ],
                    ),
                    onTap: () async {
                      /*  setState(() {
                        enabled = false;
                      }); */
                      BreakingNewsModel model = breakingNewssList[index];
                      List<BreakingNewsModel> newBList = [];
                      newBList.addAll(breakingNewssList);
                      newBList.removeAt(index);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => NewsDetails(
                                model1: model, //breakingNewssList[index],
                                index: index,
                                // updateParent: updateFav,
                                id: breakingNewssList[index].id,
                                // isFav: false,
                                isDetails: false,
                                news1: newBList,
                                fromShowMoreList: true,
                              )));
                      /* setState(() {
                        enabled = true;
                      }); */
                    },
                  ),
                  // )//AbsorbPointer
                );
        });
  }

  /*  Future<void> getUserDetails() async {
    CUR_USERID = (await getPrefrence(ID)) ?? "";
    setState(() {});
  } */

  _scrollListener() {
    if (_controller.positions.last.pixels >=
            _controller.positions.last.maxScrollExtent &&
        !_controller.positions.last.outOfRange) {
      if (this.mounted) {
        setState(() {
          _isLoadingmore = true;
          if (offset < total) callApi();
        });
      }
    }
  }
}
