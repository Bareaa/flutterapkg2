import '../models/tarot_card.dart';
import '../../constants/cards_data.dart';

class CardsRepository {
  List<TarotCard> getAllCards() {
    return tarotCards;
  }
  
  TarotCard? getCardByNumber(int number) {
    try {
      return tarotCards.firstWhere(
        (card) => card.number == number,
        orElse: () => TarotCard(
          number: number,
          name: "Card $number",
          description: "Description not available",
          element: "Unknown",
          representation: "Unknown",
        ),
      );
    } catch (e) {
      return null;
    }
  }
  
  List<TarotCard> getCardsByNumbers(List<int> numbers) {
    List<TarotCard> cards = [];
    
    for (final number in numbers) {
      final card = getCardByNumber(number);
      if (card != null) {
        cards.add(card);
      }
    }
    
    return cards;
  }

  List<TarotCard> getCardsByElement(String element) {
    return tarotCards.where((card) => card.element == element).toList();
  }

  List<TarotCard> getShuffledCards() {
    final cards = List<TarotCard>.from(tarotCards);
    cards.shuffle();
    return cards;
  }
}