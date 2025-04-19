import 'package:flutter/material.dart';
import 'dart:async';

class FocusModeScreen extends StatefulWidget {
  @override
  _FocusModeScreenState createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isBreak = false;

  String _mode = 'Pomodoro'; // Default mode

  void _setMode(String selectedMode) {
    setState(() {
      _mode = selectedMode;
      _isBreak = false;
      _resetTimer();
    });
  }

  void _startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _isRunning = false;

          if (_mode == 'Pomodoro') {
            _isBreak = !_isBreak;
            _remainingSeconds = _isBreak ? 5 * 60 : 25 * 60;
            _startTimer(); // Automatically start break or work cycle
          }
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _isRunning = false;

    setState(() {
      if (_mode == 'Pomodoro') {
        _remainingSeconds = _isBreak ? 5 * 60 : 25 * 60;
      } else {
        _remainingSeconds = 50 * 60;
      }
    });
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Focus Mode')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              isSelected: [_mode == 'Pomodoro', _mode == 'Long Study'],
              onPressed: (index) {
                _setMode(index == 0 ? 'Pomodoro' : 'Long Study');
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
              _formatTime(_remainingSeconds),
              style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _startTimer,
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: _stopTimer,
                  child: const Text('Stop'),
                ),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_mode == 'Pomodoro')
              Text(
                _isBreak ? 'Break Time 🍵' : 'Focus Time 📚',
                style: TextStyle(fontSize: 20),
              ),
          ],
        ),
      ),
    );
  }
}
