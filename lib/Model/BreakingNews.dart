import 'package:news/Helper/String.dart';

class BreakingNewsModel {
  String? id, image, title, desc;

  BreakingNewsModel({this.id, this.image, this.title, this.desc});

  factory BreakingNewsModel.fromJson(Map<String, dynamic> json) {
    return new BreakingNewsModel(
      id: json[ID],
      image: json[IMAGE],
      title: json[TITLE],
      desc: json[DESCRIPTION],
    );
  }
}
