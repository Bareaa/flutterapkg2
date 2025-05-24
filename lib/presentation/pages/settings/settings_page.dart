import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tarologia_mistica/widgets/common/starry_background.dart';
import '../../../data/services/storage_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  final _apiKeyController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _showApiKey = false;
  late AnimationController _animationController;
  String? _currentApiKey;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final apiKey = await StorageService.getApiKey();
      
      if (mounted) {
        setState(() {
          _currentApiKey = apiKey;
          if (apiKey != null) {
            _apiKeyController.text = apiKey;
          }
          _isLoading = false;
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
            content: Text('Error loading API key: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveApiKey() async {
    if (_apiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an API key'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      await StorageService.saveApiKey(_apiKeyController.text);
      
      if (mounted) {
        setState(() {
          _currentApiKey = _apiKeyController.text;
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving API key: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FadeTransition(
                      opacity: _animationController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Text(
                            'API Configuration',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFCD34D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Configure your Google Gemini API key to enable AI-powered tarot readings.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // API Key field
                          TextFormField(
                            controller: _apiKeyController,
                            decoration: InputDecoration(
                              labelText: 'Google Gemini API Key',
                              labelStyle: const TextStyle(color: Colors.white70),
                              hintText: 'Enter your API key',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                              prefixIcon: const Icon(Icons.key, color: Color(0xFFF59E0B)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showApiKey ? Icons.visibility_off : Icons.visibility,
                                  color: const Color(0xFFF59E0B),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showApiKey = !_showApiKey;
                                  });
                                },
                              ),
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
                            obscureText: !_showApiKey,
                            enableSuggestions: false,
                            autocorrect: false,
                          ),
                          const SizedBox(height: 16),
                          
                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveApiKey,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 8,
                                shadowColor: const Color(0xFFF59E0B).withOpacity(0.5),
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
                                  : const Text(
                                      'Save API Key',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // API Key status
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
                                Row(
                                  children: [
                                    Icon(
                                      _currentApiKey != null && _currentApiKey!.isNotEmpty
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: _currentApiKey != null && _currentApiKey!.isNotEmpty
                                          ? Colors.green
                                          : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'API Key Status: ${_currentApiKey != null && _currentApiKey!.isNotEmpty ? 'Configured' : 'Not Configured'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFCD34D),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'The API key is required for AI-powered tarot readings. Without it, the app will use a basic offline interpretation.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // How to get API key
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
                                      'How to get a Google Gemini API Key',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFCD34D),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildStepItem(
                                  '1',
                                  'Go to Google AI Studio (ai.google.dev)',
                                ),
                                _buildStepItem(
                                  '2',
                                  'Sign in with your Google account',
                                ),
                                _buildStepItem(
                                  '3',
                                  'Navigate to the API Keys section',
                                ),
                                _buildStepItem(
                                  '4',
                                  'Create a new API key',
                                ),
                                _buildStepItem(
                                  '5',
                                  'Copy and paste the API key here',
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    // Open Google AI Studio in browser
                                    // This is a placeholder - in a real app, you would use url_launcher
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('This would open Google AI Studio in a browser'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.open_in_new,
                                    color: Color(0xFFF59E0B),
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Visit Google AI Studio',
                                    style: TextStyle(
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFF59E0B)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
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
                                      Icons.code,
                                      color: Color(0xFFFCD34D),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Demo API Key (for testing only)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFCD34D),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'For demonstration purposes only. This key is not real and will not work in production.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'AIzaSyD_DEMO_KEY_12345abcdefghijklmnopqrstuvwxyz',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.copy,
                                          color: Color(0xFFF59E0B),
                                          size: 16,
                                        ),
                                        onPressed: () {
                                          Clipboard.setData(const ClipboardData(
                                            text: 'AIzaSyD_DEMO_KEY_12345abcdefghijklmnopqrstuvwxyz',
                                          ));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Demo API key copied to clipboard'),
                                            ),
                                          );
                                        },
                                        tooltip: 'Copy to clipboard',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
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