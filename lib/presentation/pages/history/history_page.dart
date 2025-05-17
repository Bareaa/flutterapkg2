import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/tarot_card.dart';
import '../../../data/repositories/cards_repository.dart';
import '../../../data/services/storage_service.dart';
import '../../widgets/common/starry_background.dart';
import '../../widgets/cards/card_detail_widget.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  final CardsRepository _cardsRepository = CardsRepository();
  late AnimationController _animationController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _selectedConsultation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final history = await StorageService.getHistory();
      
      // Ordenar por data (mais recente primeiro)
      history.sort((a, b) {
        final dateA = DateTime.parse(a['consultationDate'] as String);
        final dateB = DateTime.parse(b['consultationDate'] as String);
        return dateB.compareTo(dateA);
      });
      
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
          _selectedConsultation = history.isNotEmpty ? history.first : null;
        });
        
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF312E81),
        title: const Text(
          'Clear History',
          style: TextStyle(
            color: Color(0xFFFCD34D),
          ),
        ),
        content: const Text(
          'Are you sure you want to clear your consultation history? This action cannot be undone.',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await StorageService.clearHistory();
        
        if (mounted) {
          setState(() {
            _history = [];
            _selectedConsultation = null;
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('History cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing history: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _selectConsultation(Map<String, dynamic> consultation) {
    setState(() {
      _selectedConsultation = consultation;
    });
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
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
        title: const Text('Consultation History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFCD34D)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFFCD34D)),
              onPressed: _clearHistory,
              tooltip: 'Clear History',
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
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                    ),
                  )
                : _history.isEmpty
                    ? _buildEmptyView()
                    : _buildHistoryView(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history,
              color: Color(0xFFF59E0B),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'No consultations yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFCD34D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your consultation history will appear here after your first reading.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/consultation'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start a Consultation',
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

  Widget _buildHistoryView() {
    return Row(
      children: [
        // Sidebar with consultation list
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B).withOpacity(0.7),
            border: const Border(
              right: BorderSide(
                color: Color(0xFF6D28D9),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Your Readings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFCD34D),
                  ),
                ),
              ),
              
              // List of consultations
              Expanded(
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final consultation = _history[index];
                    final isSelected = _selectedConsultation != null && 
                                      _selectedConsultation!['id'] == consultation['id'];
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF312E81) 
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFF6D28D9).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          consultation['name'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFFFCD34D) : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _formatDate(consultation['consultationDate'] as String),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white70 : Colors.white54,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () => _selectConsultation(consultation),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Main content with selected consultation details
        Expanded(
          child: _selectedConsultation != null
              ? _buildConsultationDetails()
              : const Center(
                  child: Text(
                    'Select a consultation to view details',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildConsultationDetails() {
    final consultation = _selectedConsultation!;
    final selectedCardNumbers = List<int>.from(consultation['selectedCards'] as List);
    final selectedCards = _cardsRepository.getCardsByNumbers(selectedCardNumbers);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _animationController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              consultation['name'] as String,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFCD34D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${_formatDate(consultation['consultationDate'] as String)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Birth Date: ${consultation['birthDate'] as String}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            
            // Question
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFCD34D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    consultation['question'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Selected cards
            const Text(
              'Selected Cards',
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
                itemCount: selectedCards.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 120,
                      child: CardDetailWidget(
                        card: selectedCards[index],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Interpretation
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
              child: Text(
                consultation['interpretation'] as String,
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
  }
}