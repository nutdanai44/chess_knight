import 'package:flutter/material.dart';
import '../stack.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:poc_app/Leaderboard/leaderboard_entry.dart';

class ChessGridPage extends StatefulWidget {
  final int i; // Number of rows
  final int j; // Number of columns
  final String playerName; // Player's name

  const ChessGridPage({super.key, required this.i, required this.j, required this.playerName});

  @override
  State<ChessGridPage> createState() => _ChessGridPageState();
}

class _ChessGridPageState extends State<ChessGridPage> {
  late List<Color> buttonColors;
  late List<String> buttonLabels;
  int? lastPressedIndex;
  List<int> validMoves = [];
  Set<int> pressedButtons = {}; // Store pressed button indices
  int moveCount = 0;
  late int totalCells;
  final ChessStack<int> pressedHistory = ChessStack<int>();
  int pressedHistoryCount = 0;
  late Stopwatch stopwatch;

  @override
  void initState() {
    super.initState();
    totalCells = widget.i * widget.j;
    buttonColors = List<Color>.filled(totalCells, Colors.lightBlue.shade100); // Set lighter background
    buttonLabels = List<String>.filled(totalCells, '');
    stopwatch = Stopwatch()..start();
  }

  void onButtonPressed(int index) {
    if (pressedButtons.contains(index)) return; // Prevent re-clicking

    if (lastPressedIndex == null) {
      // First button press
      setState(() {
        buttonColors[index] = Colors.red;
        buttonLabels[index] = (++moveCount).toString();
        lastPressedIndex = index;
        pressedButtons.add(index);
        pressedHistory.push(index);
        highlightValidMoves(index);
      });
      return;
    }

    if (!validMoves.contains(index)) return; // Invalid move, do nothing

    setState(() {
      // Reset the last pressed button to blue
      buttonColors[lastPressedIndex!] = Colors.blue;

      // Highlight the current button
      buttonColors[index] = Colors.red;
      buttonLabels[index] = (++moveCount).toString();

      // Update the last pressed index
      lastPressedIndex = index;

      // Add the current button to pressedButtons
      pressedButtons.add(index);
      pressedHistory.push(index);

      // Highlight new valid moves
      highlightValidMoves(index);

      // Check win or lose conditions
      if (pressedButtons.length == totalCells) {
        stopwatch.stop();
        showEndDialog('ชนะ', widget.playerName, '${widget.i}x${widget.j}');
      } else if (validMoves.isEmpty) {
        stopwatch.stop();
        showEndDialog('แพ้', widget.playerName, '${widget.i}x${widget.j}');
      }
    });
  }

  void onBackPressed() {
    if (pressedHistory.isEmpty) return; // No steps to go back

    setState(() {
      // Remove the last pressed button
      pressedHistoryCount += 1;
      int lastIndex = pressedHistory.pop();
      buttonColors[lastIndex] = Colors.lightBlue.shade100; // Reset to lighter background
      buttonLabels[lastIndex] = '';
      pressedButtons.remove(lastIndex);

      // Update the last pressed index
      lastPressedIndex = pressedHistory.isEmpty ? null : pressedHistory.top();

      // Recalculate valid moves
      if (lastPressedIndex != null) {
        highlightValidMoves(lastPressedIndex!);
      } else {
        validMoves.clear();
        for (int i = 0; i < buttonColors.length; i++) {
          if (buttonColors[i] == Colors.yellow) {
            buttonColors[i] = Colors.lightBlue.shade100;
          }
        }
      }
    });
  }

  void highlightValidMoves(int index) {
    // Reset all valid move highlights
    for (int i = 0; i < buttonColors.length; i++) {
      if (buttonColors[i] == Colors.yellow) {
        buttonColors[i] = Colors.lightBlue.shade100;
      }
    }

    // Calculate row and column of the current button
    int row = index ~/ widget.j;
    int col = index % widget.j;

    // Calculate valid knight moves
    List<List<int>> moves = [
      [row - 2, col - 1],
      [row - 2, col + 1],
      [row - 1, col - 2],
      [row - 1, col + 2],
      [row + 1, col - 2],
      [row + 1, col + 2],
      [row + 2, col - 1],
      [row + 2, col + 1],
    ];

    validMoves.clear();
    for (var move in moves) {
      int newRow = move[0];
      int newCol = move[1];
      if (newRow >= 0 &&
          newRow < widget.i &&
          newCol >= 0 &&
          newCol < widget.j) {
        int newIndex = newRow * widget.j + newCol;
        if (!pressedButtons.contains(newIndex)) {
          buttonColors[newIndex] = Colors.yellow;
          validMoves.add(newIndex);
        }
      }
    }
  }

  void saveWin(String playerName, String cellSize, String timeTaken, int backCount) async {
    final prefs = await SharedPreferences.getInstance();
    final String? leaderboardData = prefs.getString('leaderboard');
    List<LeaderboardEntry> leaderboard = [];

    if (leaderboardData != null) {
      final List<dynamic> decodedData = jsonDecode(leaderboardData);
      leaderboard = decodedData.map((e) => LeaderboardEntry.fromMap(e)).toList();
    }

    // เพิ่มข้อมูลใหม่
    leaderboard.add(LeaderboardEntry(
      name: playerName,
      cellSize: cellSize,
      timeTaken: timeTaken,
      backCount: backCount,
      score: 0,
    ));

    final String updatedData = jsonEncode(leaderboard.map((e) => e.toMap()).toList());
    await prefs.setString('leaderboard', updatedData);

    // Debugging
    print('Saved Leaderboard: $updatedData');
  }

  void showEndDialog(String message, String playerName, String cellSize) {
    final String timeTaken = stopwatch.elapsed.toString().split('.').first; // Format time
    final int backCount = pressedHistoryCount; // Count of back actions used

    if (message == 'ชนะ') {
      saveWin(playerName, cellSize, timeTaken, backCount);
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Knight Movement'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: onBackPressed,
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.j, // Number of columns
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColors[index],
              ),
              onPressed: () => onButtonPressed(index),
              child: Text(
                buttonLabels[index],
                style: const TextStyle(
                  fontSize: 18, // Larger font size
                  fontWeight: FontWeight.bold, // Bold text
                  color: Colors.black, // Text color
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}