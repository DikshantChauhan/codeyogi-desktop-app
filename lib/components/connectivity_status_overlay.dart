import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_app/providers/connectivity_provider.dart';

class ConnectivityStatusOverlay extends ConsumerStatefulWidget {
  const ConnectivityStatusOverlay({super.key});

  @override
  ConsumerState<ConnectivityStatusOverlay> createState() =>
      _ConnectivityStatusOverlayState();
}

class _ConnectivityStatusOverlayState
    extends ConsumerState<ConnectivityStatusOverlay> {
  Timer? _onlineBannerTimer;
  bool _showOnlineBanner = false;
  bool _offlineBannerDismissed = false;

  @override
  void dispose() {
    _onlineBannerTimer?.cancel();
    super.dispose();
  }

  void _dismissBanner() {
    _onlineBannerTimer?.cancel();
    setState(() {
      _showOnlineBanner = false;
      _offlineBannerDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Call ref.listen directly in the build method.
    // Riverpod manages the subscription lifecycle.
    ref.listen<InternetState>(internetNotifierProvider, (
      InternetState? previousState,
      InternetState newState,
    ) {
      // This callback is executed when the InternetState changes.
      // It's safe to call setState here to update local UI state (_showOnlineBanner).

      if (!mounted)
        return; // Ensure widget is still mounted before calling setState

      if (!newState.isInitialized) {
        // If state becomes uninitialized (e.g., during a re-check),
        // ensure the "online" banner is hidden.
        if (_showOnlineBanner) {
          setState(() {
            _showOnlineBanner = false;
          });
        }
        return;
      }

      // At this point, newState.isInitialized is true.
      final bool isNowConnected = newState.hasInternet;

      // Determine if the previous state was effectively connected.
      // If previousState is null (first time listener runs for an initialized state),
      // or if it wasn't initialized, or if it had no internet, it was not "effectively connected".
      final bool wasEffectivelyConnected =
          (previousState?.isInitialized ?? false) &&
          (previousState?.hasInternet ?? false);

      // Transition: From an "effectively offline" or "uninitialized" state to "Online"
      // AND it's not the very first time this listener is triggered with an already online state.
      if (!wasEffectivelyConnected && isNowConnected && previousState != null) {
        setState(() {
          _showOnlineBanner = true;
          _offlineBannerDismissed = false; // Reset offline banner dismissed state when coming back online
        });
        _onlineBannerTimer?.cancel(); // Cancel any existing timer
        _onlineBannerTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            // Check if widget is still in the tree
            setState(() {
              _showOnlineBanner = false;
            });
          }
        });
      }
      // Transition: To "Offline" or staying "Offline"
      else if (!isNowConnected) {
        _onlineBannerTimer
            ?.cancel(); // Hide "online" banner immediately if we go offline
        if (_showOnlineBanner) {
          // Only update state if it needs to change
          setState(() {
            _showOnlineBanner = false;
            _offlineBannerDismissed = false; // Reset offline banner dismissed state when going offline
          });
        } else {
          // If we're going offline and the online banner wasn't showing, still reset the offline banner dismissed state
          setState(() {
            _offlineBannerDismissed = false;
          });
        }
      }
    });

    // Watch the current state to build the UI
    final InternetState internetState = ref.watch(internetNotifierProvider);

    if (!internetState.isInitialized) {
      return const SizedBox.shrink(); // Don't show anything until initialized
    }

    final bool isActuallyOffline = !internetState.hasInternet;
    final bool isActuallyOnline = internetState.hasInternet;

    Widget? bannerContentWidget;
    Color? bannerColor;
    String? bannerText;

    if (isActuallyOffline && !_offlineBannerDismissed) {
      bannerColor = Theme.of(context).colorScheme.error.withOpacity(0.95);
      bannerText = 'You are offline. Some features may be unavailable.';
    } else if (_showOnlineBanner && isActuallyOnline) {
      bannerColor = Theme.of(context).colorScheme.primary.withOpacity(0.95);
      bannerText = 'Back online!';
    }

    if (bannerText == null || bannerColor == null) {
      return const SizedBox.shrink(); // No banner to display
    }

    bannerContentWidget = Material(
      color: bannerColor,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                bannerText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: _dismissBanner,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(top: false, bottom: true, child: bannerContentWidget),
    );
  }
}
