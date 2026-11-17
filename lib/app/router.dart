import 'package:go_router/go_router.dart';

import '../features/data/data_screen.dart';
import '../features/meals/meals_screen.dart';
import '../features/today/today_screen.dart';
import '../features/training/training_screen.dart';
import 'home_shell.dart';
import 'routes.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: AppRoutes.today,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => HomeShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.today,
              builder: (context, state) => const TodayScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.training,
              builder: (context, state) => const TrainingScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.meals,
              builder: (context, state) => const MealsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.data,
              builder: (context, state) => const DataScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
