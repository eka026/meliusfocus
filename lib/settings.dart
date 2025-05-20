import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'models/user_profile.dart';
import 'homenavigation.dart';
import 'providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.nightlight_round),
            title: const Text('Change theme'),
            trailing: Consumer2<ThemeProvider, AuthProvider>(
              builder: (context, themeProvider, authProvider, _) => Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.setDarkMode(value, user: authProvider.user);
                },
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
          // Add more settings here in the future
        ],
      ),
    );
  }
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final userProfile = Provider.of<AuthProvider>(context, listen: false).userProfile;
    _firstNameCtrl = TextEditingController(text: userProfile?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: userProfile?.lastName ?? '');
    _usernameCtrl = TextEditingController(text: userProfile?.username ?? '');
    _emailCtrl = TextEditingController(text: userProfile?.email ?? '');
    _phoneCtrl = TextEditingController(text: userProfile?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentProfile = authProvider.userProfile;
    if (currentProfile == null) return;

    try {
      final updatedProfile = UserProfile(
        uid: currentProfile.uid,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        language: currentProfile.language,
        xp: currentProfile.xp,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
        createdBy: currentProfile.createdBy,
      );

      await authProvider.updateUserProfile(updatedProfile);
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final userProfile = authProvider.userProfile;
          if (userProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _AccountField(
                    label: "First name:",
                    controller: _firstNameCtrl,
                    enabled: _isEditing,
                  ),
                  _AccountField(
                    label: "Last name:",
                    controller: _lastNameCtrl,
                    enabled: _isEditing,
                  ),
                  _AccountField(
                    label: "Username:",
                    controller: _usernameCtrl,
                    enabled: _isEditing,
                  ),
                  _AccountField(
                    label: "Email address:",
                    controller: _emailCtrl,
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _AccountField(
                    label: "Phone number:",
                    controller: _phoneCtrl,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    value: userProfile.language,
                    items: const [
                      DropdownMenuItem(value: "English", child: Text("English")),
                      DropdownMenuItem(value: "Turkish", child: Text("Turkish")),
                    ],
                    onChanged: _isEditing ? (value) {} : null,
                    decoration: const InputDecoration(labelText: "Language"),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("About Melius Focus:", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 8),
                        Text("Privacy Policy", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                        Text("FAQs", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                        Text("Terms of Service", style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AccountField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;

  const _AccountField({
    required this.label,
    required this.controller,
    required this.enabled,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      enabled: enabled,
      keyboardType: keyboardType,
      validator: enabled ? (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      } : null,
    );
  }
}

class AppLockingScreen extends StatelessWidget {
  const AppLockingScreen({super.key});

  final List<String> apps = const [
    "Spotify",
    "ChatGPT",
    "MySU",
    "Notes",
    "Akbank",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App locking preferences"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Allowed App List:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(height: 20),
            ...apps.map((app) => ListTile(
                  leading: const Icon(Icons.circle, size: 12),
                  title: Text(app),
                )),
          ],
        ),
      ),
    );
  }
}
