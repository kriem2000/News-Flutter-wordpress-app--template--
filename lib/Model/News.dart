// ignore_for_file: unnecessary_null_comparison

import 'package:news/Helper/String.dart';
import 'package:news/Model/Survey.dart';

//news and user model data fetch from admin side in json api

class News {
  String? id;

  String? userId;

  String? newsId;

  String? categoryId;
  String? title;

  String? date;

  String? contentType;

  String? contentValue;

  String? image;

  String? desc;

  String? categoryName;

  String? counter;

  String? dateSent;

  String? totalLikes;

  String? like;

  String? keyName;

  String? tagId;

  String? tagName;

  String? dislike;

  String? totalDislike;

  String? subCatId;

  String? img;
  String? subCatName;
  String? showTill;

  List<ImageData>? imageDataList;

  bool? history = false;
  String? question, status, type;
  List<Option>? optionDataList;
  int? from;

  News(
      {this.id,
      this.userId,
      this.newsId,
      this.categoryId,
      this.title,
      this.date,
      this.contentType,
      this.contentValue,
      this.image,
      this.desc,
      this.categoryName,
      this.counter,
      this.dateSent,
      this.imageDataList,
      this.totalLikes,
      this.like,
      this.keyName,
      this.tagName,
      this.dislike,
      this.subCatId,
      this.totalDislike,
      this.tagId,
      this.history,
      this.optionDataList,
      this.question,
      this.status,
      this.type,
      this.from,
      this.img,
      this.subCatName,
      this.showTill});

  factory News.history(String history) {
    return new News(title: history, history: true);
  }

  factory News.fromSurvey(Map<String, dynamic> json) {
    List<Option> optionList = (json[OPTION] as List)
        .map((data) => new Option.fromJson(data))
        .toList();

    return News(
        id: json[ID],
        question: json[QUESTION],
        status: json[STATUS],
        optionDataList: optionList,
        type: "survey",
        from: 1);
  }

  factory News.fromJson(Map<String, dynamic> json) {
    String? tagName;
    if (json[TAG_NAME] == null) {
      tagName = "";
    } else {
      tagName = json[TAG_NAME];
    }
    List<ImageData> imageData = [];
    var imageList = (json[IMAGE_DATA] as List);
    if (imageList == null || imageList.isEmpty)
      imageList = [];
    else
      imageData =
          imageList.map((data) => new ImageData.fromJson(data)).toList();

    return new News(
        id: json[ID],
        userId: json[USER_ID],
        newsId: json[NEWS_ID],
        categoryId: json[CATEGORY_ID],
        title: json[TITLE],
        date: json[DATE],
        contentType: json[CONTENT_TYPE],
        contentValue: json[CONTENT_VALUE],
        image: json[IMAGE],
        desc: json[DESCRIPTION],
        categoryName: json[CATEGORY_NAME],
        counter: json[COUNTER],
        dateSent: json[DATE_SENT],
        imageDataList: imageData,
        totalLikes: json[TOTAL_LIKE],
        like: json[LIKE],
        tagId: json[TAG_ID],
        tagName: tagName /*json[TAG_NAME]*/,
        dislike: json[DISLIKE],
        subCatId: json[SUBCAT_ID],
        totalDislike: json[TOTAL_DISLIKE],
        history: false,
        type: "news",
        img: "",
        subCatName: json[SUBCAT_NAME],
        showTill: json[SHOW_TILL]);
  }

  toList() {}
}

class ImageData {
  String? id;
  String? otherImage;

  ImageData({this.otherImage, this.id});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return new ImageData(otherImage: json[OTHER_IMAGE], id: json[ID]);
  }
}
