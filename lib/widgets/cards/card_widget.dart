import 'package:flutter/material.dart';
import '../../../data/models/tarot_card.dart';
import '../../../core/utils/card_utils.dart';

class CardWidget extends StatefulWidget {
  final TarotCard card;
  final bool selected;
  final VoidCallback onTap;
  final int index;

  const CardWidget({
    Key? key,
    required this.card,
    required this.selected,
    required this.onTap,
    required this.index,
  }) : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _flipped = true;
  bool _wasClicked = false;
  bool _isHovering = false;
  bool _frontLoaded = false;
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
    
    Future.delayed(Duration(milliseconds: 300 + widget.index * 50), () {
      if (mounted) {
        setState(() {
          _backLoaded = true;
        });
      }
    });
    
    Future.delayed(Duration(milliseconds: 500 + widget.index * 50), () {
      if (mounted) {
        setState(() {
          _frontLoaded = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(CardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && _flipped) {
      _flipCard();
    }
  }

  void _flipCard() {
    setState(() {
      _flipped = false;
      _wasClicked = true;
    });
    _controller.forward();
  }

  void _onTap() {
    if (_flipped) {
      _flipCard();
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onTap();
      });
    } else {
      widget.onTap();
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
      onTap: _onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.identity()
            ..scale(widget.selected ? 1.05 : _isHovering ? 1.05 : 1.0),
          child: Stack(
            children: [
              // Glow effect when selected
              if (widget.selected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (cardColors["shadow"] as Color),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(3.14159 * (1 - _animation.value)),
                child: _animation.value < 0.5
                    ? _buildCardBack()
                    : _buildCardFront(cardColors, cardName),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(Map<String, dynamic> cardColors, String cardName) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: cardColors["background"] as Gradient,
        border: Border.all(
          color: widget.selected 
              ? Colors.white 
              : (cardColors["border"] as Color).withOpacity(0.5),
          width: widget.selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (cardColors["shadow"] as Color).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 2/3,
          child: Stack(
            children: [
              // Card image
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _frontLoaded ? 1.0 : 0.0,
                  child: Image.asset(
                    'assets/images/cards/card-${widget.card.number}.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: (cardColors["background"] as Gradient).colors[0],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                color: cardColors["text"] as Color,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cardName,
                                style: TextStyle(
                                  color: cardColors["text"] as Color,
                                  fontWeight: FontWeight.bold,
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
              
              // Loading placeholder
              if (!_frontLoaded)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: cardColors["background"] as Gradient,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: (cardColors["border"] as Color).withOpacity(0.5),
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFCD34D)),
                                strokeWidth: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: cardColors["text"] as Color,
                            fontSize: 12,
                          ),
                        ),
                        Opacity(
                          opacity: 0.2,
                          child: Text(
                            '${widget.card.number}',
                            style: TextStyle(
                              color: cardColors["text"] as Color,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Card info overlay
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: (_isHovering || widget.selected) ? 1.0 : 0.0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cardName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.card.element,
                          style: TextStyle(
                            color: cardColors["text"] as Color,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Selection indicator
              if (widget.selected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF312E81),
        border: Border.all(
          color: const Color(0xFFFCD34D).withOpacity(0.7),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 2/3,
          child: Stack(
            children: [
              // Card back image
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _backLoaded ? 1.0 : 0.0,
                  child: Image.asset(
                    'assets/images/cards/card-back.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF312E81),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFFCD34D),
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Loading placeholder
              if (!_backLoaded)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF312E81),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFCD34D)),
                      ),
                    ),
                  ),
                ),
              
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF59E0B).withOpacity(0.1),
                        Colors.transparent,
                        const Color(0xFF8B5CF6).withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
              
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFCD34D).withOpacity(0.3),
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFCD34D).withOpacity(0.2),
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFCD34D).withOpacity(0.4),
                          width: 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Click to flip',
                      style: TextStyle(
                        color: const Color(0xFFFCD34D).withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}