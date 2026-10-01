import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homeroom_api/api.dart';

import '../core/providers.dart';
import '../features/auth/auth_actions.dart';
import '../features/auth/sign_in.dart';
import '../features/common/notifications.dart';
import '../features/common/settings.dart';
import '../features/messages/messages.dart';
import '../features/parent/fees.dart';
import '../features/parent/home.dart';
import '../features/parent/more.dart';
import '../features/parent/records.dart';
import '../features/teacher/classes.dart';
import '../features/teacher/gradebook.dart';
import '../features/teacher/more.dart';
import '../features/teacher/today.dart';
import '../widgets/basics.dart';
import '../widgets/screen.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

const _public = {'/signin', '/forgot', '/picker'};

/// Where a person lands: their own portal. Admins and students have no mobile app.
String homeFor(Me? me) => switch (me?.role) {
      Role.guardian => '/parent/home',
      Role.teacher => '/teacher/today',
      null => '/signin',
      _ => '/unsupported',
    };

final routerProvider = Provider<GoRouter>((ref) {
  final store = ref.watch(sessionStoreProvider);

  String? guard(BuildContext context, GoRouterState state) {
    final me = store.value?.me;
    final path = state.uri.path;
    if (me == null) return _public.contains(path) ? null : '/signin';
    if (path == '/' || path == '/signin' || path == '/picker' || path == '/forgot') return homeFor(me);
    // each portal is for its own role
    if (path.startsWith('/parent') && me.role != Role.guardian) return homeFor(me);
    if (path.startsWith('/teacher') && me.role != Role.teacher) return homeFor(me);
    return null;
  }

  GoRoute detail(String path, Widget Function(BuildContext, GoRouterState) builder) =>
      GoRoute(path: path, parentNavigatorKey: _rootKey, builder: builder);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: store,
    redirect: guard,
    routes: [
      GoRoute(path: '/', redirect: (_, _) => homeFor(store.value?.me)),
      GoRoute(path: '/signin', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/forgot', builder: (_, _) => const ForgotScreen()),
      GoRoute(path: '/picker', builder: (_, _) => const PickerScreen()),
      GoRoute(path: '/unsupported', builder: (_, _) => const _UnsupportedScreen()),

      // ---- parent ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Tabs(shell: shell, tabs: const [
          (Icons.home_outlined, Icons.home, 'Home'),
          (Icons.fact_check_outlined, Icons.fact_check, 'Attendance'),
          (Icons.bar_chart_outlined, Icons.bar_chart, 'Grades'),
          (Icons.payments_outlined, Icons.payments, 'Fees'),
          (Icons.more_horiz, Icons.more_horiz, 'More'),
        ]),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/parent/home', builder: (_, _) => const ParentHome())]),
          StatefulShellBranch(routes: [GoRoute(path: '/parent/attendance', builder: (_, _) => const AttendanceScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/parent/grades', builder: (_, _) => const GradesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/parent/fees', builder: (_, _) => const FeesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/parent/more', builder: (_, _) => const ParentMore())]),
        ],
      ),
      detail('/parent/fees/pay/:id', (_, s) => PayScreen(invoiceId: s.pathParameters['id']!)),
      detail('/parent/messages', (_, _) => const MessagesScreen(base: '/parent')),
      detail('/parent/messages/:id', (_, s) => ThreadScreen(threadId: s.pathParameters['id']!, base: '/parent')),
      detail('/parent/homework', (_, _) => const ParentHomeworkScreen()),
      detail('/parent/announcements', (_, _) => const ParentAnnouncementsScreen()),
      detail('/parent/conference', (_, _) => const ConferenceScreen()),
      detail('/parent/reports', (_, _) => const ReportsScreen()),
      detail('/parent/notifications', (_, _) => const NotificationsScreen()),
      detail('/parent/settings', (_, _) => const SettingsScreen(base: '/parent')),
      detail('/parent/sms', (_, _) => const SmsAlertsScreen()),

      // ---- teacher ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _Tabs(shell: shell, tabs: const [
          (Icons.today_outlined, Icons.today, 'Today'),
          (Icons.groups_outlined, Icons.groups, 'Classes'),
          (Icons.mail_outline, Icons.mail, 'Messages'),
          (Icons.more_horiz, Icons.more_horiz, 'More'),
        ]),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/teacher/today', builder: (_, _) => const TeacherToday())]),
          StatefulShellBranch(routes: [GoRoute(path: '/teacher/classes', builder: (_, _) => const ClassesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/teacher/messages', builder: (_, _) => const MessagesScreen(base: '/teacher'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/teacher/more', builder: (_, _) => const TeacherMore())]),
        ],
      ),
      detail('/teacher/attendance/:section/:period/:date', (_, s) => TakeAttendanceScreen(section: s.pathParameters['section']!, period: s.pathParameters['period']!, date: s.pathParameters['date']!)),
      detail('/teacher/class/:id', (_, s) => ClassDetailScreen(id: s.pathParameters['id']!)),
      detail('/teacher/gradebook', (_, _) => const GradebookScreen()),
      detail('/teacher/gradebook/new', (_, s) => NewAssessmentScreen(section: s.uri.queryParameters['section'], subject: s.uri.queryParameters['subject'])),
      detail('/teacher/messages/:id', (_, s) => ThreadScreen(threadId: s.pathParameters['id']!, base: '/teacher')),
      detail('/teacher/homework', (_, _) => const TeacherHomeworkScreen()),
      detail('/teacher/conferences', (_, _) => const TeacherConferencesScreen()),
      detail('/teacher/notifications', (_, _) => const NotificationsScreen()),
      detail('/teacher/settings', (_, _) => const SettingsScreen(base: '/teacher')),
      detail('/teacher/sms', (_, _) => const SmsAlertsScreen()),
    ],
    errorBuilder: (context, state) => HrScreen(title: 'Page not found', children: [
      const InfoBanner('That page does not exist.', tone: BannerTone.alert),
      WideButton(label: 'Go home', onPressed: () => context.go('/')),
    ]),
  );
});

/// Bottom tab bar around the role's main screens. Detail screens sit above it without the bar.
class _Tabs extends StatelessWidget {
  const _Tabs({required this.shell, required this.tabs});
  final StatefulNavigationShell shell;
  final List<(IconData, IconData, String)> tabs;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [for (final t in tabs) NavigationDestination(icon: Icon(t.$1), selectedIcon: Icon(t.$2), label: t.$3)],
        ),
      );
}

class _UnsupportedScreen extends ConsumerWidget {
  const _UnsupportedScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) => HrScreen(title: 'Use the web app', children: [
        const HrCard(child: Text('This app is for teachers and parents. Administrators manage the school from the web app.')),
        WideButton(label: 'Sign out', secondary: true, onPressed: () => ref.read(authActionsProvider).signOut()),
      ]);
}
