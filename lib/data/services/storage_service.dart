import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/consultation_data.dart';

class StorageService {
  static const String _consultationDataKey = 'consultation_data';
  static const String _selectedCardsKey = 'selected_cards';
  static const String _consultationHistoryKey = 'consultation_history';
  static const String _apiKey = 'google_api_key';

  static Future<void> saveConsultationData(
    dynamic data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = jsonEncode(data is ConsultationData ? data.toJson() : data);
    await prefs.setString(_consultationDataKey, dataJson);
  }

  static Future<ConsultationData?> getConsultationData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getString(_consultationDataKey);
    
    if (dataJson == null) {
      return null;
    }
    
    final dataMap = jsonDecode(dataJson);
    return ConsultationData.fromJson(dataMap);
  }

  static Future<void> saveSelectedCards(
    List<int> cardNumbers,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCardsKey, jsonEncode(cardNumbers));
    // Limpa os índices selecionados ao salvar novas cartas
    await prefs.remove('selectedIdx');
  }

  static Future<List<int>> getSelectedCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getString(_selectedCardsKey);
    
    if (cardsJson == null) {
      return [];
    }
    
    final decodedList = jsonDecode(cardsJson) as List;
    return decodedList.map<int>((item) => item as int).toList();
  }

  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKey, apiKey);
  }

  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKey);
  }

  static Future<void> saveToHistory({
    required String name,
    required String birthDate,
    required String question,
    required List<int> selectedCards,
    required String interpretation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_consultationHistoryKey);
    
    List<Map<String, dynamic>> history = [];
    
    if (historyJson != null) {
      final decodedList = jsonDecode(historyJson) as List;
      history = decodedList
        .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
        .toList();
    }
    
    final newConsultation = {
      'id': 'consultation_${DateTime.now().millisecondsSinceEpoch}_${(Random().nextDouble() * 1000).toInt()}',
      'name': name,
      'birthDate': birthDate,
      'question': question,
      'selectedCards': selectedCards,
      'interpretation': interpretation,
      'consultationDate': DateTime.now().toIso8601String(),
    };
    
    history.add(newConsultation);
    await prefs.setString(_consultationHistoryKey, jsonEncode(history));
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_consultationHistoryKey);
    
    if (historyJson == null) {
      return [];
    }
    
    final decodedList = jsonDecode(historyJson) as List;
    return decodedList.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consultationHistoryKey);
  }

  static Future<void> clearConsultationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consultationDataKey);
    await prefs.remove(_selectedCardsKey);
    await prefs.remove('selectedIdx');
  }

  static Future<void> saveSelectedIndexes(List<int> idx) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'selectedIdx', idx.map((e) => e.toString()).toList());
  }

  static Future<List<int>> getSelectedIndexes() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('selectedIdx') ?? [];
    return list.map(int.parse).toList();
  }
}
