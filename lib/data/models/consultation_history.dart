class ConsultationHistory {
  final String id;
  final String name;
  final String birthDate;
  final String question;
  final List<int> selectedCards;
  final String interpretation;
  final DateTime consultationDate;

  ConsultationHistory({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.question,
    required this.selectedCards,
    required this.interpretation,
    required this.consultationDate,
  });

  factory ConsultationHistory.fromJson(Map<String, dynamic> json) {
    return ConsultationHistory(
      id: json['id'],
      name: json['name'],
      birthDate: json['birthDate'],
      question: json['question'],
      selectedCards: List<int>.from(json['selectedCards']),
      interpretation: json['interpretation'],
      consultationDate: DateTime.parse(json['consultationDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'question': question,
      'selectedCards': selectedCards,
      'interpretation': interpretation,
      'consultationDate': consultationDate.toIso8601String(),
    };
  }
}
