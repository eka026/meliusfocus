import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/leaderboard_provider.dart';
import 'dart:convert';

class LeaderboardScreen extends StatelessWidget {
  LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeaderboardProvider(),
      child: LeaderboardView(),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TimeFrameChip(
                  label: "Week",
                  selected: provider.currentTimeFrame == TimeFrame.week,
                  onSelected: (_) => provider.setTimeFrame(TimeFrame.week),
                ),
                _TimeFrameChip(
                  label: "Month",
                  selected: provider.currentTimeFrame == TimeFrame.month,
                  onSelected: (_) => provider.setTimeFrame(TimeFrame.month),
                ),
                _TimeFrameChip(
                  label: "All-time",
                  selected: provider.currentTimeFrame == TimeFrame.allTime,
                  onSelected: (_) => provider.setTimeFrame(TimeFrame.allTime),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(child: Text(provider.error!))
                    : provider.users.isEmpty
                        ? const Center(child: Text('No data for this time period'))
                        : ListView.builder(
                            itemCount: provider.users.length,
                            itemBuilder: (context, index) {
                              final user = provider.users[index];
                              final isTopUser = index == 0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "${index + 1}.",
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 12),
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                        radius: 20,
                                        backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                            ? MemoryImage(base64Decode(user.photoUrl!))
                                            : null,
                                        child: user.photoUrl == null || user.photoUrl!.isEmpty
                                            ? Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          isTopUser
                                              ? "👑 ${user.name}"
                                              : user.name,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text("${user.xp} XP"),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _TimeFrameChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool)? onSelected;

  const _TimeFrameChip({
    required this.label,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}
