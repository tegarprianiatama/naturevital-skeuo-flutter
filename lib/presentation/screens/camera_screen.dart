import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../core/providers.dart';
import '../../core/skeuo_theme.dart';
import '../../domain/entities/food_analysis.dart';
import '../state/app_controller.dart';
import '../widgets/skeuo_button.dart';
import '../widgets/skeuo_surface.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  static const _maxSide = 800;
  static const _jpegQuality = 72;

  CameraController? _controller;
  final ImagePicker _picker = ImagePicker();

  Uint8List? _imageBytes;
  FoodAnalysis? _analysis;
  bool _analyzing = false;
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  bool _zoomed = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  int _aspectRatioIndex = 0;
  static const _ratios = [null, 1.0, 4 / 3, 3 / 2, 16 / 9];
  static const _ratioNames = ['Auto', '1:1', '4:3', '3:2', '16:9'];

  Future<void> _toggleAspectRatio() async {
    setState(() {
      _aspectRatioIndex = (_aspectRatioIndex + 1) % _ratios.length;
    });
  }

  Future<void> _toggleZoom() async {
    final controller = _controller;
    if (controller == null) return;

    final minZoom = await controller.getMinZoomLevel();
    final maxZoom = await controller.getMaxZoomLevel();
    final zoom = _zoomed ? minZoom : maxZoom / 2;
    await controller.setZoomLevel(zoom);
    setState(() => _zoomed = !_zoomed);
  }

  Future<void> _resetCamera() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.setZoomLevel(1.0);
    setState(() {
      _zoomed = false;
      _aspectRatioIndex = 0;
    });
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('no_camera', 'No camera found on this device.');
      }

      final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = _cameraErrorMessage(error);
      });
    }
  }

  String _cameraErrorMessage(Object error) {
    if (error is CameraException) {
      switch (error.code) {
        case 'CameraAccessDenied':
        case 'CameraAccessDeniedWithoutPrompt':
          return 'Camera access denied. Enable it in settings or pick from gallery.';
        case 'no_camera':
          return error.description ?? 'No camera available.';
      }
    }
    return 'Could not access camera. Pick photo from gallery.';
  }

  Uint8List _compress(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;

      var target = decoded;
      if (decoded.width > _maxSide || decoded.height > _maxSide) {
        target = decoded.width >= decoded.height
            ? img.copyResize(
                decoded,
                width: _maxSide,
                interpolation: img.Interpolation.average,
              )
            : img.copyResize(
                decoded,
                height: _maxSide,
                interpolation: img.Interpolation.average,
              );
      }

      return Uint8List.fromList(img.encodeJpg(target, quality: _jpegQuality));
    } catch (_) {
      return bytes;
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;
    if (_analyzing) return;

    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      await _process(bytes);
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.description ?? 'Capture failed.');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      await _process(bytes);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Could not open gallery: $error');
    }
  }

  Future<void> _process(Uint8List rawBytes) async {
    final compressed = _compress(rawBytes);

    setState(() {
      _imageBytes = compressed;
      _analysis = null;
      _analyzing = true;
      _error = null;
    });

    try {
      final analysis = await ref.read(analyzeFoodUseCaseProvider)(
        base64Encode(compressed),
      );
      if (!mounted) return;
      setState(() => _analysis = analysis);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'Analysis failed. Please try again.\n$error');
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  void _reset() {
    setState(() {
      _imageBytes = null;
      _analysis = null;
      _error = null;
    });
  }

  Future<void> _logEntry() async {
    final analysis = _analysis;
    final bytes = _imageBytes;
    if (analysis == null || bytes == null) return;

    final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    
    // Fire and forget, controller handles navigation and errors
    ref.read(appControllerProvider.notifier).addFood(analysis, dataUrl);
    
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackgroundView(),
          if (_imageBytes == null && _controller != null && _error == null)
            _buildViewfinderGrid(),
          if (_analyzing) _buildAnalyzingOverlay(),
          _buildTopBar(context),
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                IconButton(
                  onPressed: _resetCamera,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
                IconButton(
                  onPressed: _toggleAspectRatio,
                  icon: Text(
                    _ratioNames[_aspectRatioIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: _toggleZoom,
                  icon: Icon(
                    _zoomed ? Icons.zoom_out : Icons.zoom_in,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _buildBottomOverlay(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundView() {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    }

    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(color: Skeuo.accent),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: Icon(
          Icons.videocam_off_outlined,
          color: Colors.white38,
          size: 48,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final previewSize = controller.value.previewSize;
        if (previewSize == null) return const SizedBox.expand();

        final ratio = _ratios[_aspectRatioIndex];
        return Center(
          child: AspectRatio(
            aspectRatio: ratio ?? 1.0,
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }

  Widget _buildViewfinderGrid() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x59FFFFFF), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D000000),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x80FFFFFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              CustomPaint(size: const Size(280, 280), painter: _GridPainter()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: const Color(0xA6000000),
      child: Center(
        child: SkeuoCard(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  color: Skeuo.accent,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'PROCESSING LOADING, PLEASE WAIT...',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  color: Skeuo.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeuoCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.remove_red_eye_rounded,
                      size: 16,
                      color: Skeuo.accent,
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PROCESSING',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Skeuo.text,
                          ),
                        ),
                        Text(
                          'SCANNER ACTIVE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: Skeuo.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: SkeuoDial(
                  size: 44,
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Skeuo.text,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                _buildErrorBanner(_error!),
                const SizedBox(height: 12),
              ],
              if (_analysis != null) ...[
                _buildAnalysisCard(_analysis!),
                const SizedBox(height: 14),
                _buildLogActionRow(),
              ] else ...[
                _buildCaptureControls(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(FoodAnalysis analysis) {
    return SkeuoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  analysis.foodName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  '${(analysis.confidence * 100).round()}% RELIABLE',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SkeuoInset(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutrientValue(
                  value: analysis.calories.round().toString(),
                  label: 'kcal',
                  big: true,
                ),
                _NutrientValue(
                  value: '${analysis.protein.round()}g',
                  label: 'Pro',
                ),
                _NutrientValue(
                  value: '${analysis.carbs.round()}g',
                  label: 'Carb',
                ),
                _NutrientValue(value: '${analysis.fat.round()}g', label: 'Fat'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogActionRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: _reset,
          child: const SkeuoDial(
            size: 52,
            child: Center(
              child: Icon(Icons.refresh_rounded, size: 22, color: Skeuo.text),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SkeuoButton(
            padding: const EdgeInsets.symmetric(vertical: 16),
            onTap: _logEntry,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'LOG ENTRY',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureControls(BuildContext context) {
    return SkeuoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _pickFromGallery,
            iconSize: 26,
            color: Skeuo.textMuted,
            tooltip: 'Gallery',
            icon: const Icon(Icons.photo_library_outlined),
          ),
          GestureDetector(
            onTap: _capture,
            child: SkeuoDial(
              size: 68,
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Skeuo.accent, width: 3),
                  ),
                  child: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Skeuo.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x663B82F6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            iconSize: 26,
            color: Skeuo.textMuted,
            tooltip: 'Cancel',
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xE6EF4444),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8),
        ],
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..strokeWidth = 1.0;

    const step = 35.0;
    for (double x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NutrientValue extends StatelessWidget {
  const _NutrientValue({
    required this.value,
    required this.label,
    this.big = false,
  });

  final String value;
  final String label;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: big ? 20 : 16,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Skeuo.textMuted,
          ),
        ),
      ],
    );
  }
}
