class Question {
  final String question;
  final List<String> options;
  final String correct;
  final String explanation;

  Question({
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      correct: json['correct'],
      explanation: json['explanation'],
    );
  }
}
