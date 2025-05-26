import 'package:desktop_app/components/connectivity_status_overlay.dart';
import 'package:desktop_app/providers/router_provider.dart';
import 'package:desktop_app/services/initializer.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  final container = await InitializerService.initialize();

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 39, 39, 39),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A), // Dark background
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const ConnectivityStatusOverlay(),
          ],
        );
      },
    );
  }
}
