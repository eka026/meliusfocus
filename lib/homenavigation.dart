import 'package:flutter/material.dart';

class HomeNavigationDrawer extends StatelessWidget {
  const HomeNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(height: 60),
              ListTile(
                leading: const Icon(Icons.emoji_events),
                title: const Text('Leaderboard'),
                onTap: () {
                  Navigator.pop(context); // close drawer
                  Navigator.pushNamed(context, '/leaderboard');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Your Profile'),
                onTap: () {
                  Navigator.pop(context); // close drawer
                  Navigator.pushNamed(context, '/profile'); // 🔥 navigate to profile
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        ],
      ),
    );
  }
}
