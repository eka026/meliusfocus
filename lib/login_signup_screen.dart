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
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false; // To show a loading indicator

  // Helper function to show an AlertDialog for errors or info
  Future<void> _showFeedbackDialog(String title, String message) async {
    if (!mounted) return; // Check if the widget is still in the tree
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
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

  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      _showFeedbackDialog('Invalid Email', 'Please enter a valid email address to reset your password.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<app_auth_provider.AuthProvider>(context, listen: false);

    try {
      await authProvider.sendPasswordResetEmail(email);
      if (mounted) {
        _showFeedbackDialog('Password Reset', 'A password reset link has been sent to $email. Please check your inbox (and spam folder).');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for that email. Please check the email address or sign up.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is not valid.";
      }
      // Add more specific Firebase error codes if needed
      print("Forgot Password FirebaseException code: ${e.code}, message: ${e.message}");
      if (mounted) {
        _showFeedbackDialog('Password Reset Error', errorMessage);
      }
    } catch (e) {
      print("Forgot Password error: $e");
      if (mounted) {
        _showFeedbackDialog('Password Reset Error', 'An unexpected error occurred. Please try again later.');
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
              Text(
                'Melius Focus',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Gaps.v32,
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _firstNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (!_isLogin && (v == null || v.isEmpty)) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      Gaps.v16,
                      TextFormField(
                        controller: _lastNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (!_isLogin && (v == null || v.isEmpty)) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      Gaps.v16,
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (!_isLogin && (v == null || v.isEmpty)) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      Gaps.v16,
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (!_isLogin && (v == null || v.isEmpty)) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      Gaps.v16,
                    ],
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
                        if (_isLogin) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter your password';
                          }
                        } else {
                          if (v == null || v.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              Gaps.v16, // Adjusted spacing
              // Forgot Password Button
              if (_isLogin) // Show only on the login tab
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _handleForgotPassword,
                    child: const Text('Forgot my password?'),
                  ),
                ),
              Gaps.v16, // Adjusted spacing
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
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
            setState(() {
              _isLogin = loginTab;
              _formKey.currentState?.reset(); // Reset form validation errors when switching tabs
              // _pwdCtrl.clear(); // Optionally clear password on tab switch
            });
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
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
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
        await authProvider.signUpWithEmailAndPassword(
          email,
          password,
          _firstNameCtrl.text.trim(),
          _lastNameCtrl.text.trim(),
          _usernameCtrl.text.trim(),
          _phoneCtrl.text.trim(),
        );
        print("Sign up successful for $email (AuthWrapper will navigate)");
      }
    } catch (e) {
      print("Authentication error type: ${e.runtimeType}");
      print("Authentication error details: $e");

      String dialogMessage;
      String dialogTitle = 'Authentication Error';

      if (e is FirebaseException) {
        print("FirebaseException code: ${e.code}, message: ${e.message}");
        if (_isLogin && (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password')) {
          dialogMessage = "Invalid email or password. Please try again, or use 'Forgot my password?' if you've forgotten your credentials.";
        } else if (!_isLogin && e.code == 'email-already-in-use') {
          dialogMessage = 'This email is already in use. Please log in or use a different email.';
        } else if (!_isLogin && e.code == 'weak-password') {
          dialogMessage = 'The password provided is too weak. It must be at least 6 characters.';
        } else if (e.code == 'invalid-email') {
          dialogMessage = "The email address is badly formatted.";
        } else {
          dialogMessage = "An unexpected Firebase error occurred. [Code: ${e.code}]";
        }
      } else {
        dialogMessage = "An unexpected error occurred. Please check your internet connection and try again.";
      }

      if (mounted) {
        _showFeedbackDialog(dialogTitle, dialogMessage);
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
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }
}