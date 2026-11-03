import 'package:flutter/material.dart';

import 'camera_screen.dart';

Future<void> openCamera(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const CameraScreen(),
    ),
  );
}
