@TestOn('vm')
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html2apk/src/apk/signing_key.dart';
import 'package:html2apk/src/site_files.dart';
import 'package:html2apk/src/ui/generator_page.dart';

import '../support/sdk_tools.dart' as sdk;
import 'fakes.dart';

void main() {
  late SigningKey key;
  setUpAll(() => key = SigningKey.generate());

  PickedSite site(Map<String, String> files, {String label = 'mysite'}) =>
      PickedSite(
        files: {
          for (final e in files.entries)
            e.key: Uint8List.fromList(e.value.codeUnits),
        },
        label: label,
      );

  Future<void> pumpPage(
    WidgetTester tester, {
    Future<PickedSite?> Function()? pickFolder,
    Future<PickedSite?> Function()? pickHtmlFile,
  }) async {
    final store = await memoryStore();
    await tester.pumpWidget(
      MaterialApp(
        home: GeneratorPage(
          actions: FakeActions(),
          savedApps: store,
          loadKey: () async => key,
          replaceKey: (_) async {},
          loadTemplate: () async => sdk.loadTemplate(),
          pickFolder: pickFolder ?? () async => null,
          pickHtmlFile: pickHtmlFile ?? () async => null,
        ),
      ),
    );
  }

  Future<void> enterName(WidgetTester tester, String name) async {
    await tester.enterText(find.byKey(const Key('name-field')), name);
    await tester.pump();
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

  testWidgets('folder with index.html enables Generate', (tester) async {
    await pumpPage(
      tester,
      pickFolder: () async =>
          site({'index.html': '<h1>hi</h1>', 'css/a.css': 'h1{}'}),
    );
    await enterName(tester, 'My Site');
    await tester.tap(find.text('Folder'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('pick-folder')));
    await tester.tap(find.byKey(const Key('pick-folder')));
    await tester.pump();
    expect(find.textContaining('2 files'), findsOneWidget);
    expect(find.textContaining('my_site.html2apk'), findsOneWidget);
    await scrollToGenerate(tester);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('generate')),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('folder without index.html stays disabled', (tester) async {
    await pumpPage(
      tester,
      pickFolder: () async => site({'style.css': 'h1{}'}),
    );
    await enterName(tester, 'My Site');
    await tester.tap(find.text('Folder'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pick-folder')));
    await tester.pump();
    expect(find.text('No index.html in this folder'), findsOneWidget);
    await scrollToGenerate(tester);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('generate')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('single HTML file enables Generate', (tester) async {
    await pumpPage(
      tester,
      pickHtmlFile: () async => site(
        {'index.html': '<h1>hi</h1>'},
        label: 'page.html',
      ),
    );
    await enterName(tester, 'Single');
    await tester.tap(find.text('Single file'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pick-html-file')));
    await tester.pump();
    expect(find.textContaining('page.html'), findsWidgets);
    await scrollToGenerate(tester);
    final button = tester.widget<FilledButton>(
      find.byKey(const Key('generate')),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('switching back to URL restores the URL field', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Folder'));
    await tester.pump();
    expect(find.byKey(const Key('url-field')), findsNothing);
    await tester.tap(find.text('Website'));
    await tester.pump();
    expect(find.byKey(const Key('url-field')), findsOneWidget);
  });
}
