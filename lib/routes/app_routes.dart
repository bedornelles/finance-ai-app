import 'package:go_router/go_router.dart';
import 'package:registrai/pages/chat_page.dart';
import 'package:registrai/pages/dashboard_page.dart';

class AppRoutes {
  static const String chat = "/";
  static const String dashboard = "/dashboard";

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.chat,

    routes: [
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
}