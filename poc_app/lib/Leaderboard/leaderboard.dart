import 'package:flutter/material.dart';
import 'dart:convert';
import 'leaderboard_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<LeaderboardEntry> leaderboard = [];

  @override
  void initState() {
    super.initState();
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final String? leaderboardData = prefs.getString('leaderboard');
    if (leaderboardData != null) {
      final List<dynamic> decodedData = jsonDecode(leaderboardData);
      setState(() {
        leaderboard = decodedData.map((e) => LeaderboardEntry.fromMap(e)).toList();
      });

      // Debugging
      print('Loaded Leaderboard: $leaderboard');
    } else {
      print('No leaderboard data found.');
    }
  }

  double calculateScore(String timeTaken, int backCount, String cellSize) {
    const double timeFactor = 100.0; // Adjustable factor for time
    const double backFactor = 20.0;  // Adjustable factor for back actions
    const double sizeFactor = 50.0;  // Adjustable factor for grid size
    const double baseScore = 1000.0;

    // Parse timeTaken (e.g., "00:05:30") into seconds
    final timeParts = timeTaken.split(':').map(int.parse).toList();
    final int totalSeconds = (timeParts[0] * 3600) + (timeParts[1] * 60) + timeParts[2];

    // Parse cellSize (e.g., "5x5") into total cells
    final sizeParts = cellSize.split('x').map(int.parse).toList();
    final int totalCells = sizeParts[0] * sizeParts[1];

    // Calculate score
    return (baseScore / totalSeconds) * timeFactor
        - (backCount * backFactor)
        + (totalCells * sizeFactor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: loadLeaderboard,
        child: ListView.builder(
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final entry = leaderboard[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(entry.name),
              subtitle: Text(
                'Cell Size: ${entry.cellSize}\n'
                    'Time: ${entry.timeTaken}\n'
                    'Backs Count: ${entry.backCount}\n'
                    'Score: ${calculateScore(entry.timeTaken, entry.backCount, entry.cellSize).toStringAsFixed(2)}',
              ),
            );
          },
        ),
      ),
    );
  }
}