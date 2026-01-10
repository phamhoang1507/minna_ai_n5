import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/alphabet_model.dart';

class AlphabetRepository {
  Future<List<AlphabetModel>> loadHiragana() async {
    final jsonString = await rootBundle.loadString('assets/jsons/hiragana.json');
    final List data = json.decode(jsonString);
    return data.map((e) => AlphabetModel.fromJson(e)).toList();
  }

  Future<List<AlphabetModel>> loadKatakana() async {
    final jsonString = await rootBundle.loadString('assets/jsons/katakana.json');
    final List data = json.decode(jsonString);
    return data.map((e) => AlphabetModel.fromJson(e)).toList();
  }
}
