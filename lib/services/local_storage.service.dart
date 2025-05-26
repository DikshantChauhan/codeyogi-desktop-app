import 'dart:convert';
import 'package:desktop_app/models/user_model.dart'; // Assuming user_model.dart exists and is correct
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

enum LocalStorageKeys { users, currentLoggedInUserId, quizData }

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    if (!_prefs.containsKey(LocalStorageKeys.users.toString())) {
      debugPrint('Initializing users');
      await _prefs.setString(LocalStorageKeys.users.toString(), '{}');
    }

    if (!_prefs.containsKey(LocalStorageKeys.quizData.toString())) {
      debugPrint('Initializing quiz data');
      await _prefs.setString(LocalStorageKeys.quizData.toString(), '{}');
    }
  }

  Future<void> _savePreference(LocalStorageKeys key, String value) async {
    await _prefs.setString(key.toString(), value);
  }

  Future<void> _removePreference(LocalStorageKeys key) async {
    await _prefs.remove(key.toString());
  }

  Future<String?> _readPreference(LocalStorageKeys key) async {
    return _prefs.getString(key.toString());
  }

  Future<void> updateUser(User user) async {
    final usersMap = await getUsersMap();

    if (!usersMap.containsKey(user.id)) {
      throw Exception('User not found');
    }

    usersMap[user.id] = user;

    await _savePreference(
      LocalStorageKeys.users,
      _getUsersSaveableString(usersMap),
    );
  }

  Future<void> addUser(User user) async {
    final usersMap = await getUsersMap();

    if (usersMap.containsKey(user.id)) {
      throw Exception('User already exists');
    }

    usersMap[user.id] = user;

    await _savePreference(
      LocalStorageKeys.users,
      _getUsersSaveableString(usersMap),
    );
  }

  String _getUsersSaveableString(Map<String, User> map) {
    final encodedableUsersMap = map.map(
      (key, value) => MapEntry(key, value.toMap()),
    );
    return jsonEncode(encodedableUsersMap);
  }

  Future<Map<String, User>> getUsersMap() async {
    final usersString = await _readPreference(LocalStorageKeys.users);
    final Map<String, dynamic> decodedMap =
        usersString != null ? jsonDecode(usersString) : {};

    final Map<String, User> users = {};

    decodedMap.forEach((key, value) {
      users[key] = User.fromMap(value as Map<String, dynamic>);
    });
    return users;
  }

  Future<User?> getUser(String id) async {
    final usersMap = await getUsersMap();
    return usersMap[id];
  }

  Future<void> deleteUser(String id) async {
    final usersMap = await getUsersMap();
    usersMap.remove(id);

    await _savePreference(
      LocalStorageKeys.users,
      _getUsersSaveableString(usersMap),
    );
  }

  Future<void> setCurrentLoggedInUserId(String? id) async {
    if (id == null) {
      await _removePreference(LocalStorageKeys.currentLoggedInUserId);
    } else {
      await _savePreference(LocalStorageKeys.currentLoggedInUserId, id);
    }
  }

  Future<String?> getCurrentLoggedInUserId() async {
    return _readPreference(LocalStorageKeys.currentLoggedInUserId);
  }

  Future<Map<String, Map<String, int>>> _getQuizData() async {
    final quizDataString = await _readPreference(LocalStorageKeys.quizData);
    final decodedData =
        jsonDecode(quizDataString ?? '{}') as Map<String, dynamic>;

    return decodedData.map(
      (key, value) => MapEntry(
        key,
        (value as Map<String, dynamic>).map(
          (innerKey, innerValue) => MapEntry(
            innerKey,
            innerValue is int ? innerValue : int.parse(innerValue.toString()),
          ),
        ),
      ),
    );
  }

  Future<void> setQuizData(
    String userId,
    String quizId,
    int pickedAnswerIndex,
  ) async {
    final quizData = await _getQuizData();
    final userQuizData = quizData[userId] ?? {};
    userQuizData[quizId] = pickedAnswerIndex;
    quizData[userId] = userQuizData;
    await _savePreference(LocalStorageKeys.quizData, jsonEncode(quizData));
  }

  Future<Map<String, int>> getUserQuizData(String userId) async {
    final quizData = await _getQuizData();
    return quizData[userId] ?? {};
  }
}

final localStorageService = LocalStorageService();
