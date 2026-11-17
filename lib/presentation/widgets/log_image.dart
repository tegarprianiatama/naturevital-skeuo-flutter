import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/local/local_photo_store.dart';

class LogImage extends StatelessWidget {
  const LogImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final String imageUrl;
  final BoxFit fit;
  final Widget? fallback;

  Uint8List? _decodeDataUri() {
    const prefix = 'data:image/';
    if (!imageUrl.startsWith(prefix)) return null;
    final comma = imageUrl.indexOf(',');
    if (comma == -1) return null;
    try {
      return base64Decode(imageUrl.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decodeDataUri();
    if (bytes != null) {
      return Image.memory(bytes, fit: fit, gaplessPlayback: true);
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        errorBuilder: (_, _, _) => fallback ?? const SizedBox.shrink(),
      );
    }

    // Anything else is a local file name managed by LocalPhotoStore.
    return FutureBuilder<File>(
      future: LocalPhotoStore().fileFor(imageUrl),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null || !file.existsSync()) {
          return fallback ?? const SizedBox.shrink();
        }
        return Image.file(
          file,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => fallback ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
