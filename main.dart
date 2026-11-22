import 'package:flutter/material.dart';

void main() {
  runApp(const CourtScoreApp());
}

class CourtScoreApp extends StatelessWidget {
  const CourtScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6759E8);
    return MaterialApp(
      title: 'CourtScore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          surface: const Color(0xFF151722),
        ),
        scaffoldBackgroundColor: const Color(0xFF0E1018),
        cardTheme: CardTheme(
          color: const Color(0xFF191C29),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFF2B3041)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF242838),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      home: const ScoreKeeperPage(),
    );
  }
}

class ScoreKeeperPage extends StatefulWidget {
  const ScoreKeeperPage({super.key});

  @override
  State<ScoreKeeperPage> createState() => _ScoreKeeperPageState();
}

class _ScoreKeeperPageState extends State<ScoreKeeperPage> {
  final _teamAController = TextEditingController(text: 'HOME');
  final _teamBController = TextEditingController(text: 'AWAY');

  int _scoreA = 0;
  int _scoreB = 0;
  int _target = 21;
  int? _previousA;
  int? _previousB;

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  void _changeScore(bool teamA, int amount) {
    setState(() {
      _previousA = _scoreA;
      _previousB = _scoreB;
      if (teamA) {
        _scoreA = (_scoreA + amount).clamp(0, 999);
      } else {
        _scoreB = (_scoreB + amount).clamp(0, 999);
      }
    });
  }

  void _undo() {
    if (_previousA == null || _previousB == null) return;
    setState(() {
      _scoreA = _previousA!;
      _scoreB = _previousB!;
      _previousA = null;
      _previousB = null;
    });
  }

  void _reset() {
    setState(() {
      _scoreA = 0;
      _scoreB = 0;
      _previousA = null;
      _previousB = null;
    });
  }

  Future<void> _confirmReset() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset scoreboard?'),
        content: const Text('Both team scores will return to zero.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
    if (shouldReset == true) _reset();
  }

  String _cleanName(TextEditingController controller, String fallback) {
    final value = controller.text.trim();
    return value.isEmpty ? fallback : value.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final aWins = _scoreA >= _target && _scoreA > _scoreB;
    final bWins = _scoreB >= _target && _scoreB > _scoreA;
    final progress = ((_scoreA > _scoreB ? _scoreA : _scoreB) / _target)
        .clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 22,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF6759E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sports_score_rounded, size: 22),
            ),
            const SizedBox(width: 11),
            const Text(
              'COURTSCORE',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                  letterSpacing: 1.8),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Undo last score change',
            onPressed: _previousA == null ? null : _undo,
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            tooltip: 'Reset scores',
            onPressed: _confirmReset,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              child: Column(
                children: [
                  _buildHeader(aWins, bWins),
                  const SizedBox(height: 18),
                  _buildTargetSelector(),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: const Color(0xFF282C3B),
                      color: const Color(0xFF8A7DFF),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final horizontal = constraints.maxWidth > 560;
                        final cards = [
                          Expanded(
                            child: _teamCard(
                              teamA: true,
                              name: _cleanName(_teamAController, 'HOME'),
                              score: _scoreA,
                              isWinner: aWins,
                            ),
                          ),
                          if (horizontal) const SizedBox(width: 14)
                          else const SizedBox(height: 14),
                          Expanded(
                            child: _teamCard(
                              teamA: false,
                              name: _cleanName(_teamBController, 'AWAY'),
                              score: _scoreB,
                              isWinner: bWins,
                            ),
                          ),
                        ];
                        return horizontal
                            ? Row(crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: cards)
                            : Column(children: cards);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBottomHint(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool aWins, bool bWins) {
    final status = aWins
        ? '${_cleanName(_teamAController, 'HOME')} WINS!'
        : bWins
            ? '${_cleanName(_teamBController, 'AWAY')} WINS!'
            : 'MATCH SCOREBOARD';
    return Column(
      children: [
        Text(status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: (aWins || bWins)
                  ? const Color(0xFFB8AEFF)
                  : Colors.white70,
              fontSize: 12,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w800,
            )),
        const SizedBox(height: 7),
        const Text(
          'Keep the game going.',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800,
              letterSpacing: -0.8),
        ),
      ],
    );
  }

  Widget _buildTargetSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('PLAY TO', style: TextStyle(
            color: Colors.white54, fontSize: 11, letterSpacing: 1.4,
            fontWeight: FontWeight.w800)),
        const SizedBox(width: 12),
        ...[11, 21, 30].map((value) {
          final selected = _target == value;
          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: ChoiceChip(
              label: Text('$value'),
              selected: selected,
              onSelected: (_) => setState(() => _target = value),
              showCheckmark: false,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : Colors.white60,
              ),
              selectedColor: const Color(0xFF6759E8),
              backgroundColor: const Color(0xFF202433),
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            ),
          );
        }),
      ],
    );
  }

  Widget _teamCard({
    required bool teamA,
    required String name,
    required int score,
    required bool isWinner,
  }) {
    final accent = teamA ? const Color(0xFF8A7DFF) : const Color(0xFF35C9B2);
    final controller = teamA ? _teamAController : _teamBController;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.13),
              const Color(0xFF191C29),
              const Color(0xFF191C29),
            ],
          ),
          border: Border(
            top: BorderSide(color: accent, width: 3),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(teamA ? Icons.home_rounded : Icons.flight_takeoff_rounded,
                        color: accent, size: 16),
                    const SizedBox(width: 6),
                    Text(teamA ? 'TEAM 01' : 'TEAM 02',
                        style: TextStyle(color: accent, fontSize: 10,
                            fontWeight: FontWeight.w900, letterSpacing: 1.7)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 190,
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 14,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: 'TEAM NAME',
                      isDense: true,
                    ),
                  ),
                ),
                if (isWinner) ...[
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text('WINNER',
                        style: TextStyle(color: accent, fontSize: 10,
                            fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                ],
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: 112,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -6,
                  color: isWinner ? accent : Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _scoreButton(
                        label: '−1',
                        icon: Icons.remove_rounded,
                        onTap: () => _changeScore(teamA, -1),
                        outlined: true,
                        accent: accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _scoreButton(
                        label: '+1',
                        onTap: () => _changeScore(teamA, 1),
                        accent: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _scoreButton(
                        label: '+2 POINTS',
                        onTap: () => _changeScore(teamA, 2),
                        accent: accent,
                        outlined: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _scoreButton(
                        label: '+3 POINTS',
                        onTap: () => _changeScore(teamA, 3),
                        accent: accent,
                        outlined: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreButton({
    required String label,
    required VoidCallback onTap,
    required Color accent,
    IconData? icon,
    bool outlined = false,
  }) {
    return SizedBox(
      height: 47,
      child: outlined
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: accent.withValues(alpha: 0.45)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
                padding: const EdgeInsets.symmetric(horizontal: 5),
              ),
              child: _buttonContent(label, icon),
            )
          : FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
                padding: const EdgeInsets.symmetric(horizontal: 5),
              ),
              child: _buttonContent(label, icon),
            ),
    );
  }

  Widget _buttonContent(String label, IconData? icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 17),
        if (icon != null) const SizedBox(width: 2),
        Flexible(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ),
      ],
    );
  }

  Widget _buildBottomHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.touch_app_rounded, size: 15, color: Colors.white38),
        SizedBox(width: 7),
        Text('Tap a score button to update the scoreboard',
            style: TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }
}
