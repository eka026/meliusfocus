import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homenavigation.dart';
import 'providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const HomeNavigationDrawer(),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userProfile = authProvider.userProfile;
          final greeting = userProfile != null 
              ? "Hi ${userProfile.firstName}! 👋🏻"
              : "Welcome! 👋🏻";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "What do you want to do today? 🤓",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _HomeButton(
                        title: 'Focus',
                        subtitle: 'Set a timer',
                        onTap: () {
                          Navigator.pushNamed(context, '/focus');
                        },
                      ),
                      _HomeButton(
                        title: 'Spaced Repetition',
                        subtitle: 'Create a spaced repetition plan',
                        onTap: () {
                          Navigator.pushNamed(context, '/spaced_repetition');
                        },
                      ),
                      _HomeButton(
                        title: 'Flashcards',
                        subtitle: 'Memorize with flashcards',
                        onTap: () {
                          Navigator.pushNamed(context, '/decks');
                        },
                      ),
                      _HomeButton(
                        title: 'Your Profile',
                        subtitle: 'Track your progress',
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
