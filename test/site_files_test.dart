import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:html2apk/src/site_files.dart';

void main() {
  test('siteEntry prefers index.html over index.htm', () {
    expect(siteEntry({'index.htm': Uint8List(0)}), 'index.htm');
    expect(
      siteEntry({'index.htm': Uint8List(0), 'index.html': Uint8List(0)}),
      'index.html',
    );
    expect(siteEntry({'Index.HTML': Uint8List(0)}), 'Index.HTML');
    expect(siteEntry({'style.css': Uint8List(0)}), isNull);
  });

  test('keepSiteFile skips hidden files and macOS metadata', () {
    expect(keepSiteFile('index.html'), isTrue);
    expect(keepSiteFile('assets/logo.png'), isTrue);
    expect(keepSiteFile('.DS_Store'), isFalse);
    expect(keepSiteFile('.hidden/x.html'), isFalse);
    expect(keepSiteFile('__MACOSX/index.html'), isFalse);
  });

  test('formatBytes', () {
    expect(formatBytes(0), '0 B');
    expect(formatBytes(512), '512 B');
    expect(formatBytes(2048), '2 KB');
    expect(formatBytes(1536 * 1024), '1.5 MB');
  });
}
