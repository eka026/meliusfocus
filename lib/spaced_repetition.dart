import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// SpacedRepetitionScreen is registered in main.dart under '/spaced_repetition'.
class SpacedRepetitionScreen extends StatefulWidget {
  const SpacedRepetitionScreen({Key? key}) : super(key: key);

  @override
  State<SpacedRepetitionScreen> createState() => _SpacedRepetitionScreenState();
}

class _SpacedRepetitionScreenState extends State<SpacedRepetitionScreen> {
  final TextEditingController _controller = TextEditingController();

  /// List of topics with a due date or description
  final List<String> _topics = [
    'CS310 - Widgets',
    'CS306 - Relational Algebra',
    'CS307 - Scheduling',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addTopicToFirestore(String topicName) async {
    if (topicName.trim().isEmpty) {
      print('Topic name is empty.');
      return;
    }
    final userId = FirebaseAuth.instance.currentUser?.uid;
    print('Current userId: $userId');
    if (userId == null) {
      print('User not logged in!');
      return;
    }
    final topicsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('topics');
    print('About to add topic: $topicName');
    try {
      await topicsRef.add({
        'topicName': topicName.trim(),
        'phase': 'learning',
        'stepIndex': 0,
        'interval': 1.0,
        'ease': 2.3,
        'dueDate': DateTime.now().toIso8601String(),
        'lastInterval': 0.0,
      });
      print('Topic added successfully!');
    } catch (e) {
      print('Error adding topic: $e');
    }
  }

  void _addTopic(String title) async {
    await _addTopicToFirestore(title);
    _controller.clear();
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Topic added!')),
    );
  }

