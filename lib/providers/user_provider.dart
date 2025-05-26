import 'package:desktop_app/models/user_model.dart';
import 'package:desktop_app/services/local_storage.service.dart';
import 'package:desktop_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_app/providers/sublevel_provider.dart';
import 'package:desktop_app/services/sync.service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

//Analogy: Slice in Redux tool kit
class AuthData {
  final AuthState authState;
  final User? user;
  final String? errorMessage;
  final Map<String, int>? quizData;

  AuthData({
    required this.authState,
    this.user,
    this.errorMessage,
    this.quizData,
  });

  factory AuthData.initial() => AuthData(authState: AuthState.initial);
  factory AuthData.loading() => AuthData(authState: AuthState.loading);
  factory AuthData.unauthenticated() =>
      AuthData(authState: AuthState.unauthenticated, user: null);
  factory AuthData.error(String message) =>
      AuthData(authState: AuthState.error, errorMessage: message);
  factory AuthData.authenticatedWithQuizData(
    User user,
    Map<String, int> quizData,
  ) => AuthData(
    authState: AuthState.authenticated,
    user: user,
    quizData: quizData,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthData &&
        other.authState == authState &&
        other.user == user &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      authState.hashCode ^ user.hashCode ^ (errorMessage?.hashCode ?? 0);
}

//Analogy: saga in Redux
class UserNotifier extends StateNotifier<AuthData> {
  final Ref ref;

  UserNotifier(this.ref) : super(AuthData.initial());

  Future<void> initialize() async {
    try {
      final currentUserId =
          await localStorageService.getCurrentLoggedInUserId();
      if (currentUserId != null) {
        final user = await localStorageService.getUser(currentUserId);
        final quizData = await localStorageService.getUserQuizData(
          currentUserId,
        );
        if (user != null) {
          state = AuthData.authenticatedWithQuizData(user, quizData);
        } else {
          state = AuthData.unauthenticated();
        }
      } else {
        state = AuthData.unauthenticated();
      }
    } catch (e) {
      debugPrint(e.toString());
      state = AuthData.error(e.toString());
    }
  }

  Future<void> login(String name, String password, bool isGuest) async {
    state = AuthData.loading();
    try {
      if (isGuest) {
        final localUsers = await localStorageService.getUsersMap();
        final user = localUsers.values.firstWhere(
          (user) => user.name == name && user.password == password,
          orElse: () => throw Exception('User not found or wrong credentials'),
        );

        await localStorageService.setCurrentLoggedInUserId(user.id);
        final quizData = await localStorageService.getUserQuizData(user.id);
        state = AuthData.authenticatedWithQuizData(user, quizData);
      } else {
        throw Exception('Implement login with email and password on database');
      }
    } catch (e) {
      state = AuthData.error(e.toString());
    }
  }

  Future<void> register(String name, String password, bool isGuest) async {
    state = AuthData.loading();
    try {
      if (isGuest) {
        final localUsers = await localStorageService.getUsersMap();
        final existingUser = localUsers.values.where(
          (user) => user.name == name,
        );

        if (existingUser.isNotEmpty) {
          throw Exception('User already exists');
        }

        final firstPathwayId = ref.read(sublevelProvider).pathwayOrderIds.first;
        final user = User(
          id: randomId(),
          name: name,
          password: password,
          isGuest: isGuest,
          currentLevelCount: 1,
          currentSubLevelId: firstPathwayId,
          maxLevelCount: 1,
          maxSubLevelId: firstPathwayId,
        );

        await localStorageService.addUser(user);
        await localStorageService.setCurrentLoggedInUserId(user.id);
        final quizData = await localStorageService.getUserQuizData(user.id);
        state = AuthData.authenticatedWithQuizData(user, quizData);
      } else {
        throw Exception(
          'Implement register with email and password on database',
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      state = AuthData.error(e.toString());
    }
  }

  Future<void> logout() async {
    state = AuthData.loading();
    try {
      await localStorageService.setCurrentLoggedInUserId(null);
      state = AuthData.unauthenticated();
    } catch (e) {
      state = AuthData.error(e.toString());
    }
  }

  AuthState getAuthStatus() {
    return state.authState;
  }

  User? getUser() {
    return state.user;
  }

  setCurrentSublevelChange(int levelCount, String sublevelId) {
    final user = state.user!;
    final currentMaxSubLevelId = user.maxSubLevelId!;
    final pathwayOrderIds = ref.read(sublevelProvider).pathwayOrderIds;

    final indexOfCurrentMaxSubLevel = pathwayOrderIds.indexOf(
      currentMaxSubLevelId,
    );
    final indexOfRequestedSubLevel = pathwayOrderIds.indexOf(sublevelId);

    final isNewMaxSubLevel =
        indexOfRequestedSubLevel > indexOfCurrentMaxSubLevel;

    state = AuthData.authenticatedWithQuizData(
      state.user!.copyWith(
        currentLevelCount: levelCount,
        currentSubLevelId: sublevelId,
        maxLevelCount: isNewMaxSubLevel ? levelCount : user.maxLevelCount,
        maxSubLevelId: isNewMaxSubLevel ? sublevelId : currentMaxSubLevelId,
      ),
      state.quizData ?? {},
    );

    localStorageService.updateUser(state.user!);
  }

  Future<void> setQuizData(String quizId, int pickedAnswerIndex) async {
    final user = state.user!;
    final updatedQuizData = {...state.quizData!, quizId: pickedAnswerIndex};

    state = AuthData.authenticatedWithQuizData(user, updatedQuizData);
    await localStorageService.setQuizData(user.id, quizId, pickedAnswerIndex);
  }

  Future<void> syncToBackend() async {
    try {
      await syncService.syncToBackend();
    } catch (e) {
      debugPrint('Error syncing to backend: $e');
      state = AuthData.error(e.toString());
    }
  }

  Future<void> syncFromBackend() async {
    try {
      await syncService.syncFromBackend();
    } catch (e) {
      debugPrint('Error syncing from backend: $e');
      state = AuthData.error(e.toString());
    }
  }
}

//Analogy: Selector in Redux
final userProvider = StateNotifierProvider<UserNotifier, AuthData>((ref) {
  return UserNotifier(ref);
});
