
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PuzzlePage extends StatefulWidget {
  final int notificationId;

  const PuzzlePage({required this.notificationId, Key? key}) : super(key: key);

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final TextEditingController _answerController = TextEditingController();
  final String correctAnswer = "42"; // Set your desired correct answer

  String _message = "Solve this: What is 6 x 7?";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _message,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your Answer',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_answerController.text.trim() == correctAnswer) {
                  // Correct answer, cancel the alarm
                  await flutterLocalNotificationsPlugin.cancel(widget.notificationId);

                  // Show success message and navigate back
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Correct!'),
                      content: const Text('The alarm has been stopped.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Incorrect answer
                  setState(() {
                    _message = "Try again! Hint: Patience It's the answer to everything.";
                  });
                }
              },
              child: const Text('Submit Answer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}