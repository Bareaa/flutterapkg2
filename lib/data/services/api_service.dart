import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/consultation_data.dart';
import '../models/tarot_card.dart';

class ApiService {

  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-2.0-flash:generateContent?key=AIzaSyAOGuUI4ecvivH3LaMaAUyD_z3pey0yCTU';

  static Future<String> interpretCards(
    ConsultationData consultation,
    List<TarotCard> cards,
  ) async {
    final prompt = _generateInterpretationPrompt(consultation, cards);

    try {
      final res = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (res.statusCode != 200) {
        throw Exception(
          _parseError(res.statusCode, res.reasonPhrase, res.body),
        );
      }

      final data = jsonDecode(res.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (text == null || (text as String).trim().isEmpty) {
        throw Exception('Resposta vazia ou formato inesperado da IA.');
      }

      return text.toString().trim();
    } on SocketException {
      // Sem internet → fallback
      return _generateOfflineInterpretation(consultation, cards);
    }
  }

  static String _parseError(int code, String? phrase, String rawBody) {
    try {
      final body = jsonDecode(rawBody);
      return body['error']?['message'] ??
          'Erro $code: ${phrase ?? 'desconhecido'}';
    } catch (_) {
      return 'Erro $code: ${phrase ?? 'desconhecido'}';
    }
  }

  static String _generateOfflineInterpretation(
    ConsultationData consultation,
    List<TarotCard> cards,
  ) {
    final dom = _identifyDominantElements(cards);
    final reps = cards.map((c) => c.representation).join(', ');

    return '''
# Interpretação para ${consultation.name}

(Sem internet — resposta offline.)

Cartas: $reps
Pergunta: "${consultation.question}"

Há predominância do elemento ${dom.isNotEmpty ? dom.first : 'variado'}.
${_getElementMeaning(dom.isNotEmpty ? dom.first : 'variado')}

${_generateBasicResponse(consultation.question, cards)}
''';
  }

  static List<String> _identifyDominantElements(List<TarotCard> cards) {
    final Map<String, int> count = {};
    for (final c in cards) {
      count[c.element] = (count[c.element] ?? 0) + 1;
    }
    final sorted = count.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }

  static String _getElementMeaning(String e) {
    switch (e) {
      case 'Ar':
        return 'momento de clareza mental e comunicação.';
      case 'Fire':
        return 'energia de paixão e transformação.';
      case 'Water':
        return 'emoções e intuição em destaque.';
      case 'Earth':
        return 'foco em questões práticas e materiais.';
      default:
        return 'equilíbrio de diferentes energias.';
    }
  }


  static String _generateBasicResponse(String question, List<TarotCard> cards) {
    final cardNames = cards.map((c) => c.name).join(', ');
    return 'Com base nas cartas sorteadas ($cardNames), a resposta à sua pergunta "$question" sugere reflexão e análise sobre o momento atual. Confie em sua intuição e busque equilíbrio nas decisões.';
  }

  static String _generateInterpretationPrompt(
    ConsultationData data,
    List<TarotCard> cards,
  ) {
    return '''
Você é um tarólogo experiente. Sua missão é fornecer uma interpretação direta e objetiva para a pergunta do consulente, baseada nas cartas selecionadas.

CONSULENTE
Nome: ${data.name}
Data de Nascimento: ${data.birthDate}
Pergunta: "${data.question}"

CARTAS
${cards.map((c) => '${c.number}. ${c.name} (${c.element}) - ${c.representation}').join('\n')}

Instruções:
1. Responda à pergunta com base nos significados das cartas.
2. Explique a conexão entre as cartas.
3. Dê 2-3 orientações práticas.

Seja claro, sem enrolar (máximo 600 palavras).
''';
  }
}