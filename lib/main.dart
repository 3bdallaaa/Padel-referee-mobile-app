import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'match_history.dart';

void main() {
  runApp(const PadelApp());
}

// ---------------- ENUMS ----------------
enum Team { A, B }

enum Side { right, left }

// ---------------- APP ----------------
class PadelApp extends StatefulWidget {
  const PadelApp({super.key});

  @override
  State<PadelApp> createState() => _PadelAppState();
}

class _PadelAppState extends State<PadelApp> {
  bool darkMode = true;
  double speechRate = 1;

  void updateSettings(bool isDark, double rate) {
    setState(() {
      darkMode = isDark;
      speechRate = rate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkMode
          ? ThemeData.dark(useMaterial3: true).copyWith(
              cardTheme: CardThemeData(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            )
          : ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              cardTheme: CardThemeData(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
      home: Builder(
        builder: (context) => PlayerSetupScreen(
          onToggleTheme: () => updateSettings(!darkMode, speechRate),
          speechRate: speechRate,
          darkMode: darkMode,
          onOpenSettings: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SettingsScreen(darkMode: darkMode, speechRate: speechRate),
              ),
            );

            if (result != null) {
              updateSettings(result['darkMode'], result['speechRate']);
            }
          },
        ),
      ),
    );
  }
}

