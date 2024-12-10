
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

  String selectedDifficulty = '';
  String question = '';
  String correctAnswer = '';

  final Map<String, List<Map<String, String>>> questions = {
    'easy': [
      {'question': 'What is 2 + 2?', 'answer': '4'},
      {'question': 'What is 5 - 3?', 'answer': '2'},
    ],
    'medium': [
      {'question': 'What is 6 x 7?', 'answer': '42'},
      {'question': 'What is 12 ÷ 4?', 'answer': '3'},
    ],
    'hard': [
      {'question': 'What is the square root of 81?', 'answer': '9'},
      {'question': 'Solve: 2^3 + 3!', 'answer': '14'},
    ],
  };

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _selectDifficulty(String difficulty) {
    setState(() {
      selectedDifficulty = difficulty;
      _loadQuestion();
    });
  }

  void _loadQuestion() {
    final List<Map<String, String>> selectedQuestions = questions[selectedDifficulty]!;
    final Map<String, String> randomQuestion =
        (selectedQuestions..shuffle()).first;

    question = randomQuestion['question']!;
    correctAnswer = randomQuestion['answer']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle Challenge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: selectedDifficulty.isEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Difficulty Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDifficulty('easy'),
              child: const Text('Easy'),
            ),
            ElevatedButton(
              onPressed: () => _selectDifficulty('medium'),
              child: const Text('Medium'),
            ),
            ElevatedButton(
              onPressed: () => _selectDifficulty('hard'),
              child: const Text('Hard'),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question,
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
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_answerController.text.trim() == correctAnswer) {
                  // Correct answer, cancel the alarm
                  await flutterLocalNotificationsPlugin
                      .cancel(widget.notificationId);

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
                    question = 'Try again! $question';
                    _answerController.clear();
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
}

