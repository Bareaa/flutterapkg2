import '../../data/models/tarot_card.dart';

class SelectionResult {
  final bool success;
  final String message;
  
  SelectionResult({
    required this.success,
    required this.message,
  });
}

class CardSelectionManager {
  List<TarotCard> _cards = [];
  final List<int> _selectedCards = [];
  final int _cardLimit = 5;
  
  List<TarotCard> get cards => _cards;
  
  List<int> get selectedCards => _selectedCards;
  
  void setCards(List<TarotCard> newCards) {
    _cards = newCards;
  }
  

  SelectionResult toggleCardSelection(int cardNumber) {
    if (_selectedCards.contains(cardNumber)) {
      _selectedCards.remove(cardNumber);
      return SelectionResult(
        success: true,
        message: '',
      );
    }
    
    if (_selectedCards.length >= _cardLimit) {
      return SelectionResult(
        success: false,
        message: 'You have already selected $_cardLimit cards. Unselect one to select another.',
      );
    }
    
    _selectedCards.add(cardNumber);
    return SelectionResult(
      success: true,
      message: '',
    );
  }
  
  bool isCardSelected(int cardNumber) {
    return _selectedCards.contains(cardNumber);
  }
  
  void clearSelection() {
    _selectedCards.clear();
  }
  
  void setSelection(List<int> cards) {
    _selectedCards.clear();
    for (int i = 0; i < cards.length && i < _cardLimit; i++) {
      _selectedCards.add(cards[i]);
    }
  }
  
  bool isSelectionComplete() {
    return _selectedCards.length == _cardLimit;
  }
}