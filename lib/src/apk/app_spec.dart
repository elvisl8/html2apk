import 'dart:convert';
import 'dart:typed_data';

import 'app_options.dart';

/// Where a generated app's content comes from.
enum AppSource {
  /// A website URL, loaded by the WebView.
  url,

  /// A folder with an entry page, bundled into the APK.
  folder,

  /// A single self-contained HTML file, bundled as the entry page.
  singleFile,
}

/// Form data for one generated app, plus URL / package-id rules.
class AppSpec {
  final String name;

  /// The site URL; only for [AppSource.url], empty otherwise.
  final String url;
  final AppSource source;

  /// Site files for folder/single-file sources, keyed by path relative to
  /// the site root. Null for URL sources.
  final Map<String, Uint8List>? siteFiles;

  /// Entry page for local sources (e.g. `index.html`).
  final String entry;

  /// ARGB color.
  final int color;
  final bool fullscreen;
  final String packageId;
  final Uint8List? icon;
  final AppOptions options;

  const AppSpec({
    required this.name,
    required this.url,
    this.source = AppSource.url,
    this.siteFiles,
    this.entry = 'index.html',
    required this.color,
    required this.fullscreen,
    required this.packageId,
    this.icon,
    this.options = const AppOptions(),
  });

  /// Contents of `assets/config.json` in the generated APK.
  String configJson() {
    final rgb = (color & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    final shared = <String, Object>{
      'title': name,
      'color': '#${rgb.toUpperCase()}',
      'fullscreen': fullscreen,
      ...options.toJson(),
    };
    if (source == AppSource.url) {
      return jsonEncode({'url': url, ...shared});
    }
    return jsonEncode({'mode': 'local', 'entry': entry, ...shared});
  }
}

/// Trims, adds `https://` when no scheme is given, lowercases scheme and host.
/// Throws [FormatException] for non-http(s) schemes or an empty host.
String normalizeUrl(String input) {
  var s = input.trim();
  if (s.isEmpty) throw const FormatException('URL is empty');
  if (!s.contains('://')) s = 'https://$s';
  final Uri uri;
  try {
    uri = Uri.parse(s);
  } on FormatException {
    throw const FormatException('Invalid URL');
  }
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') {
    throw FormatException('Unsupported URL scheme: ${uri.scheme}');
  }
  if (uri.host.isEmpty) throw const FormatException('URL has no host');
  return uri.replace(scheme: scheme, host: uri.host.toLowerCase()).toString();
}

/// Derives a valid Android package id from an app name: the sanitized name
/// plus `html2apk`. Names without Latin letters fall back to `app`.
String packageIdFromName(String name) {
  final clean = name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final segment = clean.isEmpty
      ? 'app'
      : (RegExp(r'^[a-z]').hasMatch(clean) ? clean : 'x$clean');
  return '$segment.html2apk';
}

/// Derives a valid Android package id: reversed host + `html2apk`.
String packageIdFromUrl(String url) {
  var host = Uri.parse(normalizeUrl(url)).host.toLowerCase();
  if (host.startsWith('www.')) host = host.substring(4);
  final segments = host
      .split('.')
      .where((p) => p.isNotEmpty)
      .toList()
      .reversed
      .map((p) {
        final clean = p.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
        return RegExp(r'^[a-z]').hasMatch(clean) ? clean : 'x$clean';
      });
  return [...segments, 'html2apk'].join('.');
}

final _packageIdRe = RegExp(
  r'^[a-zA-Z][a-zA-Z0-9_]*(\.[a-zA-Z][a-zA-Z0-9_]*)+$',
);

bool isValidPackageId(String id) => _packageIdRe.hasMatch(id);
