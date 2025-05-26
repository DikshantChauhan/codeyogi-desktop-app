import 'package:desktop_app/models/sublevel_model.dart';
import 'package:desktop_app/providers/sublevel_provider.dart';
import 'package:desktop_app/providers/user_provider.dart';
import 'package:desktop_app/components/video_content.dart';
import 'package:desktop_app/components/quiz_content.dart';
import 'package:desktop_app/components/assignment_content.dart';
import 'package:desktop_app/components/notes_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardContentContainer extends ConsumerWidget {
  const DashboardContentContainer({super.key});

  Widget _buildSublevelContent(Sublevel? sublevel) {
    if (sublevel == null) {
      return const Text('No sublevel selected');
    }

    return switch (sublevel) {
      Video() => VideoContent(video: sublevel),
      Quiz() => QuizContent(quiz: sublevel),
      Assignment() => AssignmentContent(assignment: sublevel),
      Notes() => NotesContent(notes: sublevel),
      _ => const Text('Unknown sublevel type'),
    };
  }

  int _getLevelCountForSublevelId(
    String sublevelId,
    SublevelState sublevelData,
  ) {
    for (int i = 0; i < sublevelData.levelSublevelIdsGroups.length; i++) {
      if (sublevelData.levelSublevelIdsGroups[i].contains(sublevelId)) {
        return i + 1;
      }
    }
    return 1; // Default to level 1 if not found
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authData = ref.watch(userProvider);
    final sublevelData = ref.read(sublevelProvider);
    final theme = Theme.of(context);

    final sublevelId = authData.user?.currentSubLevelId;
    final sublevel =
        sublevelId != null ? sublevelData.sublevelsMap[sublevelId] : null;

    // Get current sublevel index
    final currentIndex =
        sublevelId != null
            ? sublevelData.pathwayOrderIds.indexOf(sublevelId)
            : -1;

    // Get next and previous sublevel IDs
    final nextSublevelId =
        currentIndex >= 0 &&
                currentIndex < sublevelData.pathwayOrderIds.length - 1
            ? sublevelData.pathwayOrderIds[currentIndex + 1]
            : null;
    final prevSublevelId =
        currentIndex > 0
            ? sublevelData.pathwayOrderIds[currentIndex - 1]
            : null;

    // Check if current sublevel is a quiz and if it's been answered
    final canNavigateNext = switch (sublevel) {
      Quiz() => authData.quizData?.containsKey(sublevel.id) == true,
      _ => true, // Non-quiz sublevels can always navigate
    };

    return Container(
      color: theme.colorScheme.surface,
      child: Stack(
        children: [
          Center(child: _buildSublevelContent(sublevel)),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prevSublevelId != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(userProvider.notifier)
                          .setCurrentSublevelChange(
                            _getLevelCountForSublevelId(
                              prevSublevelId,
                              sublevelData,
                            ),
                            prevSublevelId,
                          );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                if (nextSublevelId != null)
                  ElevatedButton.icon(
                    onPressed:
                        canNavigateNext
                            ? () {
                              ref
                                  .read(userProvider.notifier)
                                  .setCurrentSublevelChange(
                                    _getLevelCountForSublevelId(
                                      nextSublevelId,
                                      sublevelData,
                                    ),
                                    nextSublevelId,
                                  );
                            }
                            : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
