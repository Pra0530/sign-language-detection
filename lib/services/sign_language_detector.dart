import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import '../models/translation_result.dart';

class SignLanguageDetector {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  final int _inputSize = 28; // 28x28 grayscale image

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load model
      _interpreter = await Interpreter.fromAsset('assets/ml/asl_alphabet.tflite');
      
      // Load labels
      final labelData = await rootBundle.loadString('assets/ml/asl_labels.txt');
      _labels = labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();

      if (_labels.length != 26) {
        developer.log('Warning: Expected 26 labels, found ${_labels.length}');
      }

      _isInitialized = true;
      developer.log('ML Model loaded successfully.');
    } catch (e) {
      developer.log('Failed to load ML model: $e');
    }
  }

  void dispose() {
    _interpreter?.close();
  }

  Future<TranslationResult?> processFrame(CameraImage image) async {
    if (!_isInitialized || _interpreter == null) return null;

    try {
      // 1. Convert CameraImage to image package Image
      img.Image processedImage = _convertCameraImage(image);

      // 2. Resize to 28x28 and convert to grayscale tensor
      img.Image resized = img.copyResize(processedImage, width: _inputSize, height: _inputSize);
      
      // Expected shape: [1, 28, 28, 1] FLOAT32
      var inputTensor = List.generate(
        1,
        (i) => List.generate(
          _inputSize,
          (y) => List.generate(
            _inputSize,
            (x) {
              final pixel = resized.getPixelSafe(x, y);
              // Normalize to 0-1
              final luminance = (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114) / 255.0;
              return [luminance];
            },
          ),
        ),
      );

      // 3. Output shape: [1, 26] FLOAT32
      var outputTensor = List.generate(1, (i) => List.filled(26, 0.0));

      // 4. Run inference
      _interpreter!.run(inputTensor, outputTensor);

      // 5. Process results
      final probabilities = outputTensor[0];
      
      double highestProb = 0.0;
      int highestIdx = -1;
      
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > highestProb) {
          highestProb = probabilities[i];
          highestIdx = i;
        }
      }

      if (highestIdx != -1 && highestIdx < _labels.length) {
        return TranslationResult(
          letter: _labels[highestIdx],
          confidence: highestProb,
          isStable: false, // Will be managed by the UI
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      developer.log('Error processing frame for ML: $e');
    }

    return null;
  }

  // Convert Platform specific camera image to img.Image
  img.Image _convertCameraImage(CameraImage image) {
    if (Platform.isAndroid) {
      return _convertYUV420(image);
    } else {
      return _convertBGRA8888(image);
    }
  }

  img.Image _convertBGRA8888(CameraImage image) {
    const format = img.Format.uint8;
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      rowStride: image.planes[0].bytesPerRow,
      bytesOffset: image.planes[0].bytes.offsetInBytes,
      order: img.ChannelOrder.bgra,
      format: format,
    );
  }

  img.Image _convertYUV420(CameraImage image) {
    // simplified YUV420 to RGB conversion just picking Y channel as mostly grayscale needed
    final int width = image.width;
    final int height = image.height;
    
    // creating a simple grayscale image from the Y plane directly
    final img.Image gsImage = img.Image(width: width, height: height, numChannels: 1);
    
    final yPlane = image.planes[0];
    final yBuffer = yPlane.bytes;
    final yRowStride = yPlane.bytesPerRow;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixelIndex = y * yRowStride + x;
        if (pixelIndex < yBuffer.length) {
          gsImage.setPixelRgb(x, y, yBuffer[pixelIndex], yBuffer[pixelIndex], yBuffer[pixelIndex]);
        }
      }
    }
    return gsImage;
  }
}
