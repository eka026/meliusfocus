import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Avatar & Name ──
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Enes Kafa',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // ── Overview ──
              Text(
                'Overview',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _InfoCard(title: 'Total XP', value: '5678')),
                  const SizedBox(width: 16),
                  Expanded(child: _InfoCard(title: 'Daily Streak', value: '54 days')),
                ],
              ),
              const SizedBox(height: 32),

              // ── Badges ──
              Text(
                'Badges',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              _BadgeRow(
                icon: Icons.star_border,
                text: 'Focused for 30 days in a row.',
              ),
              _BadgeRow(
                icon: Icons.emoji_events,
                text: 'Be the first in the leaderboard in a week.',
              ),
              _BadgeRow(
                icon: Icons.bolt,
                text: 'Focus Beast: Focused for 2 hours in a single session.',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BadgeRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 32, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
