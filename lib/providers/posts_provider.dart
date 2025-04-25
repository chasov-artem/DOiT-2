import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../services/api_service.dart';

class PostsProvider with ChangeNotifier {
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';
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
    print('Fetching posts...');
    try {
      // Save local posts (posts with ID >= 1000)
      final localPosts = _posts.where((post) => post.id >= 1000).toList();

      // Fetch remote posts
      final remotePosts = await _apiService.fetchPosts();

      // Combine remote and local posts
      _posts = [...remotePosts, ...localPosts];
      notifyListeners();
      print('Posts fetched successfully. Total posts: ${_posts.length}');
    } catch (error) {
      print('Error fetching posts: $error');
      throw Exception('Failed to fetch posts');
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
    print('Starting to edit post with ID: $id');
    print('Current posts count: ${_posts.length}');

    final postIndex = _posts.indexWhere((post) => post.id == id);
    print('Found post at index: $postIndex');

    if (postIndex == -1) {
      print('Post not found with ID: $id');
      throw Exception('Post not found');
    }

    final oldPost = _posts[postIndex];
    print('Old post title: ${oldPost.title}');
    print('New title: $title');

    final updatedPost = Post(
      id: oldPost.id,
      title: title,
      body: body,
      userId: oldPost.userId,
    );

    try {
      if (id >= 1000) {
        print('Editing local post with ID: $id');
        _posts[postIndex] = updatedPost;
        notifyListeners();
        print('Local post updated successfully');
        return;
      }

      final response = await http.put(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
        body: json.encode({
          'id': id,
          'title': title,
          'body': body,
          'userId': oldPost.userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _posts[postIndex] = updatedPost;
        notifyListeners();
        print('Remote post updated successfully');
      } else {
        print('Failed to update remote post. Status: ${response.statusCode}');
        throw Exception('Failed to update post');
      }
    } catch (error) {
      print('Error updating post: $error');
      _posts[postIndex] = oldPost;
      notifyListeners();
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
