import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qde_realme/core/theme/theme_colors.dart';

import '../../../../core/theme/theme_dimensions.dart';
import '../../../../core/theme/theme_text_styles.dart';

class ImeiScannerScreen extends StatefulWidget {
  const ImeiScannerScreen({super.key});

  @override
  State<ImeiScannerScreen> createState() => _ImeiScannerScreenState();
}

class _ImeiScannerScreenState extends State<ImeiScannerScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _isProcessing = false;
  String _scannedImei = 'point_at_IMEI'.tr();
  String _errorMessage = '';

  DateTime? _lastProcessedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _errorMessage = 'needCameraPermission'.tr());
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _errorMessage = 'cameraNotFound'.tr());
      return;
    }

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();

      final double minZoom = await _cameraController!.getMinZoomLevel();
      final double maxZoom = await _cameraController!.getMaxZoomLevel();
      double desiredZoom = 2.5;
      if (desiredZoom < minZoom) desiredZoom = minZoom;
      if (desiredZoom > maxZoom) desiredZoom = maxZoom;
      await _cameraController!.setZoomLevel(desiredZoom);

      await _cameraController!.setFocusMode(FocusMode.auto);
      await _cameraController!.startImageStream(_processImage);
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _errorMessage = '${'cameraError'.tr()}: $e');
    }
  }

  // Future<void> _processImage(CameraImage image) async {
  //   if (_isProcessing || _cameraController == null) return;
  //
  //   final now = DateTime.now();
  //
  //   if (_lastProcessedTime != null && now.difference(_lastProcessedTime!).inMilliseconds < 300) {
  //     return;
  //   }
  //
  //   _isProcessing = true;
  //   _lastProcessedTime = now;
  //
  //   try {
  //     final inputImage = _convertImageOptimized(image);
  //     if (inputImage == null) return;
  //
  //     final recognizedText = await _textRecognizer.processImage(inputImage);
  //     final RegExp imeiRegex = RegExp(r'\b\d{15,16}\b');
  //
  //     final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  //     final double imageWidth = isPortrait ? image.height.toDouble() : image.width.toDouble();
  //     final double imageHeight = isPortrait ? image.width.toDouble() : image.height.toDouble();
  //
  //     final double frameTopInImage = imageHeight * 0.4;
  //     final double frameBottomInImage = imageHeight * 0.6;
  //
  //     final List<TextLine> linesInFrame = [];
  //
  //     for (TextBlock block in recognizedText.blocks) {
  //       for (TextLine line in block.lines) {
  //         final rect = line.boundingBox;
  //         final double lineCenterY = rect.top + (rect.height / 2);
  //         if (lineCenterY >= frameTopInImage && lineCenterY <= frameBottomInImage) {
  //           linesInFrame.add(line);
  //         }
  //       }
  //     }
  //
  //     if (linesInFrame.isNotEmpty) {
  //       linesInFrame.sort((a, b) => (a.boundingBox.top ?? 0).compareTo(b.boundingBox.top ?? 0));
  //
  //       final cleanText = linesInFrame.first.text.replaceAll(RegExp(r'[\s-]'), '');
  //       final match = imeiRegex.firstMatch(cleanText);
  //
  //       if (match != null) {
  //         setState(() {
  //           _scannedImei = match.group(0)!;
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error: $e');
  //   } finally {
  //     _isProcessing = false;
  //   }
  // }
  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing || _cameraController == null) return;

    final now = DateTime.now();

    if (_lastProcessedTime != null && now.difference(_lastProcessedTime!).inMilliseconds < 300) {
      return;
    }

    _isProcessing = true;
    _lastProcessedTime = now;

    try {
      final inputImage = _convertImageOptimized(image);
      if (inputImage == null) return;

      final recognizedText = await _textRecognizer.processImage(inputImage);
      final RegExp imeiRegex = RegExp(r'\b\d{15,16}\b');

      final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
      final double imageWidth = isPortrait ? image.height.toDouble() : image.width.toDouble();
      final double imageHeight = isPortrait ? image.width.toDouble() : image.height.toDouble();

      final double frameTopInImage = imageHeight * 0.4;
      final double frameBottomInImage = imageHeight * 0.6;

      final List<TextLine> linesInFrame = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final rect = line.boundingBox;
          final double lineCenterY = rect.top + (rect.height / 2);
          if (lineCenterY >= frameTopInImage && lineCenterY <= frameBottomInImage) {
            linesInFrame.add(line);
          }
        }
      }

      if (linesInFrame.isNotEmpty) {
        linesInFrame.sort((a, b) => (a.boundingBox.top).compareTo(b.boundingBox.top));

        final cleanText = linesInFrame.first.text.replaceAll(RegExp(r'[\s-]'), '');
        final match = imeiRegex.firstMatch(cleanText);

        if (match != null) {
          final String foundImei = match.group(0)!;

          setState(() {
            _scannedImei = foundImei;
          });

          if (_cameraController != null && _cameraController!.value.isStreamingImages) {
            await _cameraController!.stopImageStream();
          }

          if (mounted) {
            context.pop(foundImei);
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (_scannedImei == 'point_at_IMEI'.tr()) {
        _isProcessing = false;
      }
    }
  }

  InputImage? _convertImageOptimized(CameraImage image) {
    if (_cameraController == null) return null;
    final sensorOrientation = _cameraController!.description.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (rotation == null || format == null || image.planes.isEmpty) return null;

    int totalBytes = 0;
    for (final plane in image.planes) {
      totalBytes += plane.bytes.length;
    }

    final Uint8List bytes = Uint8List(totalBytes);
    int offset = 0;
    for (final plane in image.planes) {
      bytes.setRange(offset, offset + plane.bytes.length, plane.bytes);
      offset += plane.bytes.length;
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(
          child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_cameraController!)),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: ThemeColors.primaryDark, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(
                  _scannedImei,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ThemeDimensions.paddingM, vertical: ThemeDimensions.paddingM),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.transparent),
                        child: const Icon(CupertinoIcons.arrow_left),
                      ),
                    ),
                    SizedBox(
                      width: ThemeDimensions.paddingM,
                    ),
                    Text(
                      'scan'.tr(),
                      style: ThemeTextStyles.titleMedium(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
