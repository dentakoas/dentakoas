import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GlitchGreetingText extends StatefulWidget {
  final List<String> greetings;
  final TextStyle style;

  const GlitchGreetingText({
    Key? key,
    required this.greetings,
    required this.style,
  }) : super(key: key);

  @override
  _GlitchGreetingTextState createState() => _GlitchGreetingTextState();
}

class _GlitchGreetingTextState extends State<GlitchGreetingText> {
  late String _currentText;
  late int _currentIndex;
  bool _isGlitching = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _currentText = widget.greetings[_currentIndex];
    _startChangingText();
  }

  void _startChangingText() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _isGlitching = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.greetings.length;
          _currentText = widget.greetings[_currentIndex];
          _isGlitching = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getGlitchedText() {
    if (!_isGlitching) return _currentText;

    final random = Random();
    return String.fromCharCodes(
      _currentText.runes.map((rune) {
        if (random.nextDouble() < 0.3) {
          return random.nextInt(256);
        }
        return rune;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _getGlitchedText(),
      style: widget.style.copyWith(
        color: _isGlitching
            ? widget.style.color?.withOpacity(0.8)
            : widget.style.color,
      ),
    );
  }
}

