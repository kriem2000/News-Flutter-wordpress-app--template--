import 'dart:convert';

import 'package:http/http.dart';
import 'package:news/Helper/Constant.dart';
import 'package:news/Helper/Session.dart';
import 'package:news/Helper/String.dart';
import 'package:news/Model/News.dart';
import 'package:news/ShowMoreNewsList.dart';

List<News> allNewsList = [];

class ApiConnection {
  static Future<void> getAllNews(String offsetVal) async {
    var param = {
      ACCESS_KEY: access_key,
      USER_ID: CUR_USERID != "" ? CUR_USERID : "0",
      OFFSET: offsetVal,
    };
    // print(param);
    Response response =
        await post(Uri.parse(getNewsApi), body: param, headers: headers)
            .timeout(Duration(seconds: timeOut));
    var getdata = json.decode(response.body);

    var totalVal = getdata["total"];
    total = int.parse(totalVal); //pass total to ShowMoreNewsList
    String error = getdata["error"];
    if (error == "false") {
      allNewsList.clear();
      var data = getdata["data"];
      // print("total val is ${totalVal}");
      // print("value @ response of GetAllNews without Limit - $data");
      allNewsList =
          (data as List).map((data) => new News.fromJson(data)).toList();

      newssList.addAll(allNewsList);
    } else {
      print('No data Found !!');
    }
  }

  static Future<void> getForYoulNews(String offsetVal) async {
    var param = {
      ACCESS_KEY: access_key,
      CATEGORY_ID: CATID,
      USER_ID: CUR_USERID != "" ? CUR_USERID : "0",
      OFFSET: offsetVal,
    };
    Response response = await post(Uri.parse(getNewsByUserCatApi),
            body: param, headers: headers)
        .timeout(Duration(seconds: timeOut));
    var getdata = json.decode(response.body);

    var totalVal = getdata["total"];
    total = int.parse(totalVal); //pass total to ShowMoreNewsList
    String error = getdata["error"];

    if (error == "false") {
      allNewsList.clear();
      var data = getdata["data"];
      // print("value @ response of GetForYouNews without Limit - $data");
      allNewsList =
          (data as List).map((data) => new News.fromJson(data)).toList();

      newssList.addAll(allNewsList);
    } else {
      print('No data Found !!');
    }
  }
}
