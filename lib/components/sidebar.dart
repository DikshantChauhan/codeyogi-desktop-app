import 'package:desktop_app/models/sublevel_model.dart';
import 'package:desktop_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_app/providers/sublevel_provider.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  IconData _getIconForSublevelType(Sublevel sublevel) {
    if (sublevel is Video) {
      return Icons.slow_motion_video_rounded;
    } else if (sublevel is Quiz) {
      return Icons.quiz;
    } else if (sublevel is Assignment) {
      return Icons.assignment;
    } else if (sublevel is Notes) {
      return Icons.note;
    } else {
      return Icons.question_mark;
    }
  }

  String _getTitleForSublevel(Sublevel sublevel, int sublevelIndex) {
    if (sublevel is Video) {
      return '${sublevelIndex + 1}. ${sublevel.title}';
    } else if (sublevel is Quiz) {
      return '${sublevelIndex + 1}. Quiz';
    } else if (sublevel is Assignment) {
      return '${sublevelIndex + 1}. Assignment';
    } else if (sublevel is Notes) {
      return '${sublevelIndex + 1}. Notes';
    }
    return '';
  }

  bool _isSublevelLocked(
    String sublevelId,
    String? maxSubLevelId,
    List<String> pathwayOrderIds,
    WidgetRef ref,
  ) {
    if (maxSubLevelId == null) return true;

    final indexOfMaxSubLevel = pathwayOrderIds.indexOf(maxSubLevelId);
    final indexOfCurrentSublevel = pathwayOrderIds.indexOf(sublevelId);

    // only check for just the next sublevel after max sublevel if it's a quiz and answered
    final sublevelState = ref.read(sublevelProvider);
    final maxSublevel = sublevelState.sublevelsMap[maxSubLevelId];
    if (maxSublevel is Quiz &&
        indexOfCurrentSublevel == indexOfMaxSubLevel + 1) {
      final quizData = ref.read(userProvider).quizData;
      if (quizData == null || !quizData.containsKey(maxSubLevelId)) {
        return true;
      }
    }

    // Allow access to max sublevel and the next one
    return indexOfCurrentSublevel > indexOfMaxSubLevel + 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sublevelState = ref.watch(sublevelProvider);
    final userState = ref.watch(userProvider);
    final theme = Theme.of(context);

    return ListView.builder(
      padding: EdgeInsets.only(top: 20),
      itemCount: sublevelState.levelSublevelIdsGroups.length,
      itemBuilder: (_, index) {
        final sublevelIds = sublevelState.levelSublevelIdsGroups[index];
        final sublevels =
            sublevelIds.map((id) => sublevelState.sublevelsMap[id]!).toList();

        final isLevelLocked = _isSublevelLocked(
          sublevelIds.first,
          userState.user?.maxSubLevelId,
          sublevelState.pathwayOrderIds,
          ref,
        );

        final isLevelSelected = userState.user?.currentLevelCount == index + 1;
        if (isLevelSelected) {
          debugPrint('isLevelSelected: ${userState.user?.currentLevelCount}');
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color:
                isLevelSelected
                    ? theme.colorScheme.primaryContainer
                    : isLevelLocked
                    ? theme.colorScheme.surface.withOpacity(0.5)
                    : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border:
                isLevelLocked
                    ? Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    )
                    : isLevelSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 1)
                    : null,
          ),
          child: ExpansionTile(
            leading: Stack(
              children: [
                Icon(
                  Icons.dashboard,
                  color:
                      isLevelSelected
                          ? theme.colorScheme.primary
                          : isLevelLocked
                          ? theme.colorScheme.onSurface.withOpacity(0.38)
                          : theme.colorScheme.primary,
                ),
                if (isLevelLocked)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.38),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Text(
                  'Level ${index + 1}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isLevelSelected
                            ? theme.colorScheme.primary
                            : isLevelLocked
                            ? theme.colorScheme.onSurface.withOpacity(0.38)
                            : null,
                  ),
                ),
                if (isLevelLocked)
                  Container(
                    margin: EdgeInsets.only(left: 8),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Locked',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.38),
                      ),
                    ),
                  ),
              ],
            ),
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            maintainState: true,
            initiallyExpanded: false,
            onExpansionChanged: (expanded) {
              if (isLevelLocked) {
                // Prevent expansion if level is locked
                return;
              }
            },
            children:
                sublevels.asMap().entries.map((entry) {
                  final isSublevelLocked = _isSublevelLocked(
                    sublevelIds[entry.key],
                    userState.user?.maxSubLevelId,
                    sublevelState.pathwayOrderIds,
                    ref,
                  );

                  final isSublevelSelected =
                      userState.user?.currentSubLevelId ==
                      sublevelIds[entry.key];

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          isSublevelSelected
                              ? theme.colorScheme.primaryContainer
                              : isSublevelLocked
                              ? theme.colorScheme.surface.withOpacity(0.5)
                              : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          isSublevelLocked
                              ? Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.3,
                                ),
                                width: 1,
                              )
                              : isSublevelSelected
                              ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 1,
                              )
                              : null,
                    ),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          Icon(
                            _getIconForSublevelType(entry.value),
                            color:
                                isSublevelSelected
                                    ? theme.colorScheme.primary
                                    : isSublevelLocked
                                    ? theme.colorScheme.onSurface.withOpacity(
                                      0.38,
                                    )
                                    : theme.colorScheme.primary,
                          ),
                          if (isSublevelLocked)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lock,
                                  size: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.38),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        _getTitleForSublevel(entry.value, entry.key),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              isSublevelSelected
                                  ? theme.colorScheme.primary
                                  : isSublevelLocked
                                  ? theme.colorScheme.onSurface.withOpacity(
                                    0.38,
                                  )
                                  : null,
                          fontWeight:
                              isSublevelSelected
                                  ? FontWeight.bold
                                  : isSublevelLocked
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                        ),
                      ),
                      trailing:
                          isSublevelLocked
                              ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Locked',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.38),
                                  ),
                                ),
                              )
                              : null,
                      dense: true,
                      visualDensity: VisualDensity(vertical: 0.5),
                      onTap:
                          isSublevelLocked
                              ? null
                              : () {
                                ref
                                    .read(userProvider.notifier)
                                    .setCurrentSublevelChange(
                                      index + 1,
                                      sublevelIds[entry.key],
                                    );
                              },
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}
