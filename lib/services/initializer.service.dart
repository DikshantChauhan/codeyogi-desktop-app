import 'package:desktop_app/providers/sublevel_provider.dart';
import 'package:desktop_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import '../services/local_storage.service.dart';

class InitializerService {
  static handleWindowResize() async {
    // Initialize window_manager
    await windowManager.ensureInitialized();

    // Define your minimum size
    const double minWidth = 800.0;
    const double minHeight = 600.0;

    // Set window options
    WindowOptions windowOptions = const WindowOptions(
      minimumSize: Size(minWidth, minHeight),
      // You can also set initial size, title, etc. here
      // size: Size(1024, 768),
      // center: true,
      // title: 'My Awesome App',
    );

    // Apply the window options
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  static Future<ProviderContainer> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await handleWindowResize();

    MediaKit.ensureInitialized();

    await LocalStorageService.initialize();

    //Order matters here
    final container = ProviderContainer();
    await container.read(sublevelProvider.notifier).initialize();
    await container.read(userProvider.notifier).initialize();

    return container;
  }
}
