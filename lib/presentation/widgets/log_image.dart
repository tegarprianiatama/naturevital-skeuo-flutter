import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

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

    return fallback ?? const SizedBox.shrink();
  }
}
