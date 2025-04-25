import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gluestack_ui/gluestack_ui.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_item.dart';
import '../widgets/app_drawer.dart';

class PostsListScreen extends StatelessWidget {
  const PostsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const GSHeading(
          text: 'Posts',
          size: GSHeadingSizes.$xl,
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<PostsProvider>(
        builder: (context, postsProvider, child) {
          if (postsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (postsProvider.posts.isEmpty) {
            return Center(
              child: GSText(
                text: 'Немає постів для відображення',
                style: GSStyle(
                  textStyle: TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Пошук постів',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: postsProvider.setSearchQuery,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: postsProvider.filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = postsProvider.filteredPosts[index];
                    return PostItem(post: post);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
