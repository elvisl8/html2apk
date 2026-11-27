import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../site_files.dart';

/// Lets the user pick a site folder via a `webkitdirectory` file input
/// (Chrome, Edge, Firefox and Safari); null when cancelled. Files are
/// keyed by path relative to the folder, with `/` separators.
Future<PickedSite?> pickSiteFolder() async {
  final input = _fileInput(directory: true);
  final files = await _pickFiles(input);
  if (files == null) return null;
  final picked = <String, Uint8List>{};
  for (final file in files) {
    final relative = file.webkitRelativePath;
    if (relative.isEmpty || !keepSiteFile(relative)) continue;
    picked[relative] = await _readFile(file);
  }
  final label = picked.isEmpty ? '' : picked.keys.first.split('/').first;
  return PickedSite(files: picked, label: label);
}

/// Lets the user pick a single HTML file; null when cancelled. The file is
/// stored as the site's `index.html`.
Future<PickedSite?> pickSingleHtmlFile() async {
  final input = _fileInput(directory: false)..accept = '.html,.htm';
  final files = await _pickFiles(input);
  if (files == null || files.isEmpty) return null;
  final file = files.first;
  return PickedSite(
    files: {'index.html': await _readFile(file)},
    label: file.name,
  );
}

web.HTMLInputElement _fileInput({required bool directory}) {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..style.display = 'none';
  if (directory) {
    input.setAttribute('webkitdirectory', '');
    input.multiple = true;
  }
  web.document.body!.append(input);
  return input;
}

/// Waits for the user to pick files in [input], or null when cancelled.
/// A cancelled dialog fires `cancel` in Chromium; in browsers that do not
/// fire it, the pick is simply abandoned and the user can try again.
Future<List<web.File>?> _pickFiles(web.HTMLInputElement input) async {
  final chosen = Completer<List<web.File>?>();
  void done(List<web.File>? files) {
    if (!chosen.isCompleted) chosen.complete(files);
    input.remove();
  }

  input.addEventListener(
    'change',
    ((web.Event _) {
      final list = input.files;
      final files = <web.File>[];
      if (list != null) {
        for (var i = 0; i < list.length; i++) {
          final file = list.item(i);
          if (file != null) files.add(file);
        }
      }
      done(files);
    }).toJS,
  );
  input.addEventListener('cancel', ((web.Event _) => done(null)).toJS);
  input.click();
  return chosen.future;
}

Future<Uint8List> _readFile(web.File file) async {
  final buffer = await file.arrayBuffer().toDart;
  return buffer.toDart.asUint8List();
}
