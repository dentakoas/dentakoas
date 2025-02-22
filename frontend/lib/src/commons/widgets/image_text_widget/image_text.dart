import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class GlitchGreetingText extends StatefulWidget {
  final List<String> greetings;
  final TextStyle style;

  const GlitchGreetingText({
    super.key,
    required this.greetings,
    required this.style,
  });

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


class BrutalGlitchGreetingText extends StatefulWidget {
  final List<String> greetings;
  final TextStyle style;

  const BrutalGlitchGreetingText({
    super.key,
    required this.greetings,
    required this.style,
  });

  @override
  _BrutalGlitchGreetingTextState createState() =>
      _BrutalGlitchGreetingTextState();
}

class _BrutalGlitchGreetingTextState extends State<BrutalGlitchGreetingText> {
  late String _currentText;
  late int _currentIndex;
  bool _isGlitching = false;
  late Timer _timer;
  final Random _random = Random();

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

      Future.delayed(const Duration(milliseconds: 1000), () {
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

    return String.fromCharCodes(
      _currentText.runes.map((rune) {
        if (_random.nextDouble() < 0.5) {
          return _random.nextInt(256);
        }
        return rune;
      }),
    );
  }

  Color _getGlitchColor() {
    if (!_isGlitching) return widget.style.color ?? Colors.black;

    return Color.fromRGBO(
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
      1,
    );
  }

  double _getGlitchOffset() {
    return _isGlitching ? _random.nextDouble() * 10 - 5 : 0;
  }

  double _getGlitchScale() {
    return _isGlitching ? 0.8 + _random.nextDouble() * 0.4 : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(3, (index) {
        return Positioned(
          left: _getGlitchOffset(),
          top: _getGlitchOffset(),
          child: Transform.scale(
            scale: _getGlitchScale(),
            child: Text(
              _getGlitchedText(),
              style: widget.style.copyWith(
                color: _getGlitchColor().withOpacity(0.7),
              ),
            ),
          ),
        );
      }),
    );
  }
}
