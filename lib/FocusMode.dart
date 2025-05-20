// lib/FocusMode.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/focus_mode_provider.dart'; // Adjust path if needed

class FocusModeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    final focusProvider = context.watch<FocusModeProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusProvider.feedbackMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(focusProvider.feedbackMessage!)),
        );
        focusProvider.clearFeedbackMessage(); // Clear message after showing
      }
    });

    void showTimePickerSheet() async {
      if (focusProvider.isRunning) return;
      int selectedMinutes = focusProvider.remainingMinutes;
      await showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Set Timer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: selectedMinutes > FocusModeProvider.MIN_TIME_MINUTES
                              ? () => setState(() => selectedMinutes -= 5)
                              : null,
                          iconSize: 36,
                        ),
                        SizedBox(width: 24),
                        Text(
                          '$selectedMinutes min',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 24),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: selectedMinutes < FocusModeProvider.MAX_TIME_MINUTES
                              ? () => setState(() => selectedMinutes += 5)
                              : null,
                          iconSize: 36,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (selectedMinutes != focusProvider.remainingMinutes) {
                      context.read<FocusModeProvider>().setTime(selectedMinutes);
                    }
                  },
                  child: Text('Set'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Focus Mode')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: focusProvider.isRunning ? null : showTimePickerSheet,
              child: Text(
                focusProvider.formattedTime,
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Focus Time 📚',
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  onPressed: focusProvider.isRunning
                      ? null
                      : () => context.read<FocusModeProvider>().startTimer(context),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.stop),
                  onPressed: !focusProvider.isRunning
                      ? null
                      : () => context.read<FocusModeProvider>().stopTimer(context),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  onPressed: () => context.read<FocusModeProvider>().resetTimer(context),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}