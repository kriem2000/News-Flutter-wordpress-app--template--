

import 'package:news/Helper/String.dart';

class TagModel {
  String? id, tagName;

  TagModel({this.id, this.tagName});

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return new TagModel(
        id: json[ID],
        tagName: json[TAGNAME],
      );
  }
}