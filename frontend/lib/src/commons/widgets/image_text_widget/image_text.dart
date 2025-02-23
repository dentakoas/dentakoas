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

class GlitchGreetingCard extends StatefulWidget {
  const GlitchGreetingCard({super.key});

  @override
  _GlitchGreetingCardState createState() => _GlitchGreetingCardState();
}

class _GlitchGreetingCardState extends State<GlitchGreetingCard>
    with SingleTickerProviderStateMixin {
  final List<String> greetings = [
    'Welcome',
    'Bienvenido',
    'Bienvenue',
    'Willkommen',
    'Benvenuto',
    'Bem-vindo',
    '欢迎',
    'ようこそ',
    '환영합니다',
    'Добро по��аловать',
    'مرحبا',
    'स्वागत हे',
    'Selamat datang',
  ];

  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentGreetingIndex = 0;
  bool _isGlitching = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _startGlitchTimer();
  }

  void _startGlitchTimer() {
    Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      setState(() {
        _isGlitching = true;
      });
      _controller.forward(from: 0).then((_) {
        setState(() {
          _currentGreetingIndex = _random.nextInt(greetings.length);
          _isGlitching = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _isGlitching ? _random.nextDouble() * 4 - 2 : 0,
              _isGlitching ? _random.nextDouble() * 4 - 2 : 0,
            ),
            child: Stack(
              children: [
                if (_isGlitching) ...[
                  _buildGlitchText(Colors.red, const Offset(-2, 0)),
                  _buildGlitchText(Colors.blue, const Offset(2, 0)),
                  _buildGlitchText(Colors.green, const Offset(0, 2)),
                ],
                _buildGlitchText(Colors.white, Offset.zero),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlitchText(Color color, Offset offset) {
    return Positioned.fill(
      child: Transform.translate(
        offset: offset,
        child: Text(
          greetings[_currentGreetingIndex],
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// class GlitchGreetingCard extends StatefulWidget {
//   const GlitchGreetingCard({super.key});

//   @override
//   _GlitchGreetingCardState createState() => _GlitchGreetingCardState();
// }

// class _GlitchGreetingCardState extends State<GlitchGreetingCard>
//     with SingleTickerProviderStateMixin {
//   final List<String> greetings = [
//     'Welcome',
//     'Bienvenido',
//     'Bienvenue',
//     'Willkommen',
//     'Benvenuto',
//     'Bem-vindo',
//     '欢迎',
//     'ようこそ',
//     '환영합니다',
//     'Добро пожаловать',
//     'مرحبا',
//     'स्वागत हे',
//     'Selamat datang',
//   ];

//   late AnimationController _controller;
//   late Animation<double> _animation;
//   int _currentGreetingIndex = 0;
//   bool _isGlitching = false;
//   final Random _random = Random();
//   String _displayedText = '';
//   late Timer _glitchTimer;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
//     _displayedText = greetings[_currentGreetingIndex];
//     _startGlitchTimer();
//   }

//   void _startGlitchTimer() {
//     _glitchTimer = Timer.periodic(const Duration(milliseconds: 3000), (timer) {
//       _startGlitchEffect();
//     });
//   }

//   void _startGlitchEffect() {
//     setState(() {
//       _isGlitching = true;
//     });
//     _controller.forward(from: 0);

//     int glitchCount = 0;
//     Timer.periodic(const Duration(milliseconds: 50), (timer) {
//       if (glitchCount < 20) {
//         setState(() {
//           _displayedText = _generateRandomText();
//         });
//         glitchCount++;
//       } else {
//         timer.cancel();
//         setState(() {
//           _currentGreetingIndex =
//               (_currentGreetingIndex + 1) % greetings.length;
//           _displayedText = greetings[_currentGreetingIndex];
//           _isGlitching = false;
//         });
//       }
//     });
//   }

//   String _generateRandomText() {
//     const charset =
//         'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
//     return String.fromCharCodes(Iterable.generate(
//       greetings[_currentGreetingIndex].length,
//       (_) => charset.codeUnitAt(_random.nextInt(charset.length)),
//     ));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _glitchTimer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: AnimatedBuilder(
//         animation: _animation,
//         builder: (context, child) {
//           return Transform.translate(
//             offset: Offset(
//               _isGlitching ? _random.nextDouble() * 4 - 2 : 0,
//               _isGlitching ? _random.nextDouble() * 4 - 2 : 0,
//             ),
//             child: Stack(
//               children: [
//                 if (_isGlitching) ...[
//                   _buildGlitchText(Colors.red, const Offset(-2, 0)),
//                   _buildGlitchText(Colors.blue, const Offset(2, 0)),
//                   _buildGlitchText(Colors.green, const Offset(0, 2)),
//                 ],
//                 _buildGlitchText(Colors.white, Offset.zero),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildGlitchText(Color color, Offset offset) {
//     return Positioned.fill(
//       child: Transform.translate(
//         offset: offset,
//         child: Text(
//           _displayedText,
//           style: TextStyle(
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }
