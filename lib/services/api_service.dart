import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/post.dart';

class ApiService {
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
          if (kIsWeb) 'Access-Control-Allow-Origin': '*',
        },
      );

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
        throw Exception('Failed to fetch posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch posts: $e');
    }
  }

  Future<Post> createPost(String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
          if (kIsWeb) 'Access-Control-Allow-Origin': '*',
        },
        body: json.encode({
          'title': title,
          'body': body,
          'userId': 1,
        }),
      );

      if (response.statusCode == 201) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Помилка створення поста: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Помилка створення поста: $e');
    }
  }

  Future<void> deletePost(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/posts/$id'),
        headers: {
          if (kIsWeb) 'Access-Control-Allow-Origin': '*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Помилка видалення поста: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Помилка видалення поста: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getComments(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/posts/$postId/comments'),
        headers: {
          if (kIsWeb) 'Access-Control-Allow-Origin': '*',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData);
      } else {
        throw Exception(
            'Помилка завантаження коментарів: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Помилка завантаження коментарів: $e');
    }
  }
}
