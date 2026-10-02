import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeroom/core/theme.dart';
import 'package:homeroom/widgets/basics.dart';

/// A rounded border whose sides differ in colour throws during paint, after the background fill, so the
/// widget's contents silently never draw. These cards and banners are on every screen; keep them paintable.
void main() {
  Future<void> paint(WidgetTester tester, Widget child) => tester.pumpWidget(MaterialApp(
        theme: ThemeData(extensions: [Tokens.of(Brightness.dark, Portal.parent)]),
        home: Scaffold(body: Column(children: [child])),
      ));

  testWidgets('HrCard paints its child', (tester) async {
    await paint(tester, const HrCard(child: Text('inside')));
    expect(tester.takeException(), isNull);
    expect(find.text('inside'), findsOneWidget);
  });

  testWidgets('HrCard without the accent rule paints its child', (tester) async {
    await paint(tester, const HrCard(accentRule: false, child: Text('inside')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('StatTile paints', (tester) async {
    await paint(tester, const StatTile(label: 'Latest grade', value: '82%', sub: 'Quiz 3'));
    expect(tester.takeException(), isNull);
    expect(find.text('82%'), findsOneWidget);
  });

  testWidgets('InfoBanner paints in every tone', (tester) async {
    for (final tone in BannerTone.values) {
      await paint(tester, InfoBanner('notice', tone: tone));
      expect(tester.takeException(), isNull, reason: '$tone');
    }
  });
}
