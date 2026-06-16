// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/world_cup_teams.dart';
import '../models/difficulty.dart';
import '../providers/prediction_provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import '../services/local_db_service.dart';
import '../widgets/flag_widget.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'predictions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _serverController = TextEditingController();
  int _best = 0;
  Country _pick = WorldCup.teams[12]; // Argentina by default

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _nameController.text = settings.username; // remembered from last time
    _serverController.text = ApiService.customBaseUrl ?? '';
    _loadBest();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionProvider>().loadStats();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _loadBest() async {
    final settings = context.read<SettingsProvider>();
    final best = await LocalDbService.instance
        .getBestScore(difficulty: settings.difficulty.key);
    if (mounted) setState(() => _best = best);
  }

  Future<void> _vote() async {
    final settings = context.read<SettingsProvider>();
    if (!settings.hasUsername) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a username first to vote.')),
      );
      return;
    }
    final ok = await context.read<PredictionProvider>().vote(
          username: settings.username,
          team: _pick.name,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'You picked ${_pick.name} to win the World Cup! 🏆'
            : 'Could not submit your prediction.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final canPlay = settings.hasUsername;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B6E4F), Color(0xFF13A36B), Color(0xFF9BE7C4)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text('⚽ FLAPPY WORLD CUP',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1)),
                const Text('2026 · Canada · Mexico · USA',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 14),

                _flagsBanner(),
                const SizedBox(height: 18),

                _usernameCard(settings),
                const SizedBox(height: 14),

                _scoreboardAndQuestion(settings),
                const SizedBox(height: 14),

                _difficultyCard(settings),
                const SizedBox(height: 12),

                _serverCard(settings),
                const SizedBox(height: 18),

                // Play
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC400),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: canPlay
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    GameScreen(difficulty: settings.difficulty),
                              ),
                            );
                            _loadBest();
                          }
                        : null,
                    icon: const Icon(Icons.sports_soccer),
                    label: Text(canPlay ? 'KICK OFF!' : 'Enter a username to play',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LeaderboardScreen()),
                        ),
                        icon: const Icon(Icons.leaderboard),
                        label: const Text('Scores'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const PredictionsScreen()),
                        ),
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('Predictions'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Scrolling row of national flags.
  Widget _flagsBanner() {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: WorldCup.teams.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => FlagWidget(country: WorldCup.teams[i]),
      ),
    );
  }

  Widget _usernameCard(SettingsProvider settings) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Player name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            maxLength: 20,
            textInputAction: TextInputAction.done,
            onChanged: settings.setUsername,
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              hintText: 'Enter a username to start',
              prefixIcon: const Icon(Icons.person, size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // The scoreboard + the "who will win?" question, side by side.
  Widget _scoreboardAndQuestion(SettingsProvider settings) {
    return _card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Your best',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54)),
                  Text('$_best',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w900)),
                  Text(settings.difficulty.label,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54)),
                ],
              ),
              Container(width: 1, height: 56, color: Colors.black12),
              const Icon(Icons.emoji_events,
                  size: 40, color: Color(0xFFFFC400)),
            ],
          ),
          const Divider(height: 22),

          // The special prediction question, right by the scoreboard.
          Row(
            children: const [
              Icon(Icons.help_outline, color: Color(0xFF0B6E4F)),
              SizedBox(width: 6),
              Expanded(
                child: Text('Who will win the World Cup 2026?',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _pickDropdown()),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B6E4F)),
                onPressed: _vote,
                child: const Text('Vote'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'All 48 teams — plus Lebanon 🇱🇧 & Manchester United for fun!',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickDropdown() {
    return DropdownButtonFormField<Country>(
      value: _pick,
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: WorldCup.allPicks.map((c) {
        return DropdownMenuItem<Country>(
          value: c,
          child: Row(
            children: [
              FlagWidget(country: c, width: 24, height: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.isBonus ? '${c.name} ⭐' : c.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (c) {
        if (c != null) setState(() => _pick = c);
      },
    );
  }

  Widget _difficultyCard(SettingsProvider settings) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Difficulty',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: Difficulty.all.map((d) {
              final selected = settings.difficulty.level == d.level;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text(d.label, textAlign: TextAlign.center),
                    ),
                    selected: selected,
                    selectedColor: d.color,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      settings.setDifficulty(d);
                      _loadBest();
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _serverCard(SettingsProvider settings) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding:
              const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: const Icon(Icons.dns, color: Color(0xFF0B6E4F)),
          title: const Text('Server (for phones)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(settings.serverUrl,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'On a real phone, set this to your computer\'s LAN IP so the '
                'app can reach the backend, e.g. http://192.168.1.20:4000',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _serverController,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'http://192.168.1.20:4000',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0B6E4F)),
                  onPressed: () {
                    settings.setServerUrl(_serverController.text);
                    context.read<PredictionProvider>().loadStats();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Server set to ${settings.serverUrl}')),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  _serverController.clear();
                  settings.setServerUrl(null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Using default: ${settings.serverUrl}')),
                  );
                },
                child: const Text('Reset to default'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}
