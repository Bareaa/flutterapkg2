import '../../data/models/tarot_card.dart';

/// Resultado da operação de alternar seleção
class SelectionResult {
  final bool success;
  final String message;
  
  SelectionResult({
    required this.success,
    required this.message,
  });
}

/// Gerenciador de seleção de cartas
/// 
/// Responsável por gerenciar o estado e operações relacionadas à seleção de cartas
class CardSelectionManager {
  List<TarotCard> _cards = [];
  final List<int> _selectedCards = [];
  final int _cardLimit = 5;
  
  /// Obtém a lista de cartas
  List<TarotCard> get cards => _cards;
  
  /// Obtém a lista de cartas selecionadas (números)
  List<int> get selectedCards => _selectedCards;
  
  /// Define a lista de cartas
  void setCards(List<TarotCard> newCards) {
    _cards = newCards;
  }
  
  /// Alterna a seleção de uma carta
  /// 
  /// Retorna um objeto SelectionResult com o resultado da operação
  SelectionResult toggleCardSelection(int cardNumber) {
    // Se a carta já está selecionada, remover da seleção
    if (_selectedCards.contains(cardNumber)) {
      _selectedCards.remove(cardNumber);
      return SelectionResult(
        success: true,
        message: '',
      );
    }
    
    // Se já atingiu o limite de cartas, não permitir nova seleção
    if (_selectedCards.length >= _cardLimit) {
      return SelectionResult(
        success: false,
        message: 'You have already selected $_cardLimit cards. Unselect one to select another.',
      );
    }
    
    // Adicionar carta à seleção
    _selectedCards.add(cardNumber);
    return SelectionResult(
      success: true,
      message: '',
    );
  }
  
  /// Verifica se uma carta está selecionada
  bool isCardSelected(int cardNumber) {
    return _selectedCards.contains(cardNumber);
  }
  
  /// Limpa a seleção de cartas
  void clearSelection() {
    _selectedCards.clear();
  }
  
  /// Define uma seleção de cartas
  void setSelection(List<int> cards) {
    _selectedCards.clear();
    // Adiciona somente até o limite permitido
    for (int i = 0; i < cards.length && i < _cardLimit; i++) {
      _selectedCards.add(cards[i]);
    }
  }
  
  /// Verifica se já selecionou o número correto de cartas
  bool isSelectionComplete() {
    return _selectedCards.length == _cardLimit;
  }
}