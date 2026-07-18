import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

class ImeiScannerScreen extends StatefulWidget {
  const ImeiScannerScreen({super.key});

  @override
  State<ImeiScannerScreen> createState() => _ImeiScannerScreenState();
}

class _ImeiScannerScreenState extends State<ImeiScannerScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _isProcessing = false;
  String _scannedImei = 'Наведите на IMEI';
  String _errorMessage = "";

  // Переменная для контроля времени между кадрами
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
      setState(() => _errorMessage = 'Need camera permission');
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _errorMessage = 'Camera not found');
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

      double minZoom = await _cameraController!.getMinZoomLevel();
      double maxZoom = await _cameraController!.getMaxZoomLevel();
      double desiredZoom = 2.5;
      if (desiredZoom < minZoom) desiredZoom = minZoom;
      if (desiredZoom > maxZoom) desiredZoom = maxZoom;
      await _cameraController!.setZoomLevel(desiredZoom);

      await _cameraController!.setFocusMode(FocusMode.auto);
      await _cameraController!.startImageStream(_processImage);
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _errorMessage = "Camera error: $e");
    }
  }

  // Future<void> _processImage(CameraImage image) async {
  //   if (_isProcessing || _cameraController == null) return;
  //
  //   final now = DateTime.now();
  //   // ОПТИМИЗАЦИЯ 1: Обрабатываем кадр только если прошло больше 300 мс с прошлой попытки
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
    // ОПТИМИЗАЦИЯ 1: Обрабатываем кадр только если прошло больше 300 мс с прошлой попытки
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
        linesInFrame.sort((a, b) => (a.boundingBox.top ?? 0).compareTo(b.boundingBox.top ?? 0));

        final cleanText = linesInFrame.first.text.replaceAll(RegExp(r'[\s-]'), '');
        final match = imeiRegex.firstMatch(cleanText);

        if (match != null) {
          final String foundImei = match.group(0)!;

          setState(() {
            _scannedImei = foundImei;
          });

          // Выключаем камеру перед выходом
          if (_cameraController != null && _cameraController!.value.isStreamingImages) {
            await _cameraController!.stopImageStream();
          }

          if (mounted) {
            context.pop(foundImei); // Возвращает значение назад через go_router
          }
          return; // Уходим сразу, не сбрасывая _isProcessing
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      // Сбрасываем флаг для следующего кадра только если IMEI еще не нашли
      if (_scannedImei == 'Наведите на IMEI') {
        _isProcessing = false;
      }
    }
  }

  // ОПТИМИЗАЦИЯ 2: Быстрая склейка байтов через выделение буфера под общий размер кадра
  InputImage? _convertImageOptimized(CameraImage image) {
    if (_cameraController == null) return null;
    final sensorOrientation = _cameraController!.description.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    if (rotation == null || format == null || image.planes.isEmpty) return null;

    // Считаем общий размер всех плоскостей заранее
    int totalBytes = 0;
    for (final plane in image.planes) {
      totalBytes += plane.bytes.length;
    }

    // Выделяем память один раз и копируем напрямую
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
                border: Border.all(color: Colors.blueAccent, width: 3),
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
              child: Text(
                _scannedImei,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
