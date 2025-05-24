
class TarotCard {
  final int number;
  final String name;
  final String description;
  final String element;
  final String representation;

  TarotCard({
    required this.number,
    required this.name,
    required this.description,
    required this.element,
    required this.representation,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'description': description,
      'element': element,
      'representation': representation,
    };
  }

  factory TarotCard.fromJson(Map<String, dynamic> json) {
    return TarotCard(
      number: json['number'],
      name: json['name'],
      description: json['description'],
      element: json['element'],
      representation: json['representation'],
    );
  }
}