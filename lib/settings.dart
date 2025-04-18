import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), leading: Icon(Icons.menu)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Account"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("App locking preferences"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppLockingScreen()),
            ),
          ),
          const Divider(height: 32),
          SwitchListTile(
            title: const Text("Change theme"),
            value: true,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text("Notifications"),
            value: true,
            onChanged: (val) {},
          ),
          const SizedBox(height: 40),
          const Center(child: Text("© Melius Focus", style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _AccountField(label: "First name:", value: "Enes"),
            _AccountField(label: "Last name:", value: "Kafa"),
            _AccountField(label: "Username:", value: "enes_kafa"),
            _AccountField(label: "Email address:", value: "enes.kafa@sabanciuniv.edu"),
            _AccountField(label: "Phone number:", value: "+90 553 721 4556"),
            const SizedBox(height: 10),
            DropdownButtonFormField(
              value: "English",
              items: const [
                DropdownMenuItem(value: "English", child: Text("English")),
                DropdownMenuItem(value: "Turkish", child: Text("Turkish")),
              ],
              onChanged: (value) {},
              decoration: const InputDecoration(labelText: "Language"),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("About Melius Focus:"),
                  SizedBox(height: 8),
                  Text("Privacy Policy", style: TextStyle(color: Colors.blue)),
                  Text("FAQs", style: TextStyle(color: Colors.blue)),
                  Text("Terms of Service", style: TextStyle(color: Colors.blue)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AccountField extends StatelessWidget {
  final String label;
  final String value;

  const _AccountField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
      ),
      readOnly: true,
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
        leading: BackButton(),
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
