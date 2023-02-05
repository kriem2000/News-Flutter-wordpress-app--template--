import '../Helper/String.dart';

class LiveStreamingModel {
  String? id, image, title, type, url;

  LiveStreamingModel(
      {this.id,
        this.image,
        this.title,
        this.type,
        this.url
      });

  factory LiveStreamingModel.fromJson(Map<String, dynamic> json) {
    return new LiveStreamingModel(
        id: json[ID],
        image: json[IMAGE],
        title: json[TITLE],
        type: json[TYPE],
        url: json[URL]);
  }
}