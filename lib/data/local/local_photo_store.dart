import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stores food photos as real files in the app documents directory.
///
/// `logs.imageUrl` keeps the file *name* (not base64), so the database stays
/// small and photos never hit SQLite BLOBs.
class LocalPhotoStore {
  LocalPhotoStore({Directory? root}) : _rootOverride = root;

  static const _folderName = 'photos';

  final Directory? _rootOverride;
  Directory? _resolvedRoot;

  Future<Directory> _root() async {
    final cached = _resolvedRoot;
    if (cached != null) return cached;

    final base =
        _rootOverride ?? await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _folderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _resolvedRoot = dir;
    return dir;
  }

  Future<File> fileFor(String fileName) async {
    final dir = await _root();
    return File(p.join(dir.path, fileName));
  }

  /// Persists [bytes] and returns the generated file name.
  Future<String> save(Uint8List bytes) async {
    final now = DateTime.now();
    final name =
        '${now.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch % 100000}.jpg';
    final file = await fileFor(name);
    await file.writeAsBytes(bytes, flush: true);
    return name;
  }

  /// Writes [bytes] under an explicit [fileName] (used by backup restore).
  Future<void> write(String fileName, Uint8List bytes) async {
    final file = await fileFor(fileName);
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<void> delete(String fileName) async {
    final file = await fileFor(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Uint8List?> readBytes(String fileName) async {
    final file = await fileFor(fileName);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }

  Future<String?> readBase64(String fileName) async {
    final bytes = await readBytes(fileName);
    return bytes == null ? null : base64Encode(bytes);
  }
}
