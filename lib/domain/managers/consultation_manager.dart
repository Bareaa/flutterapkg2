import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/consultation_data.dart';
import '../../data/models/consultation_history.dart';

/// Serviço de gerenciamento de consultas e armazenamento local
class ConsultationManager {
  static const String _consultationDataKey = 'consultation_data';
  static const String _selectedCardsKey = 'selected_cards';
  static const String _consultationHistoryKey = 'consultation_history';
  static const String _apiKey = 'google_api_key';

  /// Salva os dados da consulta atual
  static Future<void> saveConsultationData(ConsultationData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_consultationDataKey, jsonEncode(data.toJson()));
  }

  /// Recupera os dados da consulta atual
  static Future<ConsultationData?> getConsultationData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataJson = prefs.getString(_consultationDataKey);
    if (dataJson == null) return null;

    return ConsultationData.fromJson(jsonDecode(dataJson));
  }

  /// Salva as cartas selecionadas
  static Future<void> saveSelectedCards(List<int> cardNumbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCardsKey, jsonEncode(cardNumbers));
  }

  /// Recupera as cartas selecionadas
  static Future<List<int>> getSelectedCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getString(_selectedCardsKey);
    if (cardsJson == null) return [];

    final decodedList = jsonDecode(cardsJson) as List;
    return decodedList.map<int>((e) => e as int).toList();
  }

  /// Salva a chave da API
  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKey, apiKey);
  }

  /// Recupera a chave da API
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKey);
  }

  /// Salva uma nova entrada no histórico de consultas
  static Future<void> saveToHistory({
    required String name,
    required String birthDate,
    required String question,
    required List<int> selectedCards,
    required String interpretation,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_consultationHistoryKey);

    List<ConsultationHistory> history = [];

    if (historyJson != null) {
      final decodedList = jsonDecode(historyJson) as List;
      history = decodedList
          .map((item) => ConsultationHistory.fromJson(item))
          .toList();
    }

    final newConsultation = ConsultationHistory(
      id: 'consultation_${DateTime.now().millisecondsSinceEpoch}_${(Random().nextDouble() * 1000).toInt()}',
      name: name,
      birthDate: birthDate,
      question: question,
      selectedCards: selectedCards,
      interpretation: interpretation,
      consultationDate: DateTime.now(),
    );

    history.add(newConsultation);
    await prefs.setString(
      _consultationHistoryKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );
  }

  /// Recupera o histórico de consultas
  static Future<List<ConsultationHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_consultationHistoryKey);
    if (historyJson == null) return [];

    try {
      final decodedList = jsonDecode(historyJson) as List;
      return decodedList
          .map((item) => ConsultationHistory.fromJson(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Limpa o histórico de consultas
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consultationHistoryKey);
  }

  /// Limpa os dados da consulta atual
  static Future<void> clearConsultationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consultationDataKey);
    await prefs.remove(_selectedCardsKey);
  }
}
