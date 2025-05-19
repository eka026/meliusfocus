// lib/FocusMode.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/focus_mode_provider.dart'; // Adjust path if needed

class FocusModeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the providers
    // context.watch<T>() makes the widget rebuild when T notifies listeners.
    final focusProvider = context.watch<FocusModeProvider>();

    // Listen for feedback messages from the providers to show Snackbars
    // This is a common pattern to decouple UI feedback from providers logic.
    // We use a post-frame callback to avoid calling setState during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusProvider.feedbackMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(focusProvider.feedbackMessage!)),
        );
        focusProvider.clearFeedbackMessage(); // Clear message after showing
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Focus Mode')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              isSelected: [
                focusProvider.mode == 'Pomodoro',
                focusProvider.mode == 'Long Study'
              ],
              onPressed: (index) {
                // Use context.read<T>() for calls inside callbacks (not rebuilding widget)
                context
                    .read<FocusModeProvider>()
                    .setMode(index == 0 ? 'Pomodoro' : 'Long Study');
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Pomodoro'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Long Study'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              focusProvider.formattedTime,
              style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: focusProvider.isBreak
                      ? Colors.green.shade700
                      : Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              focusProvider.currentPhaseText,
              style: TextStyle(
                  fontSize: 24,
                  color: focusProvider.isBreak
                      ? Colors.green.shade700
                      : Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  onPressed: focusProvider.isRunning
                      ? null
                      : () => context.read<FocusModeProvider>().startTimer(),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.stop),
                  onPressed: !focusProvider.isRunning
                      ? null
                      : () => context.read<FocusModeProvider>().stopTimer(),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  onPressed: () => context.read<FocusModeProvider>().resetTimer(),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}