import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ArticleRepository {
  Future<List<Article>> fetchArticles() async {
    final response =
    await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }
}