import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:desktop_app/pages/login_page.dart';
import 'package:desktop_app/pages/signup_page.dart';
import 'package:desktop_app/pages/dashboard_page.dart';
import 'package:desktop_app/providers/user_provider.dart';

const String ROUTE_LOGIN = '/login';
const String ROUTE_REGISTER = '/register';
const String ROUTE_DASHBOARD = '/dashboard';

class GoRouterRefreshNotifier extends ChangeNotifier {
  late final ProviderSubscription<AuthData> _subscription;
  final Ref _ref;

  GoRouterRefreshNotifier(this._ref) {
    _subscription = _ref.listen<AuthData>(userProvider, (previous, next) {
      if (previous?.authState != next.authState) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshNotifier(ref);

  final initialUserData = ref.read(userProvider);
  final initialUserAuthState = initialUserData.authState;

  return GoRouter(
    refreshListenable: refreshNotifier,
    initialLocation:
        initialUserAuthState == AuthState.authenticated
            ? ROUTE_DASHBOARD
            : ROUTE_LOGIN,

    redirect: (context, GoRouterState state) {
      final currentAuthData = ref.read(userProvider);
      final currentAuthState = currentAuthData.authState;
      final isAuthenticated = currentAuthState == AuthState.authenticated;

      final currentLocation = state.matchedLocation;
      final onLoginPage = currentLocation == ROUTE_LOGIN;
      final onRegisterPage = currentLocation == ROUTE_REGISTER;

      if (isAuthenticated && (onLoginPage || onRegisterPage)) {
        return ROUTE_DASHBOARD;
      } else if (!isAuthenticated && !onLoginPage && !onRegisterPage) {
        return ROUTE_LOGIN;
      }

      return null;
    },

    routes: <RouteBase>[
      GoRoute(
        path: ROUTE_LOGIN,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: ROUTE_REGISTER,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: ROUTE_DASHBOARD,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/*',
        redirect: (context, GoRouterState state) {
          final authData = ref.read(userProvider);
          final isAuthenticated = authData.authState == AuthState.authenticated;

          return isAuthenticated ? ROUTE_DASHBOARD : ROUTE_LOGIN;
        },
      ),
    ],
  );
});
