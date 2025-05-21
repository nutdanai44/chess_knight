import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../GripPage/chess_grid_page.dart';

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController iController = TextEditingController();
  final TextEditingController jController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void navigateToGridPage() {
    final int? i = int.tryParse(iController.text);
    final int? j = int.tryParse(jController.text);
    final String playerName = nameController.text.trim();

    if (i != null && j != null && i > 0 && j > 0 && playerName.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChessGridPage(
            i: i,
            j: j,
            playerName: playerName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly!')),
      );
    }
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data cleared successfully!')),
    );
  }

  void confirmClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Clear Data'),
        content: const Text('Are you sure you want to clear all data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              clearData();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Grid Dimensions'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter number of rows (i)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: jController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter number of columns (j)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: navigateToGridPage,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: confirmClearData,
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
      ),
    );
  }
}