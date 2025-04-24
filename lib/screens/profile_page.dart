// lib/screens/profile_page.dart

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Custom header ──
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    Text(
                      'Profile',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // 24px vertical
              const SizedBox(height: 24),

              // ── Avatar & Name ──
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),

              // 16px vertical
              const SizedBox(height: 16),

              Text(
                'Enes Kafa',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!.copyWith(fontWeight: FontWeight.bold),

              ),

              // 32px vertical
              const SizedBox(height: 32),

              // ── Overview ──
              Text(
                'Overview',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),

              // 16px vertical
              const SizedBox(height: 16),

              Row(
                children: [
                  // Total XP card
                  Expanded(
                    child: _InfoCard(title: 'Total XP', value: '5678'),
                  ),
                  // 16px horizontal
                  const SizedBox(width: 16),
                  // Daily Streak card
                  Expanded(
                    child: _InfoCard(title: 'Daily Streak', value: '54 days'),
                  ),
                ],
              ),

              // 32px vertical
              const SizedBox(height: 32),

              // ── Badges ──
              Text(
                'Badges',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),

              // 16px vertical
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

              // 32px vertical at bottom
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
            // 8px vertical
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
          // 12px horizontal
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
