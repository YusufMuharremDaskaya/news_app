import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/Models/Articles.dart';
import 'package:news_app/Models/News.dart';

class HtmlService {
  static HtmlService _singleton = HtmlService._internal();
  HtmlService._internal();

  factory HtmlService() {
    return _singleton;
  }

  static Future<List<Articles>> getNews() async {
    String url =
        'https://newsapi.org/v2/top-headlines?country=tr&category=business&apiKey=446c1625c64a47c2a456fd32b74fb8a4';
    final response = await http.get(url);
    if (response.body.isNotEmpty) {
      final responseJson = json.decode(response.body);
      News news = News.fromJson(responseJson);
      return news.articles;
    }
  }
}
