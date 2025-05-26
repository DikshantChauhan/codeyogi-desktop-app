import 'dart:convert';
import 'package:desktop_app/models/user_model.dart';
import 'package:desktop_app/services/local_storage.service.dart';
import 'package:http/http.dart' as http;

class SyncService {
  final String baseUrl;
  final LocalStorageService _localStorage;

  SyncService({required this.baseUrl, LocalStorageService? localStorage})
    : _localStorage = localStorage ?? localStorageService;

  Future<Map<String, dynamic>> _prepareSyncData() async {
    // Get current logged in user
    final currentUserId = await _localStorage.getCurrentLoggedInUserId();
    if (currentUserId == null) {
      throw Exception('No user is currently logged in');
    }

    final currentUser = await _localStorage.getUser(currentUserId);
    if (currentUser == null) {
      throw Exception('Current user not found');
    }

    final currentUserQuizData = await _localStorage.getUserQuizData(
      currentUserId,
    );

    // Get all users for "others" data
    final allUsers = await _localStorage.getUsersMap();
    final otherUsers = allUsers.entries
        .where((entry) => entry.key != currentUserId)
        .map((entry) async {
          final quizData = await _localStorage.getUserQuizData(entry.key);
          return {'user': entry.value.toMap(), 'quizData': quizData};
        });

    final othersData = await Future.wait(otherUsers);

    return {
      'me': {'user': currentUser.toMap(), 'quizData': currentUserQuizData},
      'others': othersData,
    };
  }

  Future<void> syncToBackend() async {
    try {
      final syncData = await _prepareSyncData();

      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(syncData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to sync data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error syncing data: $e');
    }
  }

  Future<void> syncFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sync'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch data: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Handle the synced data
      // TODO: Implement data handling logic based on backend response structure
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}

final syncService = SyncService(
  baseUrl: 'YOUR_BACKEND_API_URL', // Replace with your actual backend URL
);
