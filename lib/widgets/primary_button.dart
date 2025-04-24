// lib/widgets/primary_button.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PrimaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(180, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
