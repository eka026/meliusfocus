// lib/screens/login_signup_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_gaps.dart';
import '../utils/app_text_styles.dart';
import '../routes.dart';
import '../widgets/primary_button.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true; // tab toggle
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
              // --- logo ---
              SizedBox(
                width: 200,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    // If the image path is wrong or the asset is missing, show the old placeholder:
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.lightGrey,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, size: 60),
                    ),
                  ),
                ),
              ),
              Gaps.v16,
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

              // --- Forgot password link ---
              InkWell(
                onTap: () => Navigator.pushNamed(context, routeForgotPwd),
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
              PrimaryButton(
                label: isLogin ? 'Log in' : 'Sign up',
                onPressed: _submit,
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
      Navigator.pushReplacementNamed(context, routeHome);
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