// ---------------- SETUP SCREEN ----------------
class PlayerSetupScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final double speechRate;
  final bool darkMode;
  final VoidCallback onOpenSettings;

  const PlayerSetupScreen({
    super.key,
    required this.onToggleTheme,
    required this.speechRate,
    required this.darkMode,
    required this.onOpenSettings,
  });

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final c1 = TextEditingController(text: "A1");
  final c2 = TextEditingController(text: "A2");
  final c3 = TextEditingController(text: "B1");
  final c4 = TextEditingController(text: "B2");

  Team startingTeam = Team.A;
  bool firstPlayerServer = true;

  int get startingServerIndex {
    return startingTeam == Team.A
        ? (firstPlayerServer ? 0 : 1)
        : (firstPlayerServer ? 2 : 3);
  }

  List<String> get players => [c1.text, c2.text, c3.text, c4.text];

  Widget _buildPlayerCard(
    TextEditingController controller,
    String label,
    Color accentColor,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: accentColor.withValues(alpha: 0.2),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  "Starting Team",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTeamChoice(
                    label: "Team A",
                    team: Team.A,
                    color: Colors.blue,
                    icon: Icons.shield,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTeamChoice(
                    label: "Team B",
                    team: Team.B,
                    color: Colors.orange,
                    icon: Icons.shield_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamChoice({
    required String label,
    required Team team,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = startingTeam == team;
    return GestureDetector(
      onTap: () => setState(() => startingTeam = team),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sports_tennis, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  "First Server",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildServerChoice(
                    label: "Player 1",
                    isSelected: firstPlayerServer,
                    onTap: () => setState(() => firstPlayerServer = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildServerChoice(
                    label: "Player 2",
                    isSelected: !firstPlayerServer,
                    onTap: () => setState(() => firstPlayerServer = false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerChoice({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Colors.green
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.person,
              color: isSelected ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Padel Match",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[800]!, Colors.green[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                tooltip: 'Match History',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  widget.darkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: widget.onToggleTheme,
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: widget.onOpenSettings,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Team A Players
                _buildSectionHeader("Team A", Colors.blue),
                const SizedBox(height: 8),
                _buildPlayerCard(c1, "Player 1", Colors.blue, Icons.person),
                const SizedBox(height: 8),
                _buildPlayerCard(
                  c2,
                  "Player 2",
                  Colors.blue,
                  Icons.person_outline,
                ),
                const SizedBox(height: 20),

                // Team B Players
                _buildSectionHeader("Team B", Colors.orange),
                const SizedBox(height: 8),
                _buildPlayerCard(c3, "Player 3", Colors.orange, Icons.person),
                const SizedBox(height: 8),
                _buildPlayerCard(
                  c4,
                  "Player 4",
                  Colors.orange,
                  Icons.person_outline,
                ),
                const SizedBox(height: 20),

                _buildTeamSelector(),
                const SizedBox(height: 12),
                _buildServerSelector(),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MatchScreen(
                            players: players,
                            startingServerIndex: startingServerIndex,
                            startingTeam: startingTeam,
                            speechRate: widget.speechRate,
                          ),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 8),
                        Text(
                          "Start Match",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------- MATCH STATE ----------------
class MatchState {
  int pointsA = 0;
  int pointsB = 0;
  int gamesA = 0;
  int gamesB = 0;
  int setsA = 0;
  int setsB = 0;

  MatchState copy() {
    final m = MatchState();
    m.pointsA = pointsA;
    m.pointsB = pointsB;
    m.gamesA = gamesA;
    m.gamesB = gamesB;
    m.setsA = setsA;
    m.setsB = setsB;
    return m;
  }
}

// ---------------- MATCH SCREEN ----------------
class MatchScreen extends StatefulWidget {
  final List<String> players;
  final int startingServerIndex;
  final Team startingTeam;
  final double speechRate;

  const MatchScreen({
    super.key,
    required this.players,
    required this.startingServerIndex,
    required this.startingTeam,
    required this.speechRate,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  MatchState state = MatchState();
  late FlutterTts tts;
  late AudioPlayer audioPlayer;

  Side serveSide = Side.right;

  int serverIndex = 0;
  List<MatchState> history = [];

  List<int> serveOrder = [];
  int currentGameIndex = 0;

  bool game2ManualSelectionDone = false;

  @override
  void initState() {
    super.initState();
    serverIndex = widget.startingServerIndex;
    serveOrder.add(serverIndex);

    tts = FlutterTts();
    tts.setLanguage("en-US");
    tts.setSpeechRate(widget.speechRate);
    tts.awaitSpeakCompletion(true);

    audioPlayer = AudioPlayer();

    speakScore();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  String uiScore(int p) {
    if (p == 0) return "0";
    if (p == 1) return "15";
    if (p == 2) return "30";
    if (p == 3) return "40";
    return "";
  }

  String speakScoreText(int p) {
    if (p == 0) return "love";
    if (p == 1) return "fifteen";
    if (p == 2) return "thirty";
    if (p == 3) return "forty";
    return "";
  }

  String get serverName => widget.players[serverIndex];

  Widget serveBall() {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 300),
      alignment: serveSide == Side.right
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.yellow[700],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.yellow[700]!.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.sports_tennis, size: 36, color: Colors.white),
      ),
    );
  }

  void rotateServerAfterGame() {
    if (serveOrder.length == 1) {
      showServerDialog();
      return;
    }

    if (serveOrder.length == 2) {
      int first = serveOrder[0];
      int next = (first == 0)
          ? 1
          : (first == 1)
          ? 0
          : (first == 2)
          ? 3
          : 2;
      serveOrder.add(next);
      serverIndex = next;
      return;
    }

    if (serveOrder.length == 3) {
      int second = serveOrder[1];
      int next = (second == 0)
          ? 1
          : (second == 1)
          ? 0
          : (second == 2)
          ? 3
          : 2;
      serveOrder.add(next);
      serverIndex = next;
      return;
    }
  }

  void showServerDialog() {
    int firstServer = serveOrder[0];
    List<int> allowedPlayers;

    if (firstServer == 0 || firstServer == 1) {
      allowedPlayers = [2, 3];
    } else {
      allowedPlayers = [0, 1];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Choose Server for Game 2"),
        content: const Text("Select from the opposite team"),
        actions: [
          for (int i in allowedPlayers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      serveOrder.add(i);
                      buildFullServeOrder();
                      serverIndex = i;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(widget.players[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void buildFullServeOrder() {
    if (serveOrder.length < 2) return;

    int first = serveOrder[0];
    int second = serveOrder[1];

    int third = (first == 0)
        ? 1
        : (first == 1)
        ? 0
        : (first == 2)
        ? 3
        : 2;

    int fourth = (second == 0)
        ? 1
        : (second == 1)
        ? 0
        : (second == 2)
        ? 3
        : 2;

    serveOrder = [first, second, third, fourth];
  }

  void nextServer() {
    currentGameIndex++;

    if (currentGameIndex == 1 && serveOrder.length == 1) {
      showServerDialog();
      return;
    }

    if (serveOrder.length == 4) {
      serverIndex = serveOrder[currentGameIndex % 4];
    }
  }

  void checkGame() {
    if (state.pointsA >= 4 || state.pointsB >= 4) {
      int diff = state.pointsA - state.pointsB;

      if (diff >= 2) {
        state.gamesA++;
        state.pointsA = 0;
        state.pointsB = 0;
        serveSide = Side.right;
        nextServer();
        speakGameWinner("A");
      } else if (diff <= -2) {
        state.gamesB++;
        state.pointsA = 0;
        state.pointsB = 0;
        serveSide = Side.right;
        nextServer();
        speakGameWinner("B");
      }

      checkSet();
    }
  }

  void checkSet() {
    if (state.gamesA >= 6 && state.gamesA - state.gamesB >= 2) {
      state.setsA++;
      state.gamesA = 0;
      state.gamesB = 0;
    }

    if (state.gamesB >= 6 && state.gamesB - state.gamesA >= 2) {
      state.setsB++;
      state.gamesA = 0;
      state.gamesB = 0;
    }
  }

  Future speakGameWinner(String team) async {
    String a = "${widget.players[0]} and ${widget.players[1]}";
    String b = "${widget.players[2]} and ${widget.players[3]}";
    await tts.speak(team == "A" ? "$a won" : "$b won");
  }

  Future speakScore() async {
    if (state.pointsA == 0 && state.pointsB == 0) {
      await audioPlayer.play(AssetSource('sounds/referee_whistle.mp3'));
      await Future.delayed(const Duration(seconds: 2));
    }

    String score = buildScoreText(forSpeech: true);
    String sideText = serveSide == Side.right
        ? "serve on the right"
        : "serve on the left";

    String textToSpeak = score.isNotEmpty ? "$score, $sideText" : sideText;

    await tts.stop();
    await tts.speak(textToSpeak);
  }

  String buildScoreText({bool forSpeech = false}) {
    String teamA = "${widget.players[0]} and ${widget.players[1]}";
    String teamB = "${widget.players[2]} and ${widget.players[3]}";

    if (state.pointsA >= 3 && state.pointsB >= 3) {
      if (state.pointsA == state.pointsB) {
        return "Deuce";
      } else if (state.pointsA > state.pointsB) {
        return forSpeech ? "advantage $teamA" : "Adv.\n$teamA";
      } else {
        return forSpeech ? "advantage $teamB" : "Adv.\n$teamB";
      }
    }

    if (forSpeech && state.pointsA == 0 && state.pointsB == 0) {
      return "";
    }

    String a = forSpeech
        ? speakScoreText(state.pointsA)
        : uiScore(state.pointsA);
    String b = forSpeech
        ? speakScoreText(state.pointsB)
        : uiScore(state.pointsB);

    if (forSpeech) {
      if (state.pointsA == state.pointsB) {
        return "$a all";
      }
      if (state.pointsA > state.pointsB) {
        return "$a $b to $teamA";
      }
      return "$b $a to $teamB";
    } else {
      return "$a - $b";
    }
  }

  void addPoint(bool isA) {
    HapticFeedback.lightImpact();

    setState(() {
      history.add(state.copy());

      if (isA) {
        state.pointsA++;
      } else {
        state.pointsB++;
      }

      serveSide = serveSide == Side.right ? Side.left : Side.right;

      checkGame();
    });

    speakScore();
  }

  void undo() {
    if (history.isNotEmpty) {
      setState(() {
        state = history.removeLast();
      });
    }
  }

  Future<void> endMatch() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("End Match"),
        content: const Text(
          "Are you sure you want to end this match and save the result?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("End & Save"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final winner = state.setsA > state.setsB
        ? 'A'
        : state.setsB > state.setsA
        ? 'B'
        : (state.gamesA > state.gamesB
              ? 'A'
              : state.gamesB > state.gamesA
              ? 'B'
              : 'A');

    final record = MatchRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      players: widget.players,
      setsA: state.setsA,
      setsB: state.setsB,
      gamesA: state.gamesA,
      gamesB: state.gamesB,
      winner: winner,
    );

    await HistoryService.saveMatch(record);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildScoreCard() {
    return Card(
      elevation: 12,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.grey[900]!, Colors.grey[850]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(
                    "SETS",
                    state.setsA,
                    state.setsB,
                    Colors.blue,
                  ),
                  Container(height: 50, width: 1, color: Colors.grey[700]),
                  _buildStatColumn(
                    "GAMES",
                    state.gamesA,
                    state.gamesB,
                    Colors.orange,
                  ),
                ],
              ),
              const Divider(height: 32, color: Colors.grey),
              Text(
                "CURRENT SCORE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                buildScoreText(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              serveBall(),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sports_tennis,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Server: $serverName",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    int valueA,
    int valueB,
    Color accentColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              "$valueA",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[300],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "-",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Text(
              "$valueB",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange[300],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamCard({
    required String player1,
    required String player2,
    required bool isTeamA,
    required VoidCallback onPressed,
  }) {
    final color = isTeamA ? Colors.blue : Colors.orange;
    return Expanded(
      child: Card(
        elevation: 8,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.8),
                  color.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isTeamA ? Icons.shield : Icons.shield_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Team ${isTeamA ? "A" : "B"}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    player1,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    player2,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "+ POINT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Match in Progress",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[800]!, Colors.green[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.save_alt),
                tooltip: 'End Match',
                onPressed: endMatch,
              ),
              IconButton(icon: const Icon(Icons.undo), onPressed: undo),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildScoreCard(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildTeamCard(
                      player1: widget.players[0],
                      player2: widget.players[1],
                      isTeamA: true,
                      onPressed: () => addPoint(true),
                    ),
                    const SizedBox(width: 12),
                    _buildTeamCard(
                      player1: widget.players[2],
                      player2: widget.players[3],
                      isTeamA: false,
                      onPressed: () => addPoint(false),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- SETTINGS SCREEN ----------------
class SettingsScreen extends StatefulWidget {
  final bool darkMode;
  final double speechRate;

  const SettingsScreen({
    super.key,
    required this.darkMode,
    required this.speechRate,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool darkMode;
  late double speechRate;

  @override
  void initState() {
    super.initState();
    darkMode = widget.darkMode;
    speechRate = widget.speechRate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text(
                          "Speech Speed",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      min: 0.5,
                      max: 1.5,
                      divisions: 10,
                      value: speechRate,
                      label: "x${speechRate.toStringAsFixed(1)}",
                      onChanged: (v) => setState(() => speechRate = v),
                    ),
                    Center(
                      child: Text(
                        "${speechRate.toStringAsFixed(1)}x",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'darkMode': darkMode,
                    'speechRate': speechRate,
                  });
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
