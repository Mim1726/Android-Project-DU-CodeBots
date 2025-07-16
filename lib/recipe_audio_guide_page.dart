// lib/recipe_audio_guide_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Interactive audio‑guided walkthrough of a recipe.
///
/// * Shows recipe photo inside a circular progress ring that only **fills while a
///   countdown is running** (no more infinite spinner).
/// * A **slider** at the bottom works like a video seek‑bar so users can jump
///   **backward** to any previous step.
/// * When the user taps **play** after pausing, a sheet lets them choose
///   _Resume_ or _Start over_ (instead of showing that sheet when they hit the
///   pause button).
/// * An app‑bar with semi‑transparent deep‑orange background is centred and
///   followed by the recipe name + total time line.
class RecipeAudioGuidePage extends StatefulWidget {
  /// Ordered instructions. Each instruction _may_ contain a duration such as
  /// "Bake for 20 minutes" that is extracted automatically.
  final List<String> instructions;

  /// Asset path of the recipe photo.
  final String imageAsset;

  /// Name of the recipe (shown under the title bar).
  final String recipeName;

  const RecipeAudioGuidePage({
    super.key,
    required this.instructions,
    required this.imageAsset,
    required this.recipeName,
  });

  @override
  State<RecipeAudioGuidePage> createState() => _RecipeAudioGuidePageState();
}

class _RecipeAudioGuidePageState extends State<RecipeAudioGuidePage> {
  // ---------- constants ----------
  static const Color deepOrange = Color(0xFFFF5722);

  // ---------- TTS ----------
  final FlutterTts _tts = FlutterTts();

  // ---------- playback state ----------
  int _index = 0; // current instruction index
  bool _waiting = false; // true while a countdown is running
  bool _paused = false; // true while user paused

  // ---------- timer state ----------
  Duration _remaining = Duration.zero; // time left in countdown
  Duration _currentWait = Duration.zero; // original wait for progress calc
  Timer? _timer;

  // ---------- life‑cycle ----------
  @override
  void initState() {
    super.initState();
    _configureTts();
    _playCurrentStep();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  // ---------- TTS helpers ----------
  void _configureTts() {
    _tts.setLanguage('en-US');
    _tts.setPitch(1.0);
    _tts.setSpeechRate(0.5);
    _tts.setCompletionHandler(_onSpoken);
  }

  Future<void> _playCurrentStep() async {
    if (_index >= widget.instructions.length) return;
    final text = widget.instructions[_index];
    await _tts.speak(text);
  }

  void _onSpoken() {
    if (_paused) return; // do nothing while paused
    final Duration? wait = _extractDuration(widget.instructions[_index]);
    if (wait != null && wait > Duration.zero) {
      _startCountdown(wait);
    } else {
      _moveNext();
    }
  }

  // ---------- countdown ----------
  void _startCountdown(Duration d) {
    setState(() {
      _waiting = true;
      _currentWait = d;
      _remaining = d;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_paused) return; // freeze while paused
      if (_remaining.inSeconds <= 1) {
        t.cancel();
        setState(() => _waiting = false);
        _moveNext();
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  void _moveNext() {
    _index++;
    if (_index < widget.instructions.length) {
      _playCurrentStep();
    } else {
      _tts.speak('All steps completed. Enjoy your meal!');
    }
  }

  // ---------- play / pause / seek ----------
  void _pause() {
    setState(() => _paused = true);
    _tts.stop();
    _timer?.cancel();
  }

  void _resume() {
    setState(() => _paused = false);
    if (_waiting) {
      _startCountdown(_remaining); // restart the ticking
    } else {
      _playCurrentStep(); // resume speech
    }
  }

  void _restart() {
    setState(() {
      _paused = false;
      _waiting = false;
      _index = 0;
    });
    _timer?.cancel();
    _playCurrentStep();
  }

  void _jumpToStep(int step) {
    setState(() {
      _paused = false;
      _waiting = false;
      _index = step;
    });
    _timer?.cancel();
    _playCurrentStep();
  }

  void _showResumeSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Resume where I left off'),
            onTap: () {
              Navigator.pop(context);
              _resume();
            },
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: const Text('Start from the beginning'),
            onTap: () {
              Navigator.pop(context);
              _restart();
            },
          ),
        ],
      ),
    );
  }

  // ---------- duration parsing ----------
  final _durReg = RegExp(
    r'(\d+)\s*(hour|hours|hr|hrs|h|minute|minutes|min|m|second|seconds|sec|s)',
    caseSensitive: false,
  );

  Duration? _extractDuration(String text) {
    final m = _durReg.firstMatch(text);
    if (m == null) return null;

    final value = int.parse(m.group(1)!);
    final unit = m.group(2)!.toLowerCase();

    if (unit.startsWith('h')) return Duration(hours: value);
    if (unit.startsWith('m')) return Duration(minutes: value);
    return Duration(seconds: value);
  }

  Duration get _totalWaitTime {
    var sum = Duration.zero;
    for (final ins in widget.instructions) {
      final d = _extractDuration(ins);
      if (d != null) sum += d;
    }
    return sum;
  }

  // ---------- progress helpers ----------
  double get _progress {
    if (!_waiting || _currentWait.inMilliseconds == 0) return 0;
    final done = _currentWait.inSeconds - _remaining.inSeconds;
    return done / _currentWait.inSeconds;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final currentText = _index < widget.instructions.length
        ? widget.instructions[_index]
        : 'Finished';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: deepOrange.withOpacity(0.9),
        centerTitle: true,
        title: const Text('Audio Guide'),
      ),
      body: Column(
        children: [
          // recipe name + total time banner
          Material(
            color: Colors.black.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.recipeName,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDuration(_totalWaitTime),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ------- circular image + progress -------
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // progress ring (fills only while waiting)
                        CircularProgressIndicator(
                          value: _waiting ? _progress : 0,
                          backgroundColor: Colors.black12,
                          color: deepOrange,
                          strokeWidth: 8,
                        ),
                        // recipe image
                        ClipOval(
                          child: Image.asset(
                            widget.imageAsset,
                            width: 220,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // play / pause overlay
                        Positioned(
                          child: IconButton(
                            iconSize: 56,
                            icon: Icon(
                              _paused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (_paused) {
                                _showResumeSheet();
                              } else {
                                _pause();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // ------- current text -------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      currentText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (_waiting && !_paused) ...[
                    const SizedBox(height: 20),
                    Text(
                      _formatDuration(_remaining),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                        color: deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // ------- seek slider -------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Slider(
              value: _index.toDouble(),
              min: 0,
              max: (widget.instructions.length - 1).toDouble(),
              divisions: widget.instructions.length - 1,
              label: 'Step ${_index + 1}/${widget.instructions.length}',
              activeColor: deepOrange,
              onChanged: (v) {
                final target = v.round();
                if (target < _index) {
                  _jumpToStep(target);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}