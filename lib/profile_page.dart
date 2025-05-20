import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'providers/auth_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'models/user_profile.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(UserProfile userProfile, AuthProvider authProvider) async {
    final picker = ImagePicker();
    
    // Show bottom sheet with options
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (pickedFile == null) return;
    
    setState(() => _isUploading = true);
    try {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final updatedProfile = userProfile.copyWith(photoUrl: base64Image);
      await authProvider.updateUserProfile(updatedProfile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final leaderboardProvider = Provider.of<LeaderboardProvider>(context, listen: false);
    final userProfile = authProvider.userProfile;
    final leaderboardUsers = leaderboardProvider.users;
    final isFirstInWeek = leaderboardUsers.isNotEmpty && leaderboardUsers.first.uid == userProfile?.uid;

    if (userProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Badge logic
    final has30DayStreak = userProfile.streak >= 30;
    final hasFocusBeast = userProfile.maxSessionDuration >= 120;

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
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    backgroundImage: userProfile.photoUrl != null && userProfile.photoUrl!.isNotEmpty
                        ? MemoryImage(base64Decode(userProfile.photoUrl!))
                        : null,
                    child: (userProfile.photoUrl == null || userProfile.photoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _isUploading ? null : () => _pickAndUploadImage(userProfile, authProvider),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: _isUploading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${userProfile.firstName} ${userProfile.lastName}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 32),

              // ── Overview ──
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _InfoCard(title: 'Total XP', value: userProfile.xp.toString())),
                  const SizedBox(width: 16),
                  Expanded(child: _InfoCard(title: 'Daily Streak', value: '${userProfile.streak} days')),
                ],
              ),
              const SizedBox(height: 32),

              // ── Badges ──
              Text(
                'Badges',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              _BadgeRow(
                icon: has30DayStreak ? Icons.star : Icons.star_border,
                text: 'Focused for 30 days in a row.',
                earned: has30DayStreak,
              ),
              _BadgeRow(
                icon: isFirstInWeek ? Icons.emoji_events : Icons.emoji_events_outlined,
                text: 'Be the first in the leaderboard in a week.',
                earned: isFirstInWeek,
              ),
              _BadgeRow(
                icon: hasFocusBeast ? Icons.bolt : Icons.bolt_outlined,
                text: 'Focus Beast: Focused for 2 hours in a single session.',
                earned: hasFocusBeast,
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
  final bool earned;

  const _BadgeRow({required this.icon, required this.text, this.earned = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 32, color: earned ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: earned ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)))),
        ],
      ),
    );
  }
}
