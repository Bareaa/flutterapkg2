import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/managers/consultation_manager.dart';
import '../../../data/services/storage_service.dart' as data_storage;
import '../../../data/models/consultation_data.dart';
import '../../widgets/common/starry_background.dart';



class ConsultationPage extends StatefulWidget {
  const ConsultationPage({Key? key}) : super(key: key);

  @override
  _ConsultationPageState createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _questionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  late AnimationController _animationController;
  final ConsultationManager _consultationManager = ConsultationManager();


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    
    // Verificar se já existem dados salvos
    _checkExistingData();
  }

  Future<void> _checkExistingData() async {
    final consultationData = await data_storage.StorageService.getConsultationData();
    if (consultationData != null) {
      setState(() {
        _nameController.text = consultationData.name;
        _questionController.text = consultationData.question;
        try {
          _selectedDate = DateTime.parse(consultationData.birthDate);
        } catch (e) {
          // Manter a data atual se o parsing falhar
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF59E0B),
              onPrimary: Colors.black,
              surface: Color(0xFF312E81),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1B4B),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final consultationData = ConsultationData(
          name: _nameController.text,
          birthDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
          question: _questionController.text,
        );
        
        // Salvar dados da consulta
        await ConsultationManager.saveConsultationData(consultationData);

        // Navegar para a tela de seleção de cartas
        if (mounted) {
          Navigator.pushNamed(context, '/card-selection');
        }
      } catch (e) {
        // Mostrar erro
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _questionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Consultation'),
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeTransition(
                  opacity: _animationController,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(_animationController),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Text(
                            'Tell us about yourself',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFCD34D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Fill in the information below to receive a personalized tarot reading.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Name field
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              labelStyle: const TextStyle(color: Colors.white70),
                              hintText: 'Enter your full name',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                              prefixIcon: const Icon(Icons.person, color: Color(0xFFF59E0B)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6D28D9)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6D28D9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF312E81).withOpacity(0.5),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Birth date field
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Birth Date',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  hintText: 'Select your birth date',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFF59E0B)),
                                  suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFFF59E0B)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF6D28D9)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFF6D28D9)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF312E81).withOpacity(0.5),
                                ),
                                controller: TextEditingController(
                                  text: DateFormat('dd/MM/yyyy').format(_selectedDate),
                                ),
                                style: const TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your birth date';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Question field
                          TextFormField(
                            controller: _questionController,
                            decoration: InputDecoration(
                              labelText: 'Your Question',
                              labelStyle: const TextStyle(color: Colors.white70),
                              hintText: 'What would you like to know?',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                              prefixIcon: const Icon(Icons.help_outline, color: Color(0xFFF59E0B)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6D28D9)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF6D28D9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF312E81).withOpacity(0.5),
                            ),
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your question';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          
                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: const Color(0xFFF59E0B).withOpacity(0.5),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Text(
                                      'Continue to Card Selection',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Tips
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
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: Color(0xFFFCD34D),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Tips for a good reading',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFCD34D),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildTipItem(
                                  'Be specific in your question for a more accurate reading.',
                                ),
                                _buildTipItem(
                                  'Focus on one issue at a time for clearer guidance.',
                                ),
                                _buildTipItem(
                                  'Avoid yes/no questions. Instead, ask "how" or "what" questions.',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}