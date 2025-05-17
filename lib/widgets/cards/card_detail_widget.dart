import 'package:flutter/material.dart';
import '../../../data/models/tarot_card.dart';
import '../../../core/utils/card_utils.dart';

class CardDetailWidget extends StatefulWidget {
  final TarotCard card;

  const CardDetailWidget({
    Key? key,
    required this.card,
  }) : super(key: key);

  @override
  _CardDetailWidgetState createState() => _CardDetailWidgetState();
}

class _CardDetailWidgetState extends State<CardDetailWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _flipped = false;
  bool _loaded = false;
  bool _backLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    
    // Simulate image loading
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _loaded = true;
        });
      }
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _backLoaded = true;
        });
      }
    });
  }

  void _toggleFlip() {
    setState(() {
      _flipped = !_flipped;
    });
    
    if (_flipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColors = CardUtils.getCardColors(widget.card.element);
    final cardName = widget.card.name.split(" - ").length > 1 
        ? widget.card.name.split(" - ")[1] 
        : widget.card.name;
    
    return GestureDetector(
      onTap: _toggleFlip,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(3.14159 * _animation.value),
        child: _animation.value < 0.5
            ? _buildFrontCard(cardColors, cardName)
            : _buildBackCard(cardColors, cardName),
      ),
    );
  }

  Widget _buildFrontCard(Map<String, dynamic> cardColors, String cardName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: cardColors["background"] as Gradient,
        border: Border.all(
          color: (cardColors["border"] as Color),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (cardColors["shadow"] as Color),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 2/3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardName,
                  style: TextStyle(
                    color: cardColors["text"] as Color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Stack(
                    children: [
                      // Card image
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _loaded ? 1.0 : 0.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/cards/card-${widget.card.number}.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback when image can't be loaded
                                return Container(
                                  color: (cardColors["background"] as Gradient).colors[0],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          color: cardColors["text"] as Color,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.card.representation,
                                          style: TextStyle(
                                            color: cardColors["text"] as Color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      
                      // Loading placeholder
                      if (!_loaded)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: cardColors["background"] as Gradient,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(cardColors["border"] as Color),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${widget.card.number}',
                                  style: TextStyle(
                                    color: cardColors["text"] as Color,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.card.representation,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // Element info overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            widget.card.element,
                            style: TextStyle(
                              color: cardColors["text"] as Color,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      
                      // Static glow effect
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFFF59E0B).withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Representation: ${widget.card.representation}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Click to flip',
                      style: TextStyle(
                        color: cardColors["text"] as Color,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(Map<String, dynamic> cardColors, String cardName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: cardColors["background"] as Gradient,
        border: Border.all(
          color: (cardColors["border"] as Color),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (cardColors["shadow"] as Color),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 2/3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardName,
                  style: TextStyle(
                    color: cardColors["text"] as Color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Element: ',
                                style: TextStyle(
                                  color: cardColors["text"] as Color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                              TextSpan(
                                text: widget.card.element,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Representation: ',
                                style: TextStyle(
                                  color: cardColors["text"] as Color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                              TextSpan(
                                text: widget.card.representation,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.card.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Click to flip',
                      style: TextStyle(
                        color: cardColors["text"] as Color,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}