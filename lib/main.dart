import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'question_model.dart';

void main() => runApp(QuizApp());

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  List<Question> questions = [];
  int currentQuestion = 0;
  int score = 0;
  String? selectedAnswer;
  bool showExplanation = false;
  bool isAnswerSelected = false;
  String feedbackMessage = "";

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final data = await rootBundle.loadString('assets/questions.json');
    final json = jsonDecode(data);
    setState(() {
      questions = (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestion < questions.length - 1) {
        currentQuestion++;
        selectedAnswer = null;
        showExplanation = false;
        isAnswerSelected = false;
        feedbackMessage = "";
      }
    });
  }

  void checkAnswer(String answer) {
    setState(() {
      isAnswerSelected = true;
      if (answer == questions[currentQuestion].correct) {
        score++;
        feedbackMessage = "Correct!";
      } else {
        feedbackMessage = "Wrong! The correct answer is: ${questions[currentQuestion].correct}";
      }
      showExplanation = true;
    });
  }

  void showScoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Score after ${currentQuestion + 1} questions"),
        content: Text("Your score: $score/${currentQuestion + 1}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Continue"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Logical Thinking Quiz"),
          actions: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Score: $score", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        body: questions.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Question ${currentQuestion + 1}/${questions.length}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Text(
                questions[currentQuestion].question,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 20),
              ...questions[currentQuestion].options.map((option) {
                bool isCorrect = option == questions[currentQuestion].correct;
                return GestureDetector(
                  onTap: () => isAnswerSelected ? null : checkAnswer(option),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isAnswerSelected
                          ? isCorrect
                          ? Colors.green.withOpacity(0.7)
                          : Colors.red.withOpacity(0.7)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAnswerSelected
                            ? isCorrect
                            ? Colors.green
                            : Colors.red
                            : Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isAnswerSelected
                            ? isCorrect
                            ? Colors.white
                            : Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              }),
              if (showExplanation) ...[
                SizedBox(height: 20),
                Text(
                  "Explanation: ${questions[currentQuestion].explanation}",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  feedbackMessage,
                  style: TextStyle(
                    color: isAnswerSelected
                        ? (isAnswerSelected && feedbackMessage == "Correct!" ? Colors.green : Colors.red)
                        : Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: nextQuestion,
                  child: Text("Next Question"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
