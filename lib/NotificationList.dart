// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/Color.dart';
import 'package:news/ListItemNotification.dart';
import 'package:news/Model/Notification.dart';
import 'package:shimmer/shimmer.dart';
import 'Helper/String.dart';
import 'Model/News.dart';
import 'NewsDetails.dart';

class NotificationList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateNoti();
}

class StateNoti extends State<NotificationList> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController controller = new ScrollController();
  ScrollController controller1 = new ScrollController();

  List<NotificationModel> tempList = [];
  bool _isNetworkAvail = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey1 =
      new GlobalKey<RefreshIndicatorState>();
  TabController? _tc;
  List<NotificationModel> notiList = [];
  int offset = 0;
  int total = 0;
  int perOffset = 0;
  int perTotal = 0;
  bool isLoadingmore = true;
  bool _isLoading = true;
  bool isPerLoadingmore = true;
  bool _isPerLoading = true;

  bool _deleteSuccess = false;

  List<NotificationModel> tempUserList = [];
  List<NotificationModel> userNoti = [];
  List<NotificationModel> userLocalNoti = [];
  List<String> _tabs = [];
  List<String> selectedList = [];

  @override
  void initState() {
    super.initState();
    getUserNotification();
    getNotification();
    controller.addListener(_scrollListener);
    controller1.addListener(_scrollListener1);
    /*new Future.delayed(Duration.zero, () {

    });*/
    _tc = TabController(length: 2, vsync: this, initialIndex: 0);
    _tc!.addListener(_handleTabControllerTick);
  }

  void _handleTabControllerTick() {
    setState(() {
      selectedList.clear();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    controller1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tabs = [
      getTranslated(context, 'personal_lbl')!,
      getTranslated(context, 'news_lbl')!
    ];
    return Scaffold(
        key: _scaffoldKey,
        appBar: setAppBar(),
        body: TabBarView(controller: _tc, children: [
          _isPerLoading
              ? shimmer1(context)
              : userNoti.length == 0
                  ? Padding(
                      padding:
                          EdgeInsetsDirectional.only(bottom: kToolbarHeight),
                      child: Center(
                          child:
                              Text(getTranslated(context, 'noti_nt_avail')!)))
                  : RefreshIndicator(
                      key: _refreshIndicatorKey1,
                      onRefresh: refresh,
                      child: Padding(
                          padding: EdgeInsetsDirectional.only(
                              start: 15.0, end: 15.0, bottom: 10.0),
                          child: Column(children: <Widget>[
                            if (selectedList.length > 0)
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    deleteNoti(selectedList.join(','));
                                    // getUserNotification();
                                    if (_deleteSuccess == true) refresh();
                                  },
                                ),
                              ),
                            // : SizedBox.shrink(),
                            Expanded(
                                child: ListView.builder(
                              controller: controller1,
                              itemCount: userNoti.length,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return (index == userNoti.length &&
                                        isPerLoadingmore)
                                    ? Center(child: CircularProgressIndicator())
                                    : Dismissible(
                                        key: ValueKey(
                                            userNoti[index].id.toString()),
                                        //UniqueKey(),
                                        //Key(userNoti[index].id.toString()),
                                        direction: DismissDirection.endToStart,
                                        /*  confirmDismiss: (direction) async {
                                          if (direction ==
                                              DismissDirection.endToStart) {
                                            /// delete
                                            return true;
                                          }
                                        }, */
                                        onDismissed: (direction) {
                                          // Remove the item from the data source.
                                          deleteNoti(userNoti[index].id!);
                                          if (_deleteSuccess == true) refresh();
                                          // getUserNotification();
                                        },
                                        background: slideLeftBackground(),
                                        secondaryBackground:
                                            slideLeftBackground(),
                                        child: ListItemNoti(
                                            userNoti: userNoti[index],
                                            isSelected: (bool value) {
                                              setState(() {
                                                if (value) {
                                                  selectedList
                                                      .add(userNoti[index].id!);
                                                } else {
                                                  selectedList.remove(
                                                      userNoti[index].id!);
                                                }
                                              });
                                            },
                                            key: Key(
                                                userNoti[index].id.toString())),
                                      );
                              },
                            ))
                          ]))),
          _isLoading
              ? shimmer(context)
              : notiList.length == 0
                  ? Padding(
                      padding: EdgeInsetsDirectional.only(top: kToolbarHeight),
                      child: Center(
                          child:
                              Text(getTranslated(context, 'noti_nt_avail')!)))
                  : RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _refresh1,
                      child: Padding(
                          padding: EdgeInsetsDirectional.only(
                              start: 15.0, end: 15.0, top: 10.0, bottom: 10.0),
                          child: ListView.builder(
                            controller: controller,
                            itemCount: notiList.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return (index == notiList.length && isLoadingmore)
                                  ? Center(child: CircularProgressIndicator())
                                  : listItem(index);
                            },
                          )))
        ]));
  }

  Widget tabShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: Colors.grey,
      child: Padding(
          padding: EdgeInsetsDirectional.only(start: 30.0, top: 20.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              width: 120,
              height: 15.0,
              color: Colors.grey,
            ),
            Padding(
                padding: EdgeInsetsDirectional.only(start: 60.0),
                child: Container(
                  width: 120,
                  height: 15.0,
                  color: Colors.grey,
                )),
          ])),
    );
  }

  //refresh function used in refresh notification
  Future<void> refresh() async {
    setState(() {
      _isPerLoading = true;
    });
    perOffset = 0;
    perTotal = 0;
    userNoti.clear();
    getUserNotification();
  }

  Future<void> _refresh1() async {
    setState(() {
      _isLoading = true;
    });
    offset = 0;
    total = 0;
    notiList.clear();
    getNotification();
  }

  setAppBar() {
    return PreferredSize(
        preferredSize: Size(double.infinity, 92), //72
        child: Container(
          // color: colors.primary,
          padding: EdgeInsetsDirectional.only(
              top: MediaQuery.of(context).padding.top + 10.0, start: 15),
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              /*alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(top: 20), */
              child: Text(
                getTranslated(context, 'notification_lbl')!,
                style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Theme.of(context).colorScheme.darkColor,
                    fontWeight: FontWeight.w600,
                    // fontSize: 22,
                    letterSpacing: 0.5),
              ),
            ),
            Spacer(),
            setTabs(),
          ]),
        ));
  }

  deleteNoti(String id) async {
    print("id:${id}");
    setState(() {
      _deleteSuccess = false;
    });

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {ACCESS_KEY: access_key, ID: id};
      Response response = await post(Uri.parse(deleteUserNotiApi),
              body: param, headers: headers)
          .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      String error = getdata["error"];
      // print("error:${param.toString()}-${error}-${selectedList.length}");
      String msg = getdata["message"];
      print("msg:$msg");
      if (error == "false") {
        // print("length @ before Delete is ${userNoti.length}");
        var delItem = []; //indexes of deleted items
        for (int i = 0; i < userNoti.length; i++) {
          // print("List id - ${userNoti[i].id} & loop id: $i");
          // userNoti.removeWhere((item) => item.id == userNoti[i].id);
          if (id.contains(",") && id.contains(userNoti[i].id!)) {
            // print("if- $i & ${userNoti[i].id}");
            delItem.add(i);
            // userNoti.removeWhere((item) => item.id == userNoti[i].id);
            // print("multiple deleted ids - ${id}");
          } else {
            // print("else- $i");
            if (userNoti[i].id == id) {
              // print("else single id- $i");
              // print("Deleted val ${userNoti[i].title} - ${userNoti[i].id}");
              userNoti.removeAt(i);
            }
          }
        }
        // print("length of DelItem ${delItem.length} & ${delItem.toList()}");
        for (int j = 0; j < delItem.length; j++) {
          // print("value of delItem ${delItem[j].toString()}");
          userNoti.removeAt(delItem[j]);
          // print(
          //     "Deleted val ${userNoti[delItem[j]].id}"); // ${userNoti[j].message} -
        }
        // setState(() {});
        selectedList.clear();
        print(
            "length @Delete is ${userNoti.length}"); //values in list - ${userNoti[0].title} &
        // showSnackBar(getTranslated(context, 'delete_noti')!, context);
        setState(() {
          _deleteSuccess = true;
        });
      } else {
        showSnackBar(msg, context); //error = true
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
    setState(() {
      _deleteSuccess = true;
    });
  }

  Widget slideLeftBackground() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 5.0,
        bottom: 10.0,
      ),
      child: Container(
        decoration: BoxDecoration(
            color: colors.primary,
            /*  boxShadow: <BoxShadow>[
              BoxShadow(
                  blurRadius: 10.0,
                  offset: const Offset(5.0, 5.0),
                  color:
                      Theme.of(context).colorScheme.fontColor.withOpacity(0.1),
                  spreadRadius: 1.0),
            ], */
            borderRadius: BorderRadius.circular(10)),
        child: Align(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          alignment: Alignment.centerRight,
        ),
      ),
    );
  }

  setTabs() {
    return Column(
      children: [
        _tabs.length != 0
            ? Align(
                alignment: Alignment.center,
                child: DefaultTabController(
                    length: 2,
                    child: Row(children: [
                      Expanded(
                        child: Container(
                            padding: EdgeInsetsDirectional.only(
                                start: 10.0, end: 25.0), //, top: 30
                            width: deviceWidth! / 1.1,
                            height: 32.0, //35.0,

                            child: TabBar(
                              controller: _tc,
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .subtitle1
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      // fontSize: 20,
                                      letterSpacing: 0.5),
                              // labelPadding: EdgeInsets.only(top: 5), //.zero,
                              labelColor:
                                  Theme.of(context).colorScheme.darkColor,
                              unselectedLabelColor: Theme.of(context)
                                  .colorScheme
                                  .fontColor
                                  .withOpacity(0.7),
                              indicatorColor:
                                  Theme.of(context).colorScheme.darkColor,
                              indicator: UnderlineTabIndicator(
                                  borderSide: BorderSide(
                                      width: 3.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .darkColor
                                          .withOpacity(0.8)),
                                  insets:
                                      EdgeInsets.symmetric(horizontal: 30.0)),
                              tabs: _tabs.map((e) => Tab(text: e)).toList(),
                            )),
                      ),
                    ])),
              )
            : tabShimmer(),
        Padding(
            padding: EdgeInsetsDirectional.only(end: 15.0), //start: 15.0,
            child: Divider(
              thickness: 1.5,
              height: 1.0,
              color: Theme.of(context).colorScheme.fontColor.withOpacity(0.3),
            ))
      ],
    );
  }

  //shimmer effects
  Widget shimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.only(
          start: 15.0, end: 15.0, top: 20.0, bottom: 10.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: Colors.grey,
        child: SingleChildScrollView(
          child: Column(
            children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                .map((_) => Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: 5.0,
                      bottom: 10.0,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.withOpacity(0.6),
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.grey,
                            ),
                            width: 80.0,
                            height: 80.0,
                          ),
                          Expanded(
                              child: Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: 13.0, end: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 13.0,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 3.0),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 13.0,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                ),
                                Container(
                                  width: 100,
                                  height: 10.0,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ))
                        ],
                      ),
                    )))
                .toList(),
          ),
        ),
      ),
    );
  }

  //shimmer effects
  Widget shimmer1(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.only(
          start: 15.0, end: 15.0, top: 20.0, bottom: 10.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: Colors.grey,
        child: SingleChildScrollView(
          child: Column(
            children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                .map((_) => Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: 5.0,
                      bottom: 10.0,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.withOpacity(0.6),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: EdgeInsetsDirectional.only(start: 5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.grey,
                                ),
                                width: 25.0,
                                height: 25.0,
                              )),
                          Expanded(
                              child: Padding(
                            padding: EdgeInsetsDirectional.only(
                                start: 13.0, end: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 13.0,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 3.0),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 13.0,
                                  color: Colors.grey,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                ),
                                Container(
                                  width: 100,
                                  height: 10.0,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ))
                        ],
                      ),
                    )))
                .toList(),
          ),
        ),
      ),
    );
  }

  //list of notification shown
  Widget listItem(int index) {
    NotificationModel model = notiList[index];
    DateTime time1 = DateTime.parse(model.dateSent!);
    return Hero(
        tag: model.id!,
        child: Padding(
            padding: EdgeInsetsDirectional.only(
              top: 5.0,
              bottom: 10.0,
            ),
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .controlSettings, //boxColor,
                    /* boxShadow: <BoxShadow>[
                      BoxShadow(
                          blurRadius: 10.0,
                          offset: const Offset(5.0, 5.0),
                          color: Theme.of(context)
                              .colorScheme
                              .fontColor
                              .withOpacity(0.1),
                          spreadRadius: 0.6),//1.0
                    ], */
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      model.image != null || model.image != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: model.image! != ""
                                  ? CachedNetworkImage(
                                      fadeInDuration:
                                          Duration(milliseconds: 150),
                                      imageUrl: model.image!,
                                      height: 80.0,
                                      width: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) {
                                        return placeHolder();
                                      },
                                      errorWidget:
                                          (context, error, stackTrace) {
                                        return errorWidget(80, 80);
                                      },
                                    )
                                  : Image.asset(
                                      "assets/images/splash_Icon.png",
                                      height: 80.0,
                                      width: 80,
                                      fit: BoxFit.scaleDown,
                                    ),
                            )
                          : SizedBox.shrink(),
                      Expanded(
                          child: Padding(
                        padding:
                            EdgeInsetsDirectional.only(start: 13.0, end: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(model.title!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor
                                            .withOpacity(0.9),
                                        fontSize: 15.0,
                                        letterSpacing: 0.1)),
                            Padding(
                                padding: EdgeInsetsDirectional.only(top: 8.0),
                                child: Text(convertToAgo(context, time1, 2)!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                            fontWeight: FontWeight.normal,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .fontColor
                                                .withOpacity(0.7),
                                            fontSize: 11)))
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              onTap: () {
                if (isRedundentClick(DateTime.now(), diff)) {
                  //duration
                  print('hold on, processing');
                  return;
                }
                NotificationModel model = notiList[index];
                if (model.newsId != "") {
                  getNewsById(model.newsId!);
                }
                diff = resetDiff;
              },
            )));
  }

  // updateParent() {}

  //when open dynamic link news index and id can used for fetch specific news
  Future<void> getNewsById(String id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var param = {
        NEWS_ID: id,
        ACCESS_KEY: access_key,
        USER_ID: CUR_USERID != null && CUR_USERID != "" ? CUR_USERID : "0"
      };
      Response response =
          await post(Uri.parse(getNewsByIdApi), body: param, headers: headers)
              .timeout(Duration(seconds: timeOut));
      var getdata = json.decode(response.body);

      String error = getdata["error"];

      if (error == "false") {
        var data = getdata["data"];
        List<News> news = [];
        news = (data as List).map((data) => new News.fromJson(data)).toList();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => NewsDetails(
                  model: news[0],
                  index: int.parse(id),
                  // updateParent: updateParent,
                  id: news[0].id,
                  // isFav: false,
                  isDetails: true,
                  news: [],
                )));
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
    }
  }

  //get notification using api
  Future<void> getNotification() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          ACCESS_KEY: access_key,
        };
        Response response = await post(Uri.parse(getNotificationApi),
                headers: headers, body: parameter)
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
                  .map((data) => new NotificationModel.fromJson(data))
                  .toList();

              notiList.addAll(tempList);
              offset = offset + perPage;
            }
          } else {
            isLoadingmore = false;
          }
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        }
      } on TimeoutException catch (_) {
        showSnackBar(getTranslated(context, 'somethingMSg')!, context);
        setState(() {
          _isLoading = false;
          isLoadingmore = false;
        });
      }
    } else {
      showSnackBar(getTranslated(context, 'internetmsg')!, context);
      setState(() {
        _isLoading = false;
        isLoadingmore = false;
      });
    }
  }

  //get notification using api
  Future<void> getUserNotification() async {
    if (CUR_USERID != null && CUR_USERID != "") {
      _isNetworkAvail = await isNetworkAvailable();
      if (_isNetworkAvail) {
        try {
          var parameter = {
            LIMIT: perPage.toString(),
            OFFSET: perOffset.toString(),
            ACCESS_KEY: access_key,
            USER_ID: CUR_USERID
          };
          Response response = await post(Uri.parse(getUserNotificationApi),
                  headers: headers, body: parameter)
              .timeout(Duration(seconds: timeOut));
          if (response.statusCode == 200) {
            var getData = json.decode(response.body);
            String error = getData["error"];
            if (error == "false") {
              // userNoti.clear();
              perTotal = int.parse(getData["total"]);
              if ((perOffset) < perTotal) {
                tempUserList.clear();
                var data = getData["data"];
                tempUserList = (data as List)
                    .map((data) => new NotificationModel.fromJson(data))
                    .toList();
                if (mounted)
                  setState(() {
                    userNoti.addAll(tempUserList);
                    userLocalNoti.addAll(tempUserList);
                  });
                print(
                    "length @ Loading is ${userNoti.length} & value is ${userNoti[0].id}");

                for (int i = 0; i < userLocalNoti.length; i++) {
                  print(
                      "comments list - ${userLocalNoti[i].id} - ${userLocalNoti[i].message} - ${userLocalNoti[i].type}");
                }
                perOffset = perOffset + perPage;
              }
            } else {
              isPerLoadingmore = false;
            }
            if (mounted)
              setState(() {
                _isPerLoading = false;
              });
          }
        } on TimeoutException catch (_) {
          showSnackBar(getTranslated(context, 'somethingMSg')!, context);
          setState(() {
            _isPerLoading = false;
            isPerLoadingmore = false;
          });
        }
      } else {
        showSnackBar(getTranslated(context, 'internetmsg')!, context);
        setState(() {
          _isPerLoading = false;
          isPerLoadingmore = false;
        });
      }
    } else {
      setState(() {
        _isPerLoading = false;
      });
    }
  }

  _scrollListener() {
    if (controller.positions.last.pixels >=
            controller.positions.last.maxScrollExtent &&
        !controller.positions.last.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset < total) getNotification();
        });
      }
    }
  }

  _scrollListener1() {
    if (controller1.offset >= controller1.position.maxScrollExtent &&
        !controller1.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isPerLoadingmore = true;

          if (perOffset < perTotal) getUserNotification();
        });
      }
    }
  }
}
