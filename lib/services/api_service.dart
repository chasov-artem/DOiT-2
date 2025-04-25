import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$_baseUrl/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> postsJson = json.decode(response.body);
      return postsJson
          .map((json) => Post(
                id: json['id'],
                title: json['title'],
                body: json['body'],
                userId: json['userId'],
              ))
          .toList();
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  Future<Post> createPost(String title, String body) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'body': body,
        'userId': 1, // Використовуємо фіксований userId для прикладу
      }),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Помилка створення поста');
    }
  }

  Future<void> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/posts/$id'));

    if (response.statusCode != 200) {
      throw Exception('Помилка видалення поста');
    }
  }

  Future<List<Map<String, dynamic>>> getComments(int postId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/posts/$postId/comments'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Помилка завантаження коментарів');
    }
  }
}
