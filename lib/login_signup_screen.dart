import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../providers/auth_provider.dart' as app_auth_provider; // Import your AuthProvider (using alias if needed)
import '../utils/app_colors.dart';
import '../utils/app_gaps.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added this import for FirebaseException

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; // Default to login tab
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _isLoading = false; // To show a loading indicator

  // Helper function to show an AlertDialog
  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return; // Check if the widget is still in the tree
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Authentication Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/logo.png', // Ensure this path is correct
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                'Melius Focus',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v32,
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _tabButton(true, 'Log in'),
                    _tabButton(false, 'Sign up'),
                  ],
                ),
              ),
              Gaps.v32,
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'example@example.com',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(v)) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    Gaps.v16,
                    TextFormField(
                      controller: _pwdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'At least 6 characters',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (v.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Gaps.v32,
              // TODO: Implement Forgot Password
              // InkWell(
              //   onTap: () {
              //     // Implement forgot password logic
              //   },
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: const [
              //       Icon(Icons.sentiment_dissatisfied),
              //       SizedBox(width: 8),
              //       Text('Forgot my password'),
              //     ],
              //   ),
              // ),
              // Gaps.v32,
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    // backgroundColor: Theme.of(context).primaryColor, // Example color
                    // foregroundColor: Colors.white,
                  ),
                  child: Text(_isLogin ? 'Log in' : 'Sign up'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(bool loginTab, String title) {
    final selected = _isLogin == loginTab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!_isLoading) { // Prevent switching tabs while loading
            setState(() => _isLogin = loginTab);
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.surface : Colors.transparent, // Use theme colors
            borderRadius: BorderRadius.circular(8),
            border: selected ? Border.all(color: Theme.of(context).colorScheme.primary) : null,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailCtrl.text.trim();
    final password = _pwdCtrl.text.trim();
    final authProvider = Provider.of<app_auth_provider.AuthProvider>(context, listen: false);

    try {
      if (_isLogin) {
        print("Attempting to log in as: $email");
        await authProvider.signInWithEmailAndPassword(email, password);
        print("Login successful for $email (AuthWrapper will navigate)");
      } else {
        print("Attempting to sign up as: $email");
        await authProvider.signUpWithEmailAndPassword(email, password);
        print("Sign up successful for $email (AuthWrapper will navigate)");
        // Optionally, you might want to show a success message before AuthWrapper navigates
        // or switch to the login tab. For now, AuthWrapper handles navigation.
      }
    } catch (e) {
      print("Authentication error type: ${e.runtimeType}");
      print("Authentication error details: $e");

      String dialogMessage;

      if (e is FirebaseException) {
        print("FirebaseException code: ${e.code}, message: ${e.message}");
        // MODIFIED SECTION - START
        if (_isLogin && (e.code == 'invalid-credential' || e.code == 'user-not-found')) {
          // Prioritize 'invalid-credential' as it's what you observed for non-existent user.
          // 'user-not-found' is kept as a fallback.
          dialogMessage = "This account does not exist. Please sign up.";
        } else if (_isLogin && e.code == 'wrong-password') {
          // This case might also be covered by 'invalid-credential' if email enumeration protection is on.
          // If 'invalid-credential' is general, you might prefer a message like:
          // "Invalid email or password. Please try again or sign up."
          dialogMessage = 'Wrong password provided. Please try again.';
          // MODIFIED SECTION - END
        } else if (!_isLogin && e.code == 'email-already-in-use') {
          dialogMessage = 'This email is already in use. Please log in or use a different email.';
        } else if (!_isLogin && e.code == 'weak-password') {
          dialogMessage = 'The password provided is too weak.';
        }
        else {
          // For other Firebase specific errors
          dialogMessage = "Authentication Error [Code: ${e.code}]: ${e.message ?? 'An unexpected Firebase error occurred.'}";
        }
      } else {
        // For non-Firebase exceptions
        dialogMessage = "An unexpected error occurred. Please check your internet connection and app configuration. (Details: $e)";
      }

      if (mounted) {
        await _showErrorDialog(dialogMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }
}
