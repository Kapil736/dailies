import 'package:flutter/material.dart';
import 'wordle_screen.dart'; // Import your Wordle game screen
import 'connections_screen.dart'; // Import your Connections game screen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dailies"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            const Text(
              "Welcome to Dailies!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),

            // Game Section Title
            const Text(
              "Games",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Game Buttons with Animations
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Two items per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 4 / 3, // Adjust button size
                children: [
                  // Wordle Game Button
                  AnimatedGameButton(
                    title: "Wordle",
                    color: Colors.deepPurple.shade100,
                    icon: Icons.gamepad,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WordleScreen()),
                      );
                    },
                  ),
                  // Connections Game Button
                  AnimatedGameButton(
                    title: "Connections",
                    color: Colors.blue.shade100,
                    icon: Icons.link,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ConnectionsScreen()),
                      );
                    },
                  ),
                  // Placeholder for Globle
                  AnimatedGameButton(
                    title: "Coming Soon",
                    color: Colors.orange.shade100,
                    icon: Icons.lightbulb_outline,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Feature coming soon!")),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Daily Challenge Section
            const Text(
              "Daily Challenge",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.orange),
                  SizedBox(width: 10),
                  Text(
                    "Try Today's Wordle!!",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Animated Game Button Widget
class AnimatedGameButton extends StatefulWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const AnimatedGameButton({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  _AnimatedGameButtonState createState() => _AnimatedGameButtonState();
}

class _AnimatedGameButtonState extends State<AnimatedGameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isPressed
            ? (Matrix4.identity()..scale(0.95)) // Fix: Added parentheses
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!_isPressed)
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(2, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 40,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 10),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
