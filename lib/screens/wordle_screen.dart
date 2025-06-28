import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

void testFirebaseConnection() async {
  try {
    await FirebaseFirestore.instance
        .collection("test")
        .doc("testDoc")
        .set({"message": "Firebase is connected!"});
    print("Firebase connection successful!");
  } catch (e) {
    print("Error connecting to Firebase: $e");
  }
}

class WordleScreen extends StatefulWidget {
  const WordleScreen({Key? key}) : super(key: key);

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen>
    with SingleTickerProviderStateMixin {
  late String correctWord = "ERROR";
  late String explanation = "Could not fetch the word.";

  List<List<String>> grid =
      List.generate(6, (_) => List.generate(5, (_) => ''));
  List<List<Color>> gridColors =
      List.generate(6, (_) => List.generate(5, (_) => Colors.white));
  Map<String, Color> keyboardColors = {};
  int currentRow = 0;
  int currentCol = 0;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    fetchDailyWord();

    _shakeController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _shakeAnimation =
        Tween<double>(begin: 0, end: 10).animate(_shakeController);
  }

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print("Firebase initialized successfully!");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }
  }

  Future<void> fetchDailyWord() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().substring(0, 10);
    print("Today's date: $today");

    try {
      print("Fetching word from Firestore...");
      final doc = await FirebaseFirestore.instance
          .collection("daily_word")
          .doc(today)
          .get();

      if (doc.exists) {
        print("Document found: ${doc.data()}");
        setState(() {
          correctWord = doc["daily_word"] ?? "ERROR";
          explanation = doc["explanation"] ?? "No explanation available.";
        });

        // Update SharedPreferences with the new word and date
        prefs.setString('last_date', today);
        prefs.setString('daily_word', correctWord);
        prefs.setString('daily_explanation', explanation);
      } else {
        print("No word document found in Firestore for date: $today");
        setState(() {
          correctWord = "ERROR";
          explanation = "No word found for today.";
        });
      }
    } catch (e) {
      print("Error fetching word from Firestore: $e");
      setState(() {
        correctWord = "ERROR";
        explanation = "Could not fetch the word.";
      });
    }
  }

  Future<bool> isWordValid(String word) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error validating word: $e");
      return false;
    }
  }

  void handleKeyPress(String key) {
    if (currentCol < 5 && currentRow < 6) {
      setState(() {
        grid[currentRow][currentCol] = key;
        currentCol++;
      });
    }
  }

  void handleEnterPress() async {
    if (currentCol == 5) {
      final String guess = grid[currentRow].join();

      if (await isWordValid(guess)) {
        if (guess == correctWord) {
          setState(() {
            updateGridColors(guess);
          });

          showResultDialog(true);
        } else {
          updateGridColors(guess);
          if (currentRow < 5) {
            setState(() {
              currentRow++;
              currentCol = 0;
            });
          } else {
            showResultDialog(false);
          }
        }
      } else {
        _shakeController.forward(from: 0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid word, please try again!')),
        );
      }
    }
  }

  void handleBackspacePress() {
    if (currentCol > 0) {
      setState(() {
        currentCol--;
        grid[currentRow][currentCol] = '';
      });
    }
  }

  void updateGridColors(String guess) {
    List<bool> correctLetters = List.filled(5, false);
    Map<String, int> letterCount = {};

    for (var letter in correctWord.characters) {
      letterCount[letter] = (letterCount[letter] ?? 0) + 1;
    }

    for (int i = 0; i < 5; i++) {
      if (guess[i] == correctWord[i]) {
        gridColors[currentRow][i] = Colors.green;
        keyboardColors[guess[i]] = Colors.green;
        correctLetters[i] = true;
        letterCount[guess[i]] = letterCount[guess[i]]! - 1;
      }
    }

    for (int i = 0; i < 5; i++) {
      if (!correctLetters[i]) {
        if (letterCount.containsKey(guess[i]) && letterCount[guess[i]]! > 0) {
          gridColors[currentRow][i] = Colors.yellow;
          if (keyboardColors[guess[i]] != Colors.green) {
            keyboardColors[guess[i]] = Colors.yellow;
          }
          letterCount[guess[i]] = letterCount[guess[i]]! - 1;
        } else {
          gridColors[currentRow][i] = Colors.grey;
          if (keyboardColors[guess[i]] == null) {
            keyboardColors[guess[i]] = Colors.grey;
          }
        }
      }
    }
    setState(() {});
  }

  void showResultDialog(bool won) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(won ? "You Win!" : "Game Over"),
          content: Text(
            won
                ? "Congratulations! You guessed the word!\n\nWord: $correctWord\nExplanation: $explanation"
                : "The word was $correctWord.\nExplanation: $explanation",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      grid = List.generate(6, (_) => List.generate(5, (_) => ''));
      gridColors =
          List.generate(6, (_) => List.generate(5, (_) => Colors.white));
      keyboardColors = {};
      currentRow = 0;
      currentCol = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wordle Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value - 5, 0),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: grid.asMap().entries.map((entry) {
                    int rowIndex = entry.key;
                    List<String> row = entry.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: row.asMap().entries.map((cellEntry) {
                        int colIndex = cellEntry.key;
                        String cell = cellEntry.value;
                        return Container(
                          margin: const EdgeInsets.all(4),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: gridColors[rowIndex][colIndex],
                            border: Border.all(color: Colors.grey),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cell,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                flex: 2,
                child: WordleKeyboard(
                  onKeyPress: handleKeyPress,
                  onEnterPress: handleEnterPress,
                  onBackspacePress: handleBackspacePress,
                  keyboardColors: keyboardColors,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WordleKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;
  final Function() onEnterPress;
  final Function() onBackspacePress;
  final Map<String, Color> keyboardColors;

  const WordleKeyboard({
    required this.onKeyPress,
    required this.onEnterPress,
    required this.onBackspacePress,
    required this.keyboardColors,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<List<String>> keys = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M']
    ];

    final double buttonWidth = (MediaQuery.of(context).size.width - 16) / 10.8;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              return SizedBox(
                width: buttonWidth,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: keyboardColors[key] ?? Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () => onKeyPress(key),
                  child: Text(
                    key,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onEnterPress,
              child: const Text('Enter'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onBackspacePress,
              child: const Text('Backspace'),
            ),
          ],
        ),
      ],
    );
  }
}
