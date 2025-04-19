import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_gaps.dart';
import '../utils/app_text_styles.dart';
import '../loginroutes.dart'; // if you don’t have this, remove the routes and use raw strings
import '../widgets/primary_button.dart'; // if missing, we can replace this with a regular ElevatedButton

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🧼 Removed logo block that was crashing

              Text('Welcome!', style: AppTextStyles.title),
              Gaps.v32,

              // --- Tabs (Log in | Sign up) ---
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _tabButton(true),
                    _tabButton(false),
                  ],
                ),
              ),
              Gaps.v32,

              // --- Form ---
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter email';
                        if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    Gaps.v16,
                    TextFormField(
                      controller: _pwdCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) =>
                          v != null && v.length >= 6 ? null : 'Min 6 chars',
                    ),
                  ],
                ),
              ),
              Gaps.v32,

              // --- Forgot password (can keep or remove) ---
              InkWell(
                onTap: () {
                  // Navigator.pushNamed(context, routeForgotPwd); // remove if unused
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.sentiment_dissatisfied),
                    SizedBox(width: 8),
                    Text('Forgot my password'),
                  ],
                ),
              ),
              Gaps.v32,

              // --- Primary button ---
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(isLogin ? 'Log in' : 'Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(bool loginTab) {
    final selected = isLogin == loginTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLogin = loginTab),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            loginTab ? 'Log in' : 'Sign up',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.black : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      print("Logging in as: ${_emailCtrl.text}"); // Optional debug log
      Navigator.pushReplacementNamed(context, '/'); // Goes to home
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Form invalid'),
          content: const Text('Please fix errors before continuing.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }
}
