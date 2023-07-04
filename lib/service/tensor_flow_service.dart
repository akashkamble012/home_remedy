import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TensorFlowService {
  late Interpreter _interpreter;

  TensorFlowService._(Interpreter interpreter) : _interpreter = interpreter;

  static Future<TensorFlowService> create() async {
    ByteData modelData = await rootBundle.load('assets/model.tflite');
    InterpreterOptions options = InterpreterOptions()..threads = 2; // Adjust the number of threads if needed
    Interpreter interpreter = Interpreter.fromBuffer(modelData.buffer.asUint8List(), options: options);
    return TensorFlowService._(interpreter);
  }

  Future<void> close() async {
    if (_interpreter != null) {
      _interpreter.close();
    }
  }

  Future<String> predictEffectiveness(List<String> userIngredients, List<String> userSymptoms) async {
    List<String> allCombinations = [];

    for (String symptom in userSymptoms) {
      for (String ingredient in userIngredients) {
        String combination = '$ingredient|$symptom';
        allCombinations.add(combination);
      }
    }

    List<List<double>> input = allCombinations.map((s) => s.codeUnits.map((c) => c.toDouble()).toList()).toList();
    print('Print INPUT : $input');
    try {
      var output = List<double>.filled(1, 0.0);
      _interpreter.run(input, output);
      double prediction = output[0];

      if (prediction >= 0.5) {
        return 'Effective';
      } else {
        return 'Not Effective';
      }
    } catch (e) {
      print('Error running TensorFlow Lite model: $e');
      return 'Unknown';
    }
  }
}
