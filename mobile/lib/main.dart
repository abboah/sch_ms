import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/format.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initFormatting();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(overrides: [prefsProvider.overrideWithValue(prefs)]);
  await container.read(sessionStoreProvider).load(); // restore the signed-in session before the first frame
  container.read(outboxProvider).startSync(); // keep trying to deliver anything saved offline
  runApp(UncontrolledProviderScope(container: container, child: const HomeroomApp()));
}
