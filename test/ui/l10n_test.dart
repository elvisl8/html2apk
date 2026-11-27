@TestOn('vm')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html2apk/src/apk/signing_key.dart';
import 'package:html2apk/src/l10n.dart';
import 'package:html2apk/src/saved_apps.dart';
import 'package:html2apk/src/ui/generator_page.dart';

import 'fakes.dart';

void main() {
  late SigningKey key;
  setUpAll(() => key = SigningKey.generate());

  Future<(SharedPreferences, SavedAppsStore)> pumpPage(
    WidgetTester tester, {
    String? language,
  }) async {
    SharedPreferences.setMockInitialValues(
      language == null ? {} : {languagePrefKey: language},
    );
    final prefs = await SharedPreferences.getInstance();
    final store = SavedAppsStore(prefs);
    // Mirrors main.dart: L10n wraps MaterialApp so pushed routes and
    // dialogs see the chosen language too.
    await tester.pumpWidget(
      L10n(
        prefs: prefs,
        child: MaterialApp(
          home: GeneratorPage(
            actions: FakeActions(),
            savedApps: store,
            loadKey: () async => key,
            replaceKey: (_) async {},
          ),
        ),
      ),
    );
    return (prefs, store);
  }

  // The Generate button sits at the bottom of a scrolling form; the sliver
  // only builds it once it is scrolled into view. Drag the form's ListView
  // until the button exists (scrollUntilVisible cannot target it: the page
  // has two Scrollables, and a ListView is not itself a Scrollable).
  Future<void> scrollToGenerate(WidgetTester tester) async {
    for (
      var i = 0;
      i < 10 && find.byKey(const Key('generate')).evaluate().isEmpty;
      i++
    ) {
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();
    }
  }

  testWidgets('Chinese preference renders Chinese UI', (tester) async {
    await pumpPage(tester, language: 'zh');
    // The preview reuses the app-name label as its title while the field
    // is empty, so type a name first to leave exactly one '应用名称'.
    await tester.enterText(find.byKey(const Key('name-field')), '测试应用');
    await tester.pump();
    // Check the top of the form before scrolling: the sliver unmounts it
    // once the Generate button is scrolled into view.
    expect(find.text('应用名称'), findsOneWidget);
    expect(find.text('网址'), findsOneWidget);
    expect(find.byTooltip('我的应用'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
    await scrollToGenerate(tester);
    expect(find.text('生成'), findsOneWidget);
    expect(find.text('Generate'), findsNothing);
  });

  testWidgets('English preference renders English UI', (tester) async {
    await pumpPage(tester, language: 'en');
    // The preview reuses the app-name label as its title while the field
    // is empty, so type a name first to leave exactly one 'App name'.
    await tester.enterText(find.byKey(const Key('name-field')), 'Test App');
    await tester.pump();
    // Check the top of the form before scrolling: the sliver unmounts it
    // once the Generate button is scrolled into view.
    expect(find.text('App name'), findsOneWidget);
    expect(find.text('中文'), findsOneWidget);
    expect(find.text('生成'), findsNothing);
    await scrollToGenerate(tester);
    expect(find.text('Generate'), findsOneWidget);
  });

  testWidgets('language toggle switches and persists the choice',
      (tester) async {
    final (prefs, _) = await pumpPage(tester, language: 'zh');
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    await scrollToGenerate(tester);
    expect(find.text('Generate'), findsOneWidget);
    expect(prefs.getString(languagePrefKey), 'en');

    await tester.tap(find.text('中文'));
    await tester.pumpAndSettle();
    await scrollToGenerate(tester);
    expect(find.text('生成'), findsOneWidget);
    expect(prefs.getString(languagePrefKey), 'zh');
  });

  testWidgets('advanced settings follow the chosen language',
      (tester) async {
    await pumpPage(tester, language: 'zh');
    await tester.tap(find.byKey(const Key('advanced-settings')));
    await tester.pumpAndSettle();
    expect(find.text('屏幕方向'), findsOneWidget);
    expect(find.text('显示'), findsOneWidget);
    expect(find.text('Screen orientation'), findsNothing);
  });

  testWidgets('without a provider the UI falls back to the system locale',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      MaterialApp(
        home: GeneratorPage(
          actions: FakeActions(),
          savedApps: SavedAppsStore(prefs),
          loadKey: () async => key,
          replaceKey: (_) async {},
        ),
      ),
    );
    // The test environment reports an English locale.
    await scrollToGenerate(tester);
    expect(find.text('Generate'), findsOneWidget);
  });
}
