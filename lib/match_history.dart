import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------- MATCH RECORD MODEL ----------------
class MatchRecord {
  final String id;
  final DateTime dateTime;
  final List<String> players;
  final int setsA;
  final int setsB;
  final int gamesA;
  final int gamesB;
  final String winner;

  MatchRecord({
    required this.id,
    required this.dateTime,
    required this.players,
    required this.setsA,
    required this.setsB,
    required this.gamesA,
    required this.gamesB,
    required this.winner,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'players': players,
    'setsA': setsA,
    'setsB': setsB,
    'gamesA': gamesA,
    'gamesB': gamesB,
    'winner': winner,
  };

  factory MatchRecord.fromJson(Map<String, dynamic> json) => MatchRecord(
    id: json['id'] as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    players: List<String>.from(json['players'] as List),
    setsA: json['setsA'] as int,
    setsB: json['setsB'] as int,
    gamesA: json['gamesA'] as int,
    gamesB: json['gamesB'] as int,
    winner: json['winner'] as String,
  );
}

// ---------------- HISTORY SERVICE ----------------
class HistoryService {
  static const _key = 'match_history';

  static Future<void> saveMatch(MatchRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_key) ?? [];
    existing.insert(0, jsonEncode(record.toJson()));
    await prefs.setStringList(_key, existing);
  }

  static Future<List<MatchRecord>> getMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => MatchRecord.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> deleteMatch(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    final updated = raw.where((e) {
      final record = MatchRecord.fromJson(
        jsonDecode(e) as Map<String, dynamic>,
      );
      return record.id != id;
    }).toList();
    await prefs.setStringList(_key, updated);
  }
}

// ---------------- HISTORY SCREEN ----------------
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<MatchRecord> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final matches = await HistoryService.getMatches();
    setState(() {
      _matches = matches;
      _loading = false;
    });
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Match'),
        content: const Text('Are you sure you want to delete this match?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService.deleteMatch(id);
      _load();
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all match history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService.clearHistory();
      _load();
    }
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final month = _twoDigits(d.month);
    final day = _twoDigits(d.day);
    final hour = _twoDigits(d.hour);
    final minute = _twoDigits(d.minute);
    return '$month/$day/${d.year}  $hour:$minute';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

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
                'Match History',
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
            actions: const [],
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_matches.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No matches yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete a match to see it here',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final match = _matches[index];
                  return _buildMatchCard(match);
                }, childCount: _matches.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(MatchRecord match) {
    final teamA = '${match.players[0]} & ${match.players[1]}';
    final teamB = '${match.players[2]} & ${match.players[3]}';
    final isTeamAWinner = match.winner == 'A';

    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(match.dateTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isTeamAWinner
                            ? Colors.blue.withValues(alpha: 0.15)
                            : Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isTeamAWinner ? 'Team A Wins' : 'Team B Wins',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isTeamAWinner ? Colors.blue : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _confirmDelete(match.id),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTeamInfo(
                    teamA,
                    match.setsA,
                    match.gamesA,
                    Colors.blue,
                    isTeamAWinner,
                  ),
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: _buildTeamInfo(
                    teamB,
                    match.setsB,
                    match.gamesB,
                    Colors.orange,
                    !isTeamAWinner,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo(
    String name,
    int sets,
    int games,
    Color color,
    bool isWinner,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isWinner ? Icons.emoji_events : Icons.shield,
              size: 16,
              color: isWinner ? Colors.amber : color.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? color : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreBadge('SETS', sets, color),
            const SizedBox(width: 12),
            _buildScoreBadge('GAMES', games, color.withValues(alpha: 0.7)),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreBadge(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
