import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            ),
      home: PlayerSetupScreen(
        onToggleTheme: () => setState(() => darkMode = !darkMode),
      ),
    );
  }
}

// ---------------- SETUP SCREEN ----------------
class PlayerSetupScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const PlayerSetupScreen({super.key, required this.onToggleTheme});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Padel Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: c1, decoration: const InputDecoration(labelText: "Player 1")),
            TextField(controller: c2, decoration: const InputDecoration(labelText: "Player 2")),
            TextField(controller: c3, decoration: const InputDecoration(labelText: "Player 3")),
            TextField(controller: c4, decoration: const InputDecoration(labelText: "Player 4")),

            const SizedBox(height: 20),

            const Text("Starting Team"),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("Team A"),
                    value: Team.A,
                    groupValue: startingTeam,
                    onChanged: (v) => setState(() => startingTeam = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("Team B"),
                    value: Team.B,
                    groupValue: startingTeam,
                    onChanged: (v) => setState(() => startingTeam = v!),
                  ),
                ),
              ],
            ),

            const Text("First Server"),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("Player 1"),
                    value: true,
                    groupValue: firstPlayerServer,
                    onChanged: (v) => setState(() => firstPlayerServer = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("Player 2"),
                    value: false,
                    groupValue: firstPlayerServer,
                    onChanged: (v) => setState(() => firstPlayerServer = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              child: const Text("Start Match"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MatchScreen(
                      players: players,
                      startingServerIndex: startingServerIndex,
                      startingTeam: startingTeam,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
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
}

// ---------------- MATCH SCREEN ----------------
class MatchScreen extends StatefulWidget {
  final List<String> players;
  final int startingServerIndex;
  final Team startingTeam;

  const MatchScreen({
    super.key,
    required this.players,
    required this.startingServerIndex,
    required this.startingTeam,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  MatchState state = MatchState();
  late FlutterTts tts;

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
    serveOrder.add(serverIndex); // Game 1

    tts = FlutterTts();
    tts.setLanguage("en-US");
    tts.setSpeechRate(0.65);
  }

  // ---------------- DISPLAY ----------------
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

  // ---------------- TENNIS BALL ----------------
  Widget serveBall() {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 300),
      alignment:
          serveSide == Side.right ? Alignment.centerRight : Alignment.centerLeft,
      child: const Icon(Icons.sports_tennis, size: 50, color: Colors.green),
    );
  }

  // ---------------- SERVER ROTATION FIXED ----------------
  void rotateServerAfterGame() {

  // GAME 2 → choose the server of second team
    if (serveOrder.length == 1) {
      showServerDialog();
      return;
    }

    // GAME 3 → نفس الفريق الأول لكن اللاعب التاني
    if (serveOrder.length == 2) {
      int first = serveOrder[0];

      int next = (first == 0) ? 1
                : (first == 1) ? 0
                : (first == 2) ? 3
                : 2;

      serveOrder.add(next);
      serverIndex = next;
      return;
    }

    // GAME 4 → الفريق التاني اللاعب التاني
    if (serveOrder.length == 3) {
      int second = serveOrder[1];

      int next = (second == 0) ? 1
                : (second == 1) ? 0
                : (second == 2) ? 3
                : 2;

      serveOrder.add(next);
      serverIndex = next;
      return;
    }
  }

  void showServerDialog() {
    int firstServer = serveOrder[0];

    // choose the server in game 2 
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
        title: const Text("Choose server for Game 2"),
        content: const Text("Select from the opposite team"),
        actions: [
          for (int i in allowedPlayers)
            TextButton(
              onPressed: () {
                setState(() {
                  serveOrder.add(i);        // Game 2
                  buildFullServeOrder();   // complete the queue
                  serverIndex = i;
                });
                Navigator.pop(context);
              },
              child: Text(widget.players[i]),
            )
        ],
      ),
    );
  }

  void buildFullServeOrder() {
    if (serveOrder.length < 2) return;

    int first = serveOrder[0];
    int second = serveOrder[1];

    // other player of starting team 
    int third = (first == 0) ? 1
              : (first == 1) ? 0
              : (first == 2) ? 3
              : 2;

    // other player of other team
    int fourth = (second == 0) ? 1
              : (second == 1) ? 0
              : (second == 2) ? 3
              : 2;

    serveOrder = [first, second, third, fourth];
  }
  void nextServer() {
    currentGameIndex++;

    // choose server in Game 2
    if (currentGameIndex == 1 && serveOrder.length == 1) {
      showServerDialog();
      return;
    }

    if (serveOrder.length == 4) {
      serverIndex = serveOrder[currentGameIndex % 4];
    }
  }
  // ---------------- GAME LOGIC ----------------
  void checkGame() {
    if (state.pointsA >= 4 || state.pointsB >= 4) {
      int diff = state.pointsA - state.pointsB;

      if (diff >= 2) {
        state.gamesA++;
        state.pointsA = 0;
        state.pointsB = 0;
        nextServer();
        speakGameWinner("A");
      } else if (diff <= -2) {
        state.gamesB++;
        state.pointsA = 0;
        state.pointsB = 0;
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
    String score = buildScoreText(forSpeech: true);

    if (score.isEmpty) return;

    await tts.stop();
    await tts.speak(score);

    await Future.delayed(const Duration(milliseconds: 700));

    String sideText = serveSide == Side.right
        ? "serve on the right"
        : "serve on the left";

    await tts.speak(sideText);
  }
//---------------------------------------------------------------------------------
  String buildScoreText({bool forSpeech = false}) {
    String teamA = "${widget.players[0]} and ${widget.players[1]}";
    String teamB = "${widget.players[2]} and ${widget.players[3]}";

    // Deuce / Advantage
    if (state.pointsA >= 3 && state.pointsB >= 3) {
      if (state.pointsA == state.pointsB) {
        return "Deuce";
      } else if (state.pointsA > state.pointsB) {
        return forSpeech ? "advantage $teamA" : "Adv.\n$teamA";
      } else {
        return forSpeech ? "advantage $teamB" : "Adv.\n$teamB";
      }
    }

    // Skip love all for speech
    if (forSpeech && state.pointsA == 0 && state.pointsB == 0) {
      return "";
    }

    String a = forSpeech
        ? speakScoreText(state.pointsA)
        : uiScore(state.pointsA);

    String b = forSpeech
        ? speakScoreText(state.pointsB)
        : uiScore(state.pointsB);

    if (state.pointsA == state.pointsB) {
      return forSpeech ? "$a all" : "$a - $b";
    }

    return state.pointsA > state.pointsB
        ? "$a $b"
        : "$b $a";
  }
  // ---------------- POINT ----------------
  void addPoint(bool isA) {
    HapticFeedback.lightImpact();

    setState(() {
      history.add(state);

      if (isA) {
        state.pointsA++;
      } else {
        state.pointsB++;
      }

      serveSide =
          serveSide == Side.right ? Side.left : Side.right;

      checkGame();
    });

    speakScore();
  }

  // ---------------- UNDO ----------------
  void undo() {
    if (history.isNotEmpty) {
      setState(() {
        state = history.removeLast();
      });
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Padel Match"),
        actions: [
          IconButton(onPressed: undo, icon: const Icon(Icons.undo))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Sets: ${state.setsA} - ${state.setsB}"),
          Text("Games: ${state.gamesA} - ${state.gamesB}"),

          const SizedBox(height: 10),

          serveBall(),

          Text(
            buildScoreText(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text("Server: $serverName"),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => addPoint(true),
                  child: Text("${widget.players[0]} / ${widget.players[1]}"),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => addPoint(false),
                  child: Text("${widget.players[2]} / ${widget.players[3]}"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}