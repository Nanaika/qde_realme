import 'dart:io';
import 'dart:math' as math;

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
  final GlobalKey _scanWindowKey = GlobalKey();

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

  // Future<void> _processImage(CameraImage image) async {
  //   if (_isProcessing || _cameraController == null) return;
  //
  //   // Проверяем, что устройство в портретном режиме
  //   final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  //   if (!isPortrait) return;
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
  //     // Размеры экрана
  //     final screenSize = MediaQuery.of(context).size;
  //     final double screenWidth = screenSize.width;
  //     final double screenHeight = screenSize.height;
  //
  //     // Размеры изображения в портретном режиме (ширина и высота меняются местами)
  //     final double imageWidth = image.height.toDouble();
  //     final double imageHeight = image.width.toDouble();
  //
  //     // Расчет маштабирования CameraPreview (BoxFit.cover)
  //     final double scale = math.max(screenWidth / imageWidth, screenHeight / imageHeight);
  //     final double offsetX = (screenWidth - imageWidth * scale) / 2;
  //     final double offsetY = (screenHeight - imageHeight * scale) / 2;
  //
  //     // Параметры вашего контейнера из Scaffold/Stack
  //     final double containerWidth = screenWidth * 0.8;
  //     final double containerHeight = 70.0;
  //     final double containerLeft = (screenWidth - containerWidth) / 2;
  //     final double containerTop = (screenHeight - containerHeight) / 2;
  //     final double containerRight = containerLeft + containerWidth;
  //     final double containerBottom = containerTop + containerHeight;
  //
  //     // Переводим экранные координаты контейнера в координаты изображения
  //     final double frameLeftInImage = (containerLeft - offsetX) / scale;
  //     final double frameTopInImage = (containerTop - offsetY) / scale;
  //     final double frameRightInImage = (containerRight - offsetX) / scale;
  //     final double frameBottomInImage = (containerBottom - offsetY) / scale;
  //
  //     final List<TextLine> linesInFrame = [];
  //
  //     for (TextBlock block in recognizedText.blocks) {
  //       for (TextLine line in block.lines) {
  //         final rect = line.boundingBox;
  //         final double lineCenterX = rect.left + (rect.width / 2);
  //         final double lineCenterY = rect.top + (rect.height / 2);
  //
  //         // Проверяем, что центр текста находится внутри границ контейнера
  //         if (lineCenterX >= frameLeftInImage &&
  //             lineCenterX <= frameRightInImage &&
  //             lineCenterY >= frameTopInImage &&
  //             lineCenterY <= frameBottomInImage) {
  //           linesInFrame.add(line);
  //         }
  //       }
  //     }
  //
  //     if (linesInFrame.isNotEmpty) {
  //       linesInFrame.sort((a, b) => (a.boundingBox.top).compareTo(b.boundingBox.top));
  //
  //       final cleanText = linesInFrame.first.text.replaceAll(RegExp(r'[\s-]'), '');
  //       final match = imeiRegex.firstMatch(cleanText);
  //
  //       if (match != null) {
  //         final String foundImei = match.group(0)!;
  //
  //         setState(() {
  //           _scannedImei = foundImei;
  //         });
  //
  //         if (_cameraController != null && _cameraController!.value.isStreamingImages) {
  //           await _cameraController!.stopImageStream();
  //         }
  //
  //         if (mounted) {
  //           context.pop(foundImei);
  //         }
  //         return;
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error: $e');
  //   } finally {
  //     if (_scannedImei == 'point_at_IMEI'.tr()) {
  //       _isProcessing = false;
  //     }
  //   }
  // }
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
  //       linesInFrame.sort((a, b) => (a.boundingBox.top).compareTo(b.boundingBox.top));
  //
  //       final cleanText = linesInFrame.first.text.replaceAll(RegExp(r'[\s-]'), '');
  //       final match = imeiRegex.firstMatch(cleanText);
  //
  //       if (match != null) {
  //         final String foundImei = match.group(0)!;
  //
  //         setState(() {
  //           _scannedImei = foundImei;
  //         });
  //
  //         if (_cameraController != null && _cameraController!.value.isStreamingImages) {
  //           await _cameraController!.stopImageStream();
  //         }
  //
  //         if (mounted) {
  //           context.pop(foundImei);
  //         }
  //         return;
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error: $e');
  //   } finally {
  //     if (_scannedImei == 'point_at_IMEI'.tr()) {
  //       _isProcessing = false;
  //     }
  //   }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    print('===============  ${status}');

    if (!status.isGranted) {
      setState(() => _errorMessage = 'needCameraPermission'.tr());
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _errorMessage = 'cameraNotFound'.tr());
      return;
    }

    // 1. Берем заднюю камеру явно (cameras.first не всегда задняя на iOS)
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high, // Заменил max на high, чтобы iOS не захлебывалась в стриме
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    try {
      await _cameraController!.initialize();

      // 2. Сначала ставим стрим и обновляем UI
      await _cameraController!.startImageStream(_processImage);
      if (mounted) setState(() {});

      // 3. Зум и фокус настраиваем ПОСЛЕ того, как камера уже погнала кадры
      final double minZoom = await _cameraController!.getMinZoomLevel();
      final double maxZoom = await _cameraController!.getMaxZoomLevel();
      double desiredZoom = 2.5;
      if (desiredZoom < minZoom) desiredZoom = minZoom;
      if (desiredZoom > maxZoom) desiredZoom = maxZoom;

      await _cameraController!.setZoomLevel(desiredZoom);
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      print('ОШИБКА КАМЕРЫ IOS: $e');
      setState(() => _errorMessage = '${'cameraError'.tr()}: $e');
    }
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing || _cameraController == null) return;

    // Жесткий блок: работаем ТОЛЬКО в стандартном портретном режиме
    final orientation = MediaQuery.of(context).orientation;
    if (orientation != Orientation.portrait) return;

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

      // Берем точные координаты рамки сканера с экрана
      final RenderBox? renderBox = _scanWindowKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final Offset containerOffset = renderBox.localToGlobal(Offset.zero);
      final Size containerSize = renderBox.size;
      final Size screenSize = MediaQuery.of(context).size;

      // Учет масштабирования камеры под экран (BoxFit.cover)
      // final double cameraAspectRatio = _cameraController!.value.aspectRatio;
      // final double previewAspectRatio = 1 / cameraAspectRatio; // В портрете инвертируем
      // final double screenAspectRatio = screenSize.width / screenSize.height;
      //
      // double scaleX = 1.0;
      // double scaleY = 1.0;
      // double offsetX = 0.0;
      // double offsetY = 0.0;
      //
      // if (previewAspectRatio > screenAspectRatio) {
      //   scaleX = previewAspectRatio / screenAspectRatio;
      //   offsetX = (scaleX - 1.0) / 2.0;
      // } else {
      //   scaleY = screenAspectRatio / previewAspectRatio;
      //   offsetY = (scaleY - 1.0) / 2.0;
      // }
      //
      // // Перевод координат рамки в процентные от 0.0 до 1.0
      // final double normLeft = (containerOffset.dx / screenSize.width) * scaleX - offsetX;
      // final double normTop = (containerOffset.dy / screenSize.height) * scaleY - offsetY;
      // final double normRight = ((containerOffset.dx + containerSize.width) / screenSize.width) * scaleX - offsetX;
      // final double normBottom = ((containerOffset.dy + containerSize.height) / screenSize.height) * scaleY - offsetY;
      //
      // // Размеры повернутого кадра в ML Kit (в портрете height = width изображения)
      // final double imageWidth = image.height.toDouble();
      // final double imageHeight = image.width.toDouble();
      //
      // final double frameLeft = normLeft * imageWidth;
      // final double frameTop = normTop * imageHeight;
      // final double frameRight = normRight * imageWidth;
      // final double frameBottom = normBottom * imageHeight;

      // Размер изображения в portrait
      final double imageWidth = image.height.toDouble();
      final double imageHeight = image.width.toDouble();

      // Размер экрана
      final double screenWidth = screenSize.width;
      final double screenHeight = screenSize.height;

      // CameraPreview работает как BoxFit.cover
      final double scale = math.max(
        screenWidth / imageWidth,
        screenHeight / imageHeight,
      );

      // Реальный размер изображения после масштабирования
      final double displayedWidth = imageWidth * scale;
      final double displayedHeight = imageHeight * scale;

      // Что было обрезано CameraPreview
      final double cropX = (displayedWidth - screenWidth) / 2.0;

      final double cropY = (displayedHeight - screenHeight) / 2.0;

      // Координаты РАМКИ на экране
      // переводим непосредственно в координаты изображения
      final double frameLeft = (containerOffset.dx + cropX) / scale;

      final double frameTop = (containerOffset.dy + cropY) / scale;

      final double frameRight = (containerOffset.dx + containerSize.width + cropX) / scale;

      final double frameBottom = (containerOffset.dy + containerSize.height + cropY) / scale;

      final List<TextLine> linesInFrame = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final rect = line.boundingBox;
          final double lineCenterX = rect.left + (rect.width / 2);
          final double lineCenterY = rect.top + (rect.height / 2);

          // Попадание строго внутрь рамки
          if (lineCenterX >= frameLeft &&
              lineCenterX <= frameRight &&
              lineCenterY >= frameTop &&
              lineCenterY <= frameBottom) {
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
    // }

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
              key: _scanWindowKey,
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
