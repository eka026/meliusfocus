import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';

class HomeNavigationDrawer extends StatelessWidget {
  const HomeNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Access AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(height: 60),
              ListTile(
                leading: Icon(Icons.emoji_events, color: Theme.of(context).colorScheme.onSurface),
                title: Text('Leaderboard', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context); // close drawer
                  Navigator.pushNamed(context, '/leaderboard');
                },
              ),
              ListTile(
                leading: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface),
                title: Text('Your Profile', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(context); // close drawer
                  Navigator.pushNamed(context, '/profile'); // 🔥 navigate to profile
                },
              ),
              ListTile( // New Logout ListTile
                leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.onSurface),
                title: Text('Logout', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                onTap: () async {
                  Navigator.pop(context); // close drawer
                  try {
                    await authProvider.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                  } catch (e) {
                    // Handle potential errors during sign out, e.g., show a SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: ${e.toString()}')),
                    );
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ListTile(
              leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface),
              title: Text('Settings', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
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
