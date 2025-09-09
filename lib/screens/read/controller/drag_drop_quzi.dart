import 'package:flutter/material.dart';

class DragDropQuiz extends StatefulWidget {
  @override
  _DragDropQuizState createState() => _DragDropQuizState();
}

class _DragDropQuizState extends State<DragDropQuiz> {
  Map<String, String?> answers = {
    'A': null,
    'B': null,
    'C': null,
    'D': null,
  };

  final List<String> emotions = ['Disappointed', 'Angry', 'Motivated', 'Confused'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.orange),
                  onPressed: () {},
                ),
                Text("Healthy Coping Mechanisms Quiz", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(value: 0.5, color: Colors.purple),
                Text("12", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
              ],
            ),
            SizedBox(height: 10),
            Text("Question 05/10", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            LinearProgressIndicator(value: 0.5, color: Colors.orange),
            SizedBox(height: 20),
            Image.network('https://via.placeholder.com/300x150', height: 150),
            SizedBox(height: 10),
            Text("Help Ken identify his emotions after receiving critical feedback on his project. Drag and drop the appropriate emotion labels to match his expressions."),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: emotions.map((emotion) => Draggable<String>(
                data: emotion,
                feedback: Material(
                  child: Chip(label: Text(emotion), backgroundColor: Colors.blueAccent),
                ),
                childWhenDragging: Chip(label: Text(emotion), backgroundColor: Colors.grey),
                child: Chip(label: Text(emotion), backgroundColor: Colors.blue),
              )).toList(),
            ),
            SizedBox(height: 20),
            Column(
              children: answers.keys.map((key) => buildDragTarget(key)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDragTarget(String key) {
    return DragTarget<String>(
      onAccept: (value) {
        setState(() {
          answers[key] = value;
        });
      },
      builder: (context, candidateData, rejectedData) => Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(answers[key] ?? "Drag & drop here", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
