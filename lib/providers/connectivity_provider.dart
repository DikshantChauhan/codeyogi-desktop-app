import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

@immutable
class InternetState {
  final bool hasInternet;
  final bool isInitialized;

  const InternetState({
    this.hasInternet = false, // Default values
    this.isInitialized = false, // Default values
  });

  // Helper method to create a copy with updated values
  InternetState copyWith({bool? hasInternet, bool? isInitialized}) {
    return InternetState(
      hasInternet: hasInternet ?? this.hasInternet,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InternetState &&
          runtimeType == other.runtimeType &&
          hasInternet == other.hasInternet &&
          isInitialized == other.isInitialized;

  @override
  int get hashCode => hasInternet.hashCode ^ isInitialized.hashCode;

  @override
  String toString() {
    return 'InternetState(hasInternet: $hasInternet, isInitialized: $isInitialized)';
  }
}

class InternetNotifier extends StateNotifier<InternetState> {
  final InternetConnection _internetConnection = InternetConnection();
  StreamSubscription<InternetStatus>? _subscription; // Make nullable

  // Initialize with the default state
  InternetNotifier() : super(const InternetState()) {
    _initialize(); // Start initialization
  }

  Future<void> _initialize() async {
    // Get initial status right away
    final bool initialConnection = await _internetConnection.hasInternetAccess;
    // Update state only if component is still mounted and values differ
    if (mounted) {
      state = InternetState(
        hasInternet: initialConnection,
        isInitialized: true,
      );
      //debugPrint("Initialized Internet State: $state"); // Debug log
    } else {
      return; // Avoid updating state if notifier is already disposed
    }

    // Subscribe to listen for future changes
    _subscription = _internetConnection.onStatusChange.listen(
      (InternetStatus status) {
        final bool currentlyHasInternet = (status == InternetStatus.connected);
        //debugPrint(
        //  "Internet Status Stream: $status -> HasInternet: $currentlyHasInternet",
        //); // Debug log

        // Check if mounted and if the value actually changed before updating state
        if (mounted && state.hasInternet != currentlyHasInternet) {
          state = state.copyWith(
            hasInternet: currentlyHasInternet,
            isInitialized: true,
          );
          //debugPrint("Updated Internet State: $state"); // Debug log
        }
      },
      onError: (e) {
        // Handle potential errors from the stream
        //debugPrint("Error in internet status stream: $e");
        if (mounted && state.hasInternet) {
          state = state.copyWith(
            hasInternet: false,
            isInitialized: true,
          ); // Assume disconnected on error
        }
      },
    );
  }

  // Method to trigger a manual check
  Future<void> checkNow() async {
    if (!mounted) return; // Don't do anything if disposed
    state = state.copyWith(isInitialized: false); // Indicate checking
    final bool currentStatus = await _internetConnection.hasInternetAccess;
    if (mounted) {
      state = InternetState(
        hasInternet: currentStatus,
        isInitialized: true,
      ); // Set final state
    }
  }

  // Dispose method is called automatically by Riverpod
  @override
  void dispose() {
    //debugPrint(
    //  "Disposing InternetNotifier and cancelling subscription.",
    //); // Debug log
    _subscription?.cancel(); // Cancel the subscription
    super.dispose();
  }
}

// 2. Define the StateNotifierProvider (global instance)
final internetNotifierProvider =
    StateNotifierProvider<InternetNotifier, InternetState>((ref) {
      return InternetNotifier();
    });
