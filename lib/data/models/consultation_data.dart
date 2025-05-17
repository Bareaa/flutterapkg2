/// Modelo de dados de consulta
/// 
/// Armazena informações sobre a consulta do usuário
class ConsultationData {
  /// Nome do consulente
  final String name;
  
  /// Data de nascimento do consulente (formato ISO: YYYY-MM-DD)
  final String birthDate;
  
  /// Pergunta do consulente
  final String question;

  /// Construtor
  ConsultationData({
    required this.name,
    required this.birthDate,
    required this.question,
  });

  /// Converte objeto para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthDate': birthDate,
      'question': question,
    };
  }

  /// Cria objeto a partir de JSON
  factory ConsultationData.fromJson(Map<String, dynamic> json) {
    return ConsultationData(
      name: json['name'],
      birthDate: json['birthDate'],
      question: json['question'],
    );
  }
}