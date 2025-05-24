import 'package:flutter/material.dart';
import 'dart:math';
import '../../../data/models/tarot_card.dart';
import '../../../data/repositories/cards_repository.dart';
import '../../../domain/managers/card_selection_manager.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/common/starry_background.dart';
import '../../widgets/cards/card_widget.dart';

class CardSelectionPage extends StatefulWidget {
  const CardSelectionPage({Key? key}) : super(key: key);

  @override
  _CardSelectionPageState createState() => _CardSelectionPageState();
}

class _CardSelectionPageState extends State<CardSelectionPage> with TickerProviderStateMixin {
  final CardSelectionManager _selectionManager = CardSelectionManager();
  final CardsRepository _cardsRepository = CardsRepository();
  late AnimationController _fadeController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
    
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cards = _cardsRepository.getShuffledCards();
      _selectionManager.setCards(cards);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading cards: ${e.toString()}';
        });
      }
    }
  }

  void _toggleCardSelection(int cardNumber) {
    final result = _selectionManager.toggleCardSelection(cardNumber);
    
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.red,
        ),
      );

      _shakeController.reset();
      _shakeController.forward();
    }
    
    setState(() {});
  }

  Future<void> _continueToResult() async {
    if (!_selectionManager.isSelectionComplete()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select 5 cards to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      await StorageService.saveSelectedCards(_selectionManager.selectedCards);
      
      if (mounted) {
        Navigator.pushNamed(context, '/result');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving selection: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha suas cartas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFCD34D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background
          const StarryBackground(),
          
          // Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingView()
                : _errorMessage.isNotEmpty
                    ? _buildErrorView()
                    : _buildCardSelectionView(),
          ),
        ],
      ),
      bottomNavigationBar: _isLoading || _errorMessage.isNotEmpty
          ? null
          : _buildBottomBar(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Shuffling the cards...',
            style: TextStyle(
              fontSize: 9,
              color: Color(0xFFFCD34D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFF59E0B),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFCD34D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCards,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSelectionView() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              FadeTransition(
                opacity: _fadeController,
                child: const Text(
                  'Select 5 cards that call to you',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFCD34D),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeController,
                child: Text(
                  'Selected: ${_selectionManager.selectedCards.length}/5',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        
        // Cards grid
        Expanded(
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  sin(_shakeAnimation.value * 3 * pi) * 5,
                  0,
                ),
                child: child,
              );
            },
            child: FadeTransition(
              opacity: _fadeController,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2/3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _selectionManager.cards.length,
                itemBuilder: (context, index) {
                  final card = _selectionManager.cards[index];
                  final isSelected = _selectionManager.isCardSelected(card.number);
                  
                  return CardWidget(
                    card: card,
                    selected: isSelected,
                    onTap: () => _toggleCardSelection(card.number),
                    index: index,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: ElevatedButton(
            onPressed: _selectionManager.isSelectionComplete() && !_isSaving
                ? _continueToResult
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: const Color(0xFFF59E0B),
              disabledBackgroundColor: const Color(0xFFF59E0B).withOpacity(0.3),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    _selectionManager.isSelectionComplete()
                        ? 'Continue to Reading'
                        : 'Select ${5 - _selectionManager.selectedCards.length} more cards',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
