import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                'DOiT-2',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Список постів'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Створити пост'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/create-post');
            },
          ),
        ],
      ),
    );
  }
}
