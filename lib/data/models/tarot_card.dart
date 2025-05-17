/// Modelo de carta de tarô
/// 
/// Armazena informações sobre uma carta de tarô
class TarotCard {
  /// Número da carta
  final int number;
  
  /// Nome da carta
  final String name;
  
  /// Descrição da carta
  final String description;
  
  /// Elemento da carta (Ar, Fire, Water, Earth)
  final String element;
  
  /// Representação da carta
  final String representation;

  /// Construtor
  TarotCard({
    required this.number,
    required this.name,
    required this.description,
    required this.element,
    required this.representation,
  });

  /// Converte objeto para JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'description': description,
      'element': element,
      'representation': representation,
    };
  }

  /// Cria objeto a partir de JSON
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