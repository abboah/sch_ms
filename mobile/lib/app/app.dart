import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homeroom_api/api.dart';

import '../core/providers.dart';
import '../core/theme.dart';
import 'router.dart';
import 'theme_mode.dart';

class HomeroomApp extends ConsumerStatefulWidget {
  const HomeroomApp({super.key});

  @override
  ConsumerState<HomeroomApp> createState() => _HomeroomAppState();
}

class _HomeroomAppState extends ConsumerState<HomeroomApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Coming back to the foreground is the moment to retry anything saved while offline.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.read(outboxProvider).onResumed();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final me = ref.watch(meProvider);
    final portal = me?.role == Role.teacher ? Portal.teacher : Portal.parent;
    return MaterialApp.router(
      title: 'Homeroom',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: HrTheme.build(Brightness.light, portal),
      darkTheme: HrTheme.build(Brightness.dark, portal),
      themeMode: ref.watch(themeModeProvider),
    );
  }
}
