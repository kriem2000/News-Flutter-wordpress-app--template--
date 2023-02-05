import 'package:news/Helper/String.dart';

//category model fetch category data from server side
class NotificationModel {
  String? id, image, message, dateSent, title, newsId, type, date;

  NotificationModel(
      {this.id,
      this.image,
      this.message,
      this.title,
      this.dateSent,
      this.newsId,
      this.type,
      this.date});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return new NotificationModel(
        id: json[ID],
        image: json[IMAGE],
        message: json[MESSAGE],
        dateSent: json[DATE_SENT],
        newsId: json[NEWS_ID],
        title: json[TITLE],
        type: json[TYPE],
        date: json[DATE]);
  }
}
