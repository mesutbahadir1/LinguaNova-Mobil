import 'package:flutter/material.dart';

class NoviTitle extends StatefulWidget {
  final String text;
  final Color textColor;
  final Color glowColor;
  final double fontSize;

  const NoviTitle({
    Key? key,
    required this.text,
    this.textColor = Colors.white,
    this.glowColor = const Color(0xFF4B5EFF),
    this.fontSize = 24,
  }) : super(key: key);

  @override
  State<NoviTitle> createState() => _NoviTitleState();
}

class _NoviTitleState extends State<NoviTitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 60, // 6 seconds of nothing
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 10, // 1 second fade in
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 30, // 3 seconds fade out
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animation and repeat it
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Base text (always visible)
            Text(
              widget.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.textColor,
                fontSize: widget.fontSize,
                letterSpacing: 1.2,
              ),
            ),
            
            // Glow overlay (fades in and out)
            Opacity(
              opacity: _pulseAnimation.value,
              child: Text(
                widget.text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: widget.fontSize,
                  letterSpacing: 1.2,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = widget.glowColor.withOpacity(0.6),
                  shadows: [
                    Shadow(
                      color: widget.glowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Kullanım örneği:
// appBar: AppBar(
//   automaticallyImplyLeading: false,
//   title: AnimatedGradientTitle(text: 'Novi'),
//   centerTitle: true,
//   backgroundColor: const Color(0xFF4B5EFF),
//   elevation: 0,
//   actions: [ ... ],
// ),