  void _manageTopics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.5, // reduced height for a smaller popup
          child: const _FirestoreTopicManager(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Spaced Repetition'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter a topic you studied:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Please enter your topic here...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _addTopic(_controller.text),
                  ),
                ),
                onSubmitted: _addTopic,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Topics you need to review...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Topics',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'Due',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Review list or placeholder if empty
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: (() {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId == null) {
                      // Return an empty stream if not logged in
                      return const Stream<QuerySnapshot>.empty();
                    }
                    return FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('topics')
                        .where('dueDate', isLessThanOrEqualTo: DateTime.now().toIso8601String())
                        .snapshots();
                  })(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No topics to review.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }
                    final docs = snapshot.data!.docs;
                    return ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final title = data['topicName'] ?? '';
                        final dueDate = data['dueDate'] ?? '';
                        final docRef = docs[index].reference;
                        return InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => _ReviewBottomSheet(
                                topicTitle: title,
                                onReview: (rating) => _reviewTopic(docRef, rating),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(child: Text(title)),
                                Text(
                                  dueDate.isNotEmpty
                                      ? dueDate.split('T').first
                                      : '—',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Manage topics action
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _manageTopics,
                    child: const Text('Manage the topics'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reviewTopic(DocumentReference docRef, String rating) async {
    // Fetch the topic data
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;
    final data = docSnap.data() as Map<String, dynamic>;

    // SM-2 parameters
    double ease = (data['ease'] ?? 2.3).toDouble();
    double interval = (data['interval'] ?? 1.0).toDouble();
    String phase = data['phase'] ?? 'learning';
    int stepIndex = data['stepIndex'] ?? 0;
    double lastInterval = (data['lastInterval'] ?? 0.0).toDouble();
    DateTime now = DateTime.now();
    DateTime dueDate = DateTime.tryParse(data['dueDate'] ?? '') ?? now;

    // Learning phase steps (customize as needed)
    final learningSteps = [Duration(minutes: 30), Duration(hours: 2), Duration(days: 2)];
    final easyBonus = 1.3;
    final minEase = 1.3;
    final lapseIntervalMultiplier = 0.1;
    final intervalMultiplier = 1.0;

    if (phase == 'learning') {
      if (rating == 'forgot') {
        stepIndex = 0;
        dueDate = now.add(learningSteps[0]);
      } else if (rating == 'partial') {
        // Stay on same step, show again at half the time to next step
        final nextStep = (stepIndex + 1 < learningSteps.length)
            ? learningSteps[stepIndex + 1]
            : learningSteps.last;
        dueDate = now.add(Duration(seconds: (nextStep.inSeconds / 2).round()));
      } else if (rating == 'effort') {
        // Move to next step
        if (stepIndex + 1 < learningSteps.length) {
          stepIndex++;
          dueDate = now.add(learningSteps[stepIndex]);
        } else {
          // Enter exponential phase
          phase = 'exponential';
          interval = learningSteps.last.inDays.toDouble();
          dueDate = now.add(Duration(days: interval.round()));
        }
      } else if (rating == 'easy') {
        // Enter exponential phase with easy bonus
        phase = 'exponential';
        interval = learningSteps.last.inDays.toDouble() * easyBonus;
        ease += 0.15;
        dueDate = now.add(Duration(days: interval.round()));
      }
    } else if (phase == 'exponential') {
      if (rating == 'forgot') {
        ease = (ease - 0.2).clamp(minEase, double.infinity);
        interval = interval * lapseIntervalMultiplier;
        phase = 'relearning';
        stepIndex = 0;
        lastInterval = interval;
        dueDate = now.add(learningSteps[0]);
      } else if (rating == 'partial') {
        ease = (ease - 0.15).clamp(minEase, double.infinity);
        interval = interval * 1.2 * intervalMultiplier;
        dueDate = now.add(Duration(days: interval.round()));
      } else if (rating == 'effort') {
        interval = interval * ease * intervalMultiplier;
        dueDate = now.add(Duration(days: interval.round()));
      } else if (rating == 'easy') {
        ease += 0.15;
        interval = interval * ease * easyBonus * intervalMultiplier;
        dueDate = now.add(Duration(days: interval.round()));
      }
    } else if (phase == 'relearning') {
      if (rating == 'forgot') {
        stepIndex = 0;
        dueDate = now.add(learningSteps[0]);
      } else if (rating == 'partial') {
        final nextStep = (stepIndex + 1 < learningSteps.length)
            ? learningSteps[stepIndex + 1]
            : learningSteps.last;
        dueDate = now.add(Duration(seconds: (nextStep.inSeconds / 2).round()));
      } else if (rating == 'effort') {
        if (stepIndex + 1 < learningSteps.length) {
          stepIndex++;
          dueDate = now.add(learningSteps[stepIndex]);
        } else {
          // Back to exponential phase
          phase = 'exponential';
          interval = lastInterval * lapseIntervalMultiplier;
          dueDate = now.add(Duration(days: interval.round()));
        }
      } else if (rating == 'easy') {
        phase = 'exponential';
        interval = lastInterval * lapseIntervalMultiplier * easyBonus;
        ease += 0.15;
        dueDate = now.add(Duration(days: interval.round()));
      }
    }

    // Update Firestore
    await docRef.update({
      'ease': ease,
      'interval': interval,
      'phase': phase,
      'stepIndex': stepIndex,
      'lastInterval': lastInterval,
      'dueDate': dueDate.toIso8601String(),
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review recorded: $rating')),
      );
    }
  }
}

// Replace _TopicManager with Firestore-based manager
class _FirestoreTopicManager extends StatelessWidget {
  const _FirestoreTopicManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text('Not logged in.'));
    }
    final topicsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('topics');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Manage Topics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: topicsRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No topics to manage.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final title = data['topicName'] ?? '';
                      return ListTile(
                        title: Text(title),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await docs[i].reference.delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Topic deleted!')),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add the bottom sheet widget for review buttons
class _ReviewBottomSheet extends StatelessWidget {
  final String topicTitle;
  final void Function(String rating) onReview;
  const _ReviewBottomSheet({required this.topicTitle, required this.onReview});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review: $topicTitle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onReview('forgot');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Forgot'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onReview('partial');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Partially recalled'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onReview('effort');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Recalled with effort'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onReview('easy');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Theme.of(context).colorScheme.onTertiary,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Easily recalled'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
