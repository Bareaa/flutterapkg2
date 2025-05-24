
class ConsultationData {
  final String name;
  final String birthDate;
  final String question;

  ConsultationData({
    required this.name,
    required this.birthDate,
    required this.question,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthDate': birthDate,
      'question': question,
    };
  }

  factory ConsultationData.fromJson(Map<String, dynamic> json) {
    return ConsultationData(
      name: json['name'],
      birthDate: json['birthDate'],
      question: json['question'],
    );
  }
}