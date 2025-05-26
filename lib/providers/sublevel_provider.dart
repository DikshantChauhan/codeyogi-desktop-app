import 'dart:convert';

import 'package:desktop_app/models/sublevel_model.dart';
import 'package:desktop_app/utils.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SublevelState {
  final List<String> pathwayOrderIds;
  final Map<String, Sublevel> sublevelsMap;
  final List<List<String>> levelSublevelIdsGroups;
  final bool isLoading;
  final String? error;

  SublevelState({
    this.pathwayOrderIds = const [],
    this.sublevelsMap = const {},
    this.levelSublevelIdsGroups = const [],
    this.isLoading = false,
    this.error,
  });

  SublevelState copyWith({
    List<String>? pathwayOrderIds,
    Map<String, Sublevel>? sublevelsMap,
    List<List<String>>? levelSublevelIdsGroups,
    bool? isLoading,
    String? error,
  }) {
    return SublevelState(
      pathwayOrderIds: pathwayOrderIds ?? this.pathwayOrderIds,
      sublevelsMap: sublevelsMap ?? this.sublevelsMap,
      levelSublevelIdsGroups:
          levelSublevelIdsGroups ?? this.levelSublevelIdsGroups,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SublevelNotifier extends StateNotifier<SublevelState> {
  SublevelNotifier() : super(SublevelState());

  Future<void> initialize() async {
    try {
      state = state.copyWith(isLoading: true);

      //fetch pathway file and parse it
      final pathwayJson = await rootBundle.loadString(pathwayJsonPath);
      final List<dynamic> pathwayOrderDynamic = jsonDecode(pathwayJson);
      final List<String> pathwayOrder =
          pathwayOrderDynamic.map((e) => e.toString()).toList();

      //loop throught each pathway and load the sublevels and set them in the state
      for (final pathwayId in pathwayOrder) {
        final sublevelJson = await rootBundle.loadString(
          getSublevelJsonPath(pathwayId),
        );
        final sublevel = Sublevel.fromJson(jsonDecode(sublevelJson), pathwayId);

        state = state.copyWith(
          sublevelsMap: {...state.sublevelsMap, pathwayId: sublevel},
        );

        final isVideoType = sublevel.type == 'video';

        if (isVideoType) {
          state = state.copyWith(
            levelSublevelIdsGroups: [
              ...state.levelSublevelIdsGroups,
              [pathwayId],
            ],
          );
        } else {
          final lastGroup = state.levelSublevelIdsGroups.last;
          final newGroups = [...state.levelSublevelIdsGroups];
          newGroups[newGroups.length - 1] = [...lastGroup, pathwayId];
          state = state.copyWith(levelSublevelIdsGroups: newGroups);
        }
      }

      //set the pathway order ids in the state
      state = state.copyWith(pathwayOrderIds: pathwayOrder, isLoading: false);
    } on Exception catch (e) {
      debugPrint("Error loading sublevels: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final sublevelProvider = StateNotifierProvider<SublevelNotifier, SublevelState>(
  (ref) {
    return SublevelNotifier();
  },
);
