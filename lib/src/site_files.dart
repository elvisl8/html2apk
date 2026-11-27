import 'dart:typed_data';

/// One picked site: files keyed by path relative to the site root,
/// using `/` as the separator.
class PickedSite {
  final Map<String, Uint8List> files;

  /// Display name: folder name, or the single file's name.
  final String label;

  const PickedSite({required this.files, required this.label});
}

/// Entry page of a site: `index.html` if present, else `index.htm`,
/// using the file's actual casing. Null when the site has no entry page.
String? siteEntry(Map<String, Uint8List> files) {
  final byLower = <String, String>{};
  for (final path in files.keys) {
    byLower.putIfAbsent(path.toLowerCase(), () => path);
  }
  return byLower['index.html'] ?? byLower['index.htm'];
}

/// Whether a site file belongs in the APK: skips hidden files and macOS
/// metadata.
bool keepSiteFile(String relativePath) {
  if (relativePath.startsWith('__MACOSX/')) return false;
  return !relativePath.split('/').any((part) => part.startsWith('.'));
}

/// Total size of [files] in bytes.
int siteTotalSize(Map<String, Uint8List> files) =>
    files.values.fold(0, (sum, bytes) => sum + bytes.lengthInBytes);

/// Human-readable size, e.g. `123 B`, `12 KB`, `1.2 MB`.
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
