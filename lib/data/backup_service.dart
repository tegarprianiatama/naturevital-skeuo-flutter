import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'local/app_database.dart';
import 'local/local_photo_store.dart';

/// Self-contained JSON backup: profile + logs + photos (base64).
///
/// Local-only storage means an uninstall wipes everything, so this service is
/// the safety net. The format is intentionally plain JSON so it can be read,
/// edited and diffed outside the app.
class BackupService {
  BackupService({AppDatabase? database, LocalPhotoStore? photoStore})
    : _database = database ?? AppDatabase.instance,
      _photoStore = photoStore ?? LocalPhotoStore();

  static const backupVersion = 1;

  final AppDatabase _database;
  final LocalPhotoStore _photoStore;

  Future<BackupExportResult> exportToFile(String uid) async {
    final db = await _database.database;

    final profileRows = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
      limit: 1,
    );
    final logRows = await db.rawQuery(
      'SELECT * FROM logs WHERE userId = ? ORDER BY timestamp ASC',
      [uid],
    );

    final photos = <String, String>{};
    for (final row in logRows) {
      final imageUrl = row['imageUrl'] as String?;
      if (imageUrl == null || !_isLocalFileName(imageUrl)) continue;
      final base64 = await _photoStore.readBase64(imageUrl);
      if (base64 != null) photos[imageUrl] = base64;
    }

    final payload = <String, Object?>{
      'backupVersion': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'uid': uid,
      'profile': profileRows.isEmpty
          ? null
          : Map<String, Object?>.from(profileRows.first),
      'logs': logRows.map(Map<String, Object?>.from).toList(),
      'photos': photos,
    };

    final dir = await getTemporaryDirectory();
    final stamp = _timestamp();
    final file = File(p.join(dir.path, 'naturevital-backup-$stamp.json'));
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );

    return BackupExportResult(
      file: file,
      logCount: logRows.length,
      photoCount: photos.length,
    );
  }

  /// Restores JSON produced by [exportToFile] into the current account.
  ///
  /// Rows are upserted by primary key and ownership is rewritten to
  /// [currentUid], because this is a single-person backup of one's own data.
  Future<BackupImportResult> importFromJson(
    String json, {
    required String currentUid,
    String? displayName,
  }) async {
    final decoded = jsonDecode(json);
    if (decoded is! Map) {
      throw const FormatException('Backup file is not a JSON object.');
    }

    final payload = Map<String, dynamic>.from(decoded);
    final version = (payload['backupVersion'] as num?)?.toInt() ?? 0;
    if (version > backupVersion) {
      throw FormatException(
        'Backup version $version is newer than this app supports '
        '($backupVersion). Please update the app.',
      );
    }

    final rawLogs = payload['logs'];
    final rawPhotos = payload['photos'];
    final rawProfile = payload['profile'];

    var importedLogs = 0;
    var skippedLogs = 0;
    var importedPhotos = 0;

    final db = await _database.database;

    // Photos first: if a log references a missing photo we still keep the row.
    if (rawPhotos is Map) {
      for (final entry in rawPhotos.entries) {
        final name = entry.key as String;
        final base64 = entry.value;
        if (base64 is! String || !_isSafeFileName(name)) continue;
        try {
          await _photoStore.write(name, base64Decode(base64));
          importedPhotos++;
        } catch (_) {
          // Corrupt photo entry: skip, the log still renders its placeholder.
        }
      }
    }

    await db.transaction((txn) async {
      if (rawLogs is List) {
        for (final item in rawLogs) {
          if (item is! Map) {
            skippedLogs++;
            continue;
          }
          final row = _normalizeLogRow(item, currentUid);
          if (row == null) {
            skippedLogs++;
            continue;
          }
          await txn.insert(
            'logs',
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          importedLogs++;
        }
      }

      if (rawProfile is Map) {
        final profile = _normalizeProfileRow(
          rawProfile,
          currentUid,
          displayName,
        );
        await txn.insert(
          'users',
          profile,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    return BackupImportResult(
      logCount: importedLogs,
      photoCount: importedPhotos,
      skippedLogs: skippedLogs,
      hadProfile: rawProfile is Map,
    );
  }

  Map<String, Object?>? _normalizeLogRow(Map item, String currentUid) {
    final row = Map<String, dynamic>.from(item);

    final id = row['id'];
    final timestamp = row['timestamp'];
    final type = row['type'];
    if (id is! String || id.isEmpty) return null;
    if (timestamp is! num) return null;
    if (type != 'food' && type != 'water') return null;

    double? asDouble(Object? value) =>
        value is num ? value.toDouble() : null;

    return {
      'id': id,
      'userId': currentUid,
      'timestamp': timestamp.toInt(),
      'type': type,
      'calories': asDouble(row['calories']),
      'description': row['description'] is String
          ? row['description'] as String
          : null,
      'imageUrl': row['imageUrl'] is String ? row['imageUrl'] as String : null,
      'protein': asDouble(row['protein']),
      'carbs': asDouble(row['carbs']),
      'fat': asDouble(row['fat']),
      'amount': asDouble(row['amount']),
    };
  }

  Map<String, Object?> _normalizeProfileRow(
    Map item,
    String currentUid,
    String? displayName,
  ) {
    final row = Map<String, dynamic>.from(item);
    double asDouble(Object? value, double fallback) =>
        value is num ? value.toDouble() : fallback;

    return {
      'uid': currentUid,
      'displayName': displayName?.isNotEmpty == true
          ? displayName!
          : (row['displayName'] is String &&
                    (row['displayName'] as String).isNotEmpty
                ? row['displayName'] as String
                : 'User'),
      'calorieGoal': asDouble(row['calorieGoal'], 2200),
      'waterGoal': asDouble(row['waterGoal'], 2500),
    };
  }

  bool _isLocalFileName(String imageUrl) {
    return !imageUrl.startsWith('http') && !imageUrl.startsWith('data:');
  }

  bool _isSafeFileName(String name) {
    return name.isNotEmpty &&
        p.basename(name) == name &&
        !name.contains('..') &&
        !name.contains('/') &&
        !name.contains(r'\');
  }

  String _timestamp() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}'
        '-${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }
}

class BackupExportResult {
  const BackupExportResult({
    required this.file,
    required this.logCount,
    required this.photoCount,
  });

  final File file;
  final int logCount;
  final int photoCount;
}

class BackupImportResult {
  const BackupImportResult({
    required this.logCount,
    required this.photoCount,
    required this.skippedLogs,
    required this.hadProfile,
  });

  final int logCount;
  final int photoCount;
  final int skippedLogs;
  final bool hadProfile;
}
