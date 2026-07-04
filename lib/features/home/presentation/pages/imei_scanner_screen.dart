import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      setState(() => _errorMessage = 'Нужен доступ к камере');
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _errorMessage = 'Камеры не найдены');
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
      setState(() => _errorMessage = "Ошибка камеры: $e");
    }
  }

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
          setState(() {
            _scannedImei = match.group(0)!;
          });
        }
      }
    } catch (e) {
      debugPrint('Ошибка распознавания: $e');
    } finally {
      _isProcessing = false;
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

// class ImeiScannerScreen extends StatefulWidget {
//   const ImeiScannerScreen({super.key});
//
//   @override
//   State<ImeiScannerScreen> createState() => _ImeiScannerScreenState();
// }
//
// class _ImeiScannerScreenState extends State<ImeiScannerScreen> with WidgetsBindingObserver {
//   CameraController? _cameraController;
//   final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//   bool _isProcessing = false;
//   String _scannedImei = "Наведите на IMEI";
//   String _errorMessage = "";
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initCamera();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _cameraController?.dispose();
//     _textRecognizer.close();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) return;
//     if (state == AppLifecycleState.inactive) {
//       _cameraController?.dispose();
//     } else if (state == AppLifecycleState.resumed) {
//       _initCamera();
//     }
//   }
//
//   Future<void> _initCamera() async {
//     final status = await Permission.camera.request();
//     if (!status.isGranted) {
//       setState(() => _errorMessage = "Нужен доступ к камере");
//       return;
//     }
//
//     final cameras = await availableCameras();
//     if (cameras.isEmpty) {
//       setState(() => _errorMessage = "Камеры не найдены");
//       return;
//     }
//
//     _cameraController = CameraController(
//       cameras.first,
//       ResolutionPreset.max, // Максимальное разрешение для четкости мелкого шрифта
//       enableAudio: false,
//       imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
//     );
//
//     try {
//       await _cameraController!.initialize();
//
//       // Выставляем зум 2.5x сразу, чтобы держать трубу дальше от коробки
//       double minZoom = await _cameraController!.getMinZoomLevel();
//       double maxZoom = await _cameraController!.getMaxZoomLevel();
//       double desiredZoom = 2.5;
//       if (desiredZoom < minZoom) desiredZoom = minZoom;
//       if (desiredZoom > maxZoom) desiredZoom = maxZoom;
//       await _cameraController!.setZoomLevel(desiredZoom);
//
//       await _cameraController!.setFocusMode(FocusMode.auto);
//       await _cameraController!.startImageStream(_processImage);
//       if (mounted) setState(() {});
//     } catch (e) {
//       setState(() => _errorMessage = "Ошибка камеры: $e");
//     }
//   }
//
//   // Future<void> _processImage(CameraImage image) async {
//   //   if (_isProcessing || _cameraController == null) return;
//   //   _isProcessing = true;
//   //
//   //   try {
//   //     final inputImage = _convertImage(image);
//   //     if (inputImage == null) return;
//   //
//   //     final recognizedText = await _textRecognizer.processImage(inputImage);
//   //     final RegExp imeiRegex = RegExp(r'\b\d{15,16}\b');
//   //
//   //     // 1. Получаем реальные размеры кадра, который пришел с камеры
//   //     // В зависимости от поворота устройства ширина и высота могут меняться местами
//   //     final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
//   //     final double imageWidth = isPortrait ? image.height.toDouble() : image.width.toDouble();
//   //     final double imageHeight = isPortrait ? image.width.toDouble() : image.height.toDouble();
//   //
//   //     // 2. Рассчитываем, где в этом кадре находится наша центральная рамка.
//   //     // Допустим, рамка на экране занимает центральные 20% высоты кадра.
//   //     final double frameTopInImage = imageHeight * 0.4;
//   //     final double frameBottomInImage = imageHeight * 0.6;
//   //
//   //     List<TextLine> linesInFrame = [];
//   //
//   //     for (TextBlock block in recognizedText.blocks) {
//   //       for (TextLine line in block.lines) {
//   //         final rect = line.boundingBox;
//   //         if (rect != null) {
//   //           // 3. Проверяем: если центр строки текста лежит внутри нашей виртуальной рамки
//   //           final double lineCenterY = rect.top + (rect.height / 2);
//   //
//   //           if (lineCenterY >= frameTopInImage && lineCenterY <= frameBottomInImage) {
//   //             linesInFrame.add(line);
//   //           }
//   //         }
//   //       }
//   //     }
//   //
//   //     // 4. Если в рамку попало несколько строк (например, оба IMEI),
//   //     // сортируем их сверху вниз и берем строго ПЕРВЫЙ
//   //     if (linesInFrame.isNotEmpty) {
//   //       linesInFrame.sort((a, b) => (a.boundingBox?.top ?? 0).compareTo(b.boundingBox?.top ?? 0));
//   //
//   //       final cleanText = linesInFrame.first.text.replaceAll(RegExp(r'[\s-]'), '');
//   //       final match = imeiRegex.firstMatch(cleanText);
//   //
//   //       if (match != null) {
//   //         setState(() {
//   //           _scannedImei = match.group(0)!;
//   //         });
//   //       }
//   //     }
//   //   } catch (e) {
//   //     debugPrint("Ошибка сканирования в рамке: $e");
//   //   } finally {
//   //     _isProcessing = false;
//   //   }
//   // }
//
//
//   InputImage? _convertImage(CameraImage image) {
//     if (_cameraController == null) return null;
//     final sensorOrientation = _cameraController!.description.sensorOrientation;
//     final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
//     final format = InputImageFormatValue.fromRawValue(image.format.raw);
//
//     if (rotation == null || format == null || image.planes.isEmpty) return null;
//
//     final bytes = Uint8List.fromList(
//       image.planes.fold<List<int>>(<int>[], (prev, plane) => prev..addAll(plane.bytes)),
//     );
//
//     return InputImage.fromBytes(
//       bytes: bytes,
//       metadata: InputImageMetadata(
//         size: Size(image.width.toDouble(), image.height.toDouble()),
//         rotation: rotation,
//         format: format,
//         bytesPerRow: image.planes.first.bytesPerRow,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_errorMessage.isNotEmpty) {
//       return Scaffold(body: Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red))));
//     }
//
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(child: CameraPreview(_cameraController!)),
//           // Рамка-прицел под зум
//           Center(
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.8,
//               height: 70,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.blueAccent, width: 3),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//           // Вывод результата
//           Positioned(
//             bottom: 40, left: 20, right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 _scannedImei,
//                 style: const TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
//
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ImeiScannerScreen extends StatefulWidget {
//   const ImeiScannerScreen({super.key});
//
//   @override
//   State<ImeiScannerScreen> createState() => _ImeiScannerScreenState();
// }
//
// class _ImeiScannerScreenState extends State<ImeiScannerScreen> with WidgetsBindingObserver {
//   CameraController? _cameraController;
//   final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//   bool _isProcessing = false;
//   String _scannedImei = "Наведите на IMEI";
//   String _errorMessage = "";
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); // Следим за состоянием приложения
//     _requestPermissionAndInitCamera();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _stopCamera();
//     _textRecognizer.close();
//     super.dispose();
//   }
//
//   // Остановка камеры при сворачивании приложения
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final CameraController? cameraController = _cameraController;
//     if (cameraController == null || !cameraController.value.isInitialized) return;
//
//     if (state == AppLifecycleState.inactive) {
//       _stopCamera();
//     } else if (state == AppLifecycleState.resumed) {
//       _requestPermissionAndInitCamera();
//     }
//   }
//
//   Future<void> _stopCamera() async {
//     if (_cameraController != null) {
//       await _cameraController!.stopImageStream();
//       await _cameraController!.dispose();
//       _cameraController = null;
//     }
//   }
//
//   Future<void> _requestPermissionAndInitCamera() async {
//     setState(() => _errorMessage = ""); // Сброс ошибок
//
//     var status = await Permission.camera.request();
//     if (!status.isGranted) {
//       setState(() => _errorMessage = "Нужен доступ к камере.");
//       return;
//     }
//
//     final cameras = await availableCameras();
//     if (cameras.isEmpty) {
//       setState(() => _errorMessage = "Камеры не найдены.");
//       return;
//     }
//
//     // Используем максимальное разрешение для лучшей четкости
//     _cameraController = CameraController(
//       cameras.first,
//       ResolutionPreset.max, // Максимальное разрешение для лучшей детализации мелкого текста
//       enableAudio: false,
//       imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
//     );
//
//     try {
//       await _cameraController!.initialize();
//
//       // Настройка зума - пробуем установить зум 1.5, если возможно
//       double minZoom = await _cameraController!.getMinZoomLevel();
//       double maxZoom = await _cameraController!.getMaxZoomLevel();
//       double desiredZoom = 1.5;
//       if (desiredZoom < minZoom) desiredZoom = minZoom;
//       if (desiredZoom > maxZoom) desiredZoom = maxZoom;
//       await _cameraController!.setZoomLevel(desiredZoom);
//
//       await _cameraController!.startImageStream(_processCameraImage);
//       if (mounted) setState(() {});
//     } catch (e) {
//       setState(() => _errorMessage = "Ошибка камеры: $e");
//     }
//   }
//
//   Future<void> _processCameraImage(CameraImage image) async {
//     if (_isProcessing || _cameraController == null) return;
//     _isProcessing = true;
//
//     try {
//       final inputImage = _convertCameraImageToInputImage(image);
//       if (inputImage == null) {
//         _isProcessing = false;
//         return;
//       }
//
//       final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
//
//       // Регулярка для 15 цифр (IMEI) ИЛИ 16 цифр (IMEISV)
//       final RegExp imeiRegex = RegExp(r'\b\d{15,16}\b');
//
//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           // Очистка от пробелов и дефисов
//           final cleanText = line.text.replaceAll(RegExp(r'[\s-]'), '');
//
//           final match = imeiRegex.firstMatch(cleanText);
//           if (match != null) {
//             String found = match.group(0)!;
//             // Обновляем результат, если код новый
//             if (_scannedImei != found) {
//               setState(() {
//                 _scannedImei = found;
//               });
//             }
//             break; // Выходим из циклов, если код найден
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("Ошибка распознавания: $e");
//     } finally {
//       _isProcessing = false;
//     }
//   }
//
//   // Конвертация CameraImage в InputImage
//   InputImage? _convertCameraImageToInputImage(CameraImage image) {
//     if (_cameraController == null) return null;
//
//     final sensorOrientation = _cameraController!.description.sensorOrientation;
//
//     InputImageRotation? rotation;
//     if (Platform.isIOS) {
//       rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
//     } else if (Platform.isAndroid) {
//       rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
//     }
//     if (rotation == null) return null;
//
//     final format = InputImageFormatValue.fromRawValue(image.format.raw);
//     if (format == null) return null;
//
//     if (image.planes.isEmpty) return null;
//
//     // Сборка байтов изображения
//     final bytes = Uint8List.fromList(
//       image.planes.fold<List<int>>(<int>[], (List<int> previousValue, Plane plane) => previousValue..addAll(plane.bytes)),
//     );
//
//     return InputImage.fromBytes(
//       bytes: bytes,
//       metadata: InputImageMetadata(
//         size: Size(image.width.toDouble(), image.height.toDouble()),
//         rotation: rotation,
//         format: format,
//         bytesPerRow: image.planes.first.bytesPerRow,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_errorMessage.isNotEmpty) {
//       return Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(20), child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center))));
//     }
//
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Сканер IMEI')),
//       body: Stack(
//         children: [
//           Positioned.fill(child: CameraPreview(_cameraController!)),
//           // Рамка-прицел (размер адаптирован)
//           Center(
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.7, // Немного шире, чем раньше
//               height: 70, // Ниже, чем раньше
//               decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blueAccent, width: 3),
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]
//               ),
//             ),
//           ),
//           // Текст "Наведите..." над рамкой
//           Positioned(
//               top: MediaQuery.of(context).size.height * 0.38, // Адаптировано положение
//               left: 0, right: 0,
//               child: const Text("Разместите IMEI в рамке", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, backgroundColor: Colors.black45), textAlign: TextAlign.center,)
//           ),
//           // Панель результата снизу
//           Positioned(
//             bottom: 30, left: 20, right: 20,
//             child: Card(
//               elevation: 8,
//               color: Colors.black.withOpacity(0.85),
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text('Распознанный код:', style: TextStyle(color: Colors.grey, fontSize: 14)),
//                     const SizedBox(height: 10),
//                     SelectableText(
//                       _scannedImei,
//                       style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
//
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ImeiScannerScreen extends StatefulWidget {
//   const ImeiScannerScreen({super.key});
//
//   @override
//   State<ImeiScannerScreen> createState() => _ImeiScannerScreenState();
// }
//
// class _ImeiScannerScreenState extends State<ImeiScannerScreen> {
//   CameraController? _cameraController;
//   final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//   bool _isProcessing = false;
//   String _scannedImei = "Наведите камеру на IMEI";
//   bool _isCameraInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissionAndInitCamera();
//   }
//
//   // Запрос прав и инициализация камеры
//   Future<void> _requestPermissionAndInitCamera() async {
//     var status = await Permission.camera.request();
//     if (status.isGranted) {
//       final cameras = await availableCameras();
//       if (cameras.isEmpty) return;
//
//       // Используем заднюю камеру с оптимальным разрешением для текста
//       _cameraController = CameraController(
//         cameras.first,
//         ResolutionPreset.high,
//         enableAudio: false,
//         imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
//       );
//
//       try {
//         await _cameraController!.initialize();
//         // Запуск стрима кадров
//         await _cameraController!.startImageStream(_processCameraImage);
//         setState(() {
//           _isCameraInitialized = true;
//         });
//       } catch (e) {
//         debugPrint("Ошибка камеры: $e");
//       }
//     } else {
//       setState(() {
//         _scannedImei = "Доступ к камере запрещен";
//       });
//     }
//   }
//
//   // Обработка каждого кадра видеопотока
//   Future<void> _processCameraImage(CameraImage image) async {
//     if (_isProcessing) return;
//     _isProcessing = true;
//
//     try {
//       final inputImage = _convertCameraImageToInputImage(image);
//       if (inputImage == null) return;
//
//       final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
//
//       // Регулярное выражение для поиска IMEI (обычно это 15 цифр подряд)
//       final RegExp imeiRegex = RegExp(r'\b\d{15}\b');
//
//       for (TextBlock block in recognizedText.blocks) {
//         for (TextLine line in block.lines) {
//           final match = imeiRegex.firstMatch(line.text.replaceAll(' ', '')); // убираем пробелы, если они есть
//           if (match != null) {
//             setState(() {
//               _scannedImei = match.group(0)!;
//             });
//             // Здесь можно остановить стрим, если нужен только один IMEI:
//             // await _cameraController?.stopImageStream();
//             break;
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("Ошибка распознавания: $e");
//     } finally {
//       _isProcessing = false;
//     }
//   }
//
//   // Конвертация кадра камеры в формат для ML Kit
//   InputImage? _convertCameraImageToInputImage(CameraImage image) {
//     if (_cameraController == null) return null;
//
//     final camera = _cameraController!.description;
//     final sensorOrientation = camera.sensorOrientation;
//
//     // Определение ориентации
//     InputImageRotation? rotation;
//     if (Platform.isIOS) {
//       rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
//     } else if (Platform.isAndroid) {
//       var rotationCompensation = 0; // Предполагаем portrait
//       rotation = InputImageRotationValue.fromRawValue((sensorOrientation + rotationCompensation) % 360);
//     }
//
//     if (rotation == null) return null;
//
//     // Определение формата пикселей
//     final format = InputImageFormatValue.fromRawValue(image.format.raw);
//     if (format == null ||
//         (Platform.isAndroid && format != InputImageFormat.nv21) ||
//         (Platform.isIOS && format != InputImageFormat.bgra8888))
//       return null;
//
//     if (image.planes.isEmpty) return null;
//
//     // Сборка байтов
//     final WriteBuffer allBytes = WriteBuffer();
//     for (final Plane plane in image.planes) {
//       allBytes.putUint8List(plane.bytes);
//     }
//     final bytes = allBytes.done().buffer.asUint8List();
//
//     final metadata = InputImageMetadata(
//       size: Size(image.width.toDouble(), image.height.toDouble()),
//       rotation: rotation,
//       format: format,
//       bytesPerRow: image.planes.first.bytesPerRow,
//     );
//
//     return InputImage.fromBytes(bytes: bytes, metadata: metadata);
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _textRecognizer.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isCameraInitialized || _cameraController == null) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Сканер IMEI')),
//       body: Stack(
//         children: [
//           // Отображение превью камеры на весь экран
//           Positioned.fill(child: CameraPreview(_cameraController!)),
//           // Простая рамка-прицел по центру
//           Center(
//             child: Container(
//               width: 300,
//               height: 80,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.green, width: 3),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//           // Отображение найденного кода внизу экрана
//           Positioned(
//             bottom: 50,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               color: Colors.black.withOpacity(0.7),
//               child: Text(
//                 'IMEI: $_scannedImei',
//                 style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
