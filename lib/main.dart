import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers/posts_provider.dart';
import 'screens/posts_screen.dart';
import 'screens/create_post_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PostsProvider(),
      child: MaterialApp(
        title: 'Posts app2',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const PostsScreen(),
        routes: {
          '/create-post': (context) => const CreatePostScreen(),
        },
      ),
    );
  }
}
