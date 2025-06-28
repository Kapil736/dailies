import 'package:flutter/material.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  // Sample data: 4 categories with 4 words each
  final Map<String, List<String>> categories = {
    "Fruits": ["Apple", "Banana", "Orange", "Grape"],
    "Colors": ["Red", "Blue", "Green", "Yellow"],
    "Animals": ["Dog", "Cat", "Horse", "Elephant"],
    "Countries": ["India", "USA", "China", "France"],
  };

  List<String> shuffledWords = [];
  List<String> selectedWords = [];
  int attemptsLeft = 5; // Max incorrect attempts

  List<String> correctGroups = []; // Tracks correctly guessed categories

  @override
  void initState() {
    super.initState();
    // Flatten and shuffle the word list
    shuffledWords = categories.values.expand((words) => words).toList();
    shuffledWords.shuffle();
  }

  void onWordTap(String word) {
    setState(() {
      if (selectedWords.contains(word)) {
        selectedWords.remove(word); // Deselect if already selected
      } else {
        selectedWords.add(word);
        // Check if selection is complete
        if (selectedWords.length == 4) {
          checkSelection();
        }
      }
    });
  }

  void checkSelection() {
    // Check if selected words belong to the same category
    String? matchedCategory;
    for (var entry in categories.entries) {
      if (entry.value.toSet().containsAll(selectedWords.toSet())) {
        matchedCategory = entry.key;
        break;
      }
    }

    if (matchedCategory != null) {
      // Correct group
      correctGroups.add(matchedCategory);
      shuffledWords.removeWhere((word) => selectedWords.contains(word));
      showFeedbackDialog(
          "Correct!", "You grouped the $matchedCategory category.");
    } else {
      // Incorrect group
      attemptsLeft--;
      showFeedbackDialog(
          "Incorrect!", "This group doesn't match any category.");
    }

    // Reset selection
    selectedWords.clear();

    // Check win/lose conditions
    if (correctGroups.length == 4) {
      showEndDialog("Congratulations!", "You found all the groups!");
    } else if (attemptsLeft == 0) {
      showEndDialog("Game Over", "You've run out of attempts!");
    }
  }

  void showFeedbackDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void showEndDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text("Play Again"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to main menu
              },
              child: const Text("Exit"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      shuffledWords = categories.values.expand((words) => words).toList();
      shuffledWords.shuffle();
      selectedWords.clear();
      correctGroups.clear();
      attemptsLeft = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connections Game"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Grid of words
            Expanded(
              child: GridView.builder(
                itemCount: shuffledWords.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (context, index) {
                  final word = shuffledWords[index];
                  final isSelected = selectedWords.contains(word);
                  return GestureDetector(
                    onTap: () => onWordTap(word),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade200
                            : Colors.grey.shade300,
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        word,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Attempts remaining
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Attempts Left: $attemptsLeft",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
