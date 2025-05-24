import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/consultation_data.dart';
import '../../../data/models/tarot_card.dart';
import '../../../data/repositories/cards_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../widgets/common/starry_background.dart';
import '../../../widgets/common/loading_effect.dart';
import '../../../widgets/cards/card_detail_widget.dart';
// Make sure the import path is correct and that CardDetailWidget is defined in this file.

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with SingleTickerProviderStateMixin {
  final CardsRepository _cardsRepository = CardsRepository();
  late AnimationController _animationController;
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  
  ConsultationData? _consultationData;
  List<TarotCard> _selectedCards = [];
  String _interpretation = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });
    
    try {
      final consultationData = await StorageService.getConsultationData();
      if (consultationData == null) {
        throw Exception('Consultation data not found');
      }
      
      final selectedCardNumbers = await StorageService.getSelectedCards();
      if (selectedCardNumbers.isEmpty) {
        throw Exception('No cards selected');
      }
      
      final selectedCards = _cardsRepository.getCardsByNumbers(selectedCardNumbers);
      
      final interpretation = await ApiService.interpretCards(
        consultationData,
        selectedCards,
      );
      
      await StorageService.saveToHistory(
        name: consultationData.name,
        birthDate: consultationData.birthDate,
        question: consultationData.question,
        selectedCards: selectedCardNumbers,
        interpretation: interpretation,
      );
      
      if (mounted) {
        setState(() {
          _consultationData = consultationData;
          _selectedCards = selectedCards;
          _interpretation = interpretation;
          _isLoading = false;
        });
        
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _shareReading() {
    if (_consultationData == null) return;
    
    final cardNames = _selectedCards.map((card) => card.name).join(', ');
    
    final text = '''
🔮 Tarot Reading for ${_consultationData!.name} 🔮

Question: ${_consultationData!.question}

Cards: $cardNames

Interpretation:
${_interpretation.split('\n').take(3).join('\n')}...

Get your own reading with the Mystic Tarology app!
''';
    
    Share.share(text);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reading'),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Color(0xFFFCD34D)),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          ),
        ),
        actions: [
          if (!_isLoading && !_isError)
            IconButton(
              icon: const Icon(Icons.share, color: Color(0xFFFCD34D)),
              onPressed: _shareReading,
              tooltip: 'Share Reading',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          const StarryBackground(),
          
          // Content
          SafeArea(
            child: _isLoading
                ? _buildLoadingView()
                : _isError
                    ? _buildErrorView()
                    : _buildResultView(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingEffect(
            size: 120,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 24),
          const Text(
            'Consulting the cards...',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFFFCD34D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait while we interpret your reading',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
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
            const Text(
              'Something went wrong',
              style: TextStyle(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadData,
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
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                  ),
                  child: const Text(
                    'Go Home',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.1),
                  end: Offset.zero,
                ).animate(_animationController),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reading for ${_consultationData?.name}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFCD34D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Question: ${_consultationData?.question}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_animationController),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Selected Cards',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFCD34D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedCards.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: SizedBox(
                              width: 120,
                              child: CardDetailWidget(
                                card: _selectedCards[index],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_animationController),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interpretation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFCD34D),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF312E81).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFCD34D).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: _buildMarkdownText(_interpretation),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            FadeTransition(
              opacity: _animationController,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/'),
                    icon: const Icon(
                      Icons.home,
                      color: Colors.black,
                    ),
                    label: const Text(
                      'New Reading',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    icon: const Icon(
                      Icons.history,
                      color: Color(0xFFF59E0B),
                    ),
                    label: const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFFF59E0B)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownText(String text) {
    final lines = text.split('\n');
    final widgets = <Widget>[];
    
    for (final line in lines) {
      if (line.startsWith('# ')) {
        // Heading 1
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line.substring(2),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFCD34D),
              ),
            ),
          ),
        );
      } else if (line.startsWith('## ')) {
        // Heading 2
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              line.substring(3),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFCD34D),
              ),
            ),
          ),
        );
      } else if (line.startsWith('### ')) {
        // Heading 3
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              line.substring(4),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFCD34D),
              ),
            ),
          ),
        );
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        // List item
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•',
                  style: TextStyle(
                    color: Color(0xFFFCD34D),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.startsWith('1. ') || line.startsWith('2. ') || line.startsWith('3. ')) {
        final number = line.substring(0, line.indexOf('.'));
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number.',
                  style: const TextStyle(
                    color: Color(0xFFFCD34D),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    line.substring(line.indexOf('.') + 2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line.isEmpty) {
        // Empty line
        widgets.add(const SizedBox(height: 8));
      } else {
        // Regular paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}