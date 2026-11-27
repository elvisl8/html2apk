import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../site_files.dart';

/// Lets the user pick a site folder; null when cancelled. Files are keyed
/// by path relative to the folder, with `/` separators.
Future<PickedSite?> pickSiteFolder() async {
  final path = await FilePicker.getDirectoryPath();
  if (path == null) return null;
  var root = Directory(path).path;
  while (root.endsWith(Platform.pathSeparator) && root.length > 1) {
    root = root.substring(0, root.length - 1);
  }
  final dir = Directory(root);
  final files = <String, Uint8List>{};
  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final relative = entity.path
        .substring(root.length + 1)
        .replaceAll(Platform.pathSeparator, '/');
    if (!keepSiteFile(relative)) continue;
    files[relative] = await entity.readAsBytes();
  }
  final label = root.split(Platform.pathSeparator).lastWhere(
        (part) => part.isNotEmpty,
        orElse: () => root,
      );
  return PickedSite(files: files, label: label);
}

/// Lets the user pick a single HTML file; null when cancelled. The file is
/// stored as the site's `index.html`.
Future<PickedSite?> pickSingleHtmlFile() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['html', 'htm'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return null;
  final file = result.files.first;
  final bytes = file.bytes;
  if (bytes == null) return null;
  return PickedSite(files: {'index.html': bytes}, label: file.name);
}
