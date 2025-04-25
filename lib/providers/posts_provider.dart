import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../services/api_service.dart';

class PostsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  int _nextLocalId = 1000; // Початковий ID для локальних постів

  List<Post> get posts => [..._posts];
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;

  List<Post> get filteredPosts {
    if (_searchQuery.isEmpty) return _posts;
    return _posts
        .where((post) =>
            post.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Fetching posts...');
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> postsJson = json.decode(response.body);
        // Зберігаємо існуючі локальні пости
        final localPosts = _posts.where((post) => post.id >= 1000).toList();
        // Оновлюємо пости з API
        _posts = postsJson.map((json) => Post.fromJson(json)).toList();
        // Додаємо локальні пости назад
        _posts.insertAll(0, localPosts);
        print(
            'Fetched ${_posts.length} posts (including ${localPosts.length} local posts)');
        _error = null;
      } else {
        _error = 'Failed to load posts';
        print('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      print('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(String title, String body) async {
    print('Creating post with title: $title');
    print('Current posts count: ${_posts.length}');

    try {
      final response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': title,
          'body': body,
          'userId': 1,
        }),
      );

      print('Create post response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        // Створюємо новий пост з локальним ID
        final newPost = Post(
          id: _nextLocalId++,
          userId: 1,
          title: title,
          body: body,
        );

        print('New post created with local ID: ${newPost.id}');
        _posts.insert(0, newPost);
        print('Posts count after insert: ${_posts.length}');

        notifyListeners();
        print('Notified listeners');
      } else {
        print('Failed to create post: ${response.statusCode}');
        throw Exception('Failed to create post');
      }
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  Future<void> deletePost(int id) async {
    final postIndex = _posts.indexWhere((post) => post.id == id);
    if (postIndex >= 0) {
      final post = _posts[postIndex];
      _posts.removeAt(postIndex);
      notifyListeners();

      try {
        final response = await http.delete(
          Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
        );

        if (response.statusCode != 200) {
          _posts.insert(postIndex, post);
          notifyListeners();
          throw Exception('Failed to delete post');
        }
      } catch (e) {
        _posts.insert(postIndex, post);
        notifyListeners();
        throw e;
      }
    }
  }

  Future<void> editPost(int id, String title, String body) async {
    final postIndex = _posts.indexWhere((post) => post.id == id);
    if (postIndex >= 0) {
      final oldPost = _posts[postIndex];

      try {
        final response = await http.put(
          Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'id': id,
            'title': title,
            'body': body,
            'userId': oldPost.userId,
          }),
        );

        if (response.statusCode == 200) {
          final updatedPost = Post(
            id: id,
            userId: oldPost.userId,
            title: title,
            body: body,
          );
          _posts[postIndex] = updatedPost;
          notifyListeners();
        } else {
          throw Exception('Failed to update post');
        }
      } catch (e) {
        rethrow;
      }
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
