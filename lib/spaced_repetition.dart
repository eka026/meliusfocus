import 'package:flutter/material.dart';

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

  void _addTopic(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      _topics.add(title.trim());
    });
    _controller.clear();
  }

  void _manageTopics() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.5, // reduced height for a smaller popup
          child: _TopicManager(
            topics: List.from(_topics),
            onUpdate: (updated) {
              setState(() {
                _topics
                  ..clear()
                  ..addAll(updated);
              });
            },
          ),
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
                child: _topics.isEmpty
                    ? const Center(
                  child: Text(
                    'No topics to review.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.separated(
                  itemCount: _topics.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, index) {
                    final title = _topics[index];
                    return Row(
                      children: [
                        // bullet
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
                        const Text('—'), // placeholder for due info
                      ],
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
}

/// A simple bottom sheet to edit or delete topics
class _TopicManager extends StatefulWidget {
  final List<String> topics;
  final ValueChanged<List<String>> onUpdate;
  const _TopicManager({required this.topics, required this.onUpdate});

  @override
  State<_TopicManager> createState() => _TopicManagerState();
}

class _TopicManagerState extends State<_TopicManager> {
  late List<String> _editable;

  @override
  void initState() {
    super.initState();
    _editable = List.from(widget.topics);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Manage Topics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Placeholder if no topics to manage
            _editable.isEmpty
                ? const Expanded(
              child: Center(
                child: Text(
                  'No topics to manage.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
                : Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _editable.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    title: TextFormField(
                      initialValue: _editable[i],
                      onChanged: (val) => _editable[i] = val,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => _editable.removeAt(i)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                widget.onUpdate(_editable);
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